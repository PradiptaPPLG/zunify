import { Router, Request, Response } from 'express';
import { v4 as uuidv4 } from 'uuid';
import { z } from 'zod';
import { dbData, saveDb } from '../db/database';
import { logger } from '../utils/logger';

export const playlistRouter = Router();

function success(data: unknown) {
  return { success: true, data };
}

function fail(message: string) {
  return { success: false, data: null, message };
}

// ─── Playlists CRUD ───────────────────────────────────────────────────────────

playlistRouter.get('/', (_req: Request, res: Response) => {
  try {
    const playlists = [...dbData.playlists].sort((a, b) => 
      new Date(b.updated_at).getTime() - new Date(a.updated_at).getTime()
    );
    
    const results = playlists.map((p: any) => {
      const tracks = dbData.playlist_tracks
        .filter(t => t.playlist_id === p.id)
        .sort((a, b) => a.position - b.position)
        .map(mapTrackRow);
        
      return {
        id: p.id,
        name: p.name,
        description: p.description,
        coverUrl: p.cover_url,
        trackCount: tracks.length,
        createdAt: p.created_at,
        updatedAt: p.updated_at,
        tracks,
      };
    });

    return res.json(success(results));
  } catch (err: any) {
    logger.error(`Get playlists error: ${err.message}`);
    return res.status(500).json(fail('Failed to load playlists'));
  }
});

playlistRouter.post('/', (req: Request, res: Response) => {
  const schema = z.object({
    name: z.string().min(1).max(100),
    description: z.string().max(500).optional(),
  });

  const parsed = schema.safeParse(req.body);
  if (!parsed.success) {
    return res.status(400).json(fail('Invalid playlist data'));
  }

  const { name, description } = parsed.data;
  const id = uuidv4();
  const now = new Date().toISOString();

  try {
    const playlist = {
      id,
      name,
      description: description || null,
      cover_url: null,
      created_at: now,
      updated_at: now
    };
    dbData.playlists.push(playlist);
    saveDb();
    
    return res.json(success({
      id: playlist.id,
      name: playlist.name,
      description: playlist.description,
      coverUrl: playlist.cover_url,
      trackCount: 0,
      createdAt: playlist.created_at,
      updatedAt: playlist.updated_at,
      tracks: [],
    }));
  } catch (err: any) {
    logger.error(`Create playlist error: ${err.message}`);
    return res.status(500).json(fail('Failed to create playlist'));
  }
});

playlistRouter.get('/:id', (req: Request, res: Response) => {
  const { id } = req.params;
  try {
    const playlist = dbData.playlists.find(p => p.id === id);
    if (!playlist) return res.status(404).json(fail('Playlist not found'));

    const tracks = dbData.playlist_tracks
        .filter(t => t.playlist_id === id)
        .sort((a, b) => a.position - b.position)
        .map(mapTrackRow);

    return res.json(success({
      id: playlist.id,
      name: playlist.name,
      description: playlist.description,
      coverUrl: playlist.cover_url,
      trackCount: tracks.length,
      createdAt: playlist.created_at,
      updatedAt: playlist.updated_at,
      tracks,
    }));
  } catch (err: any) {
    logger.error(`Get playlist error: ${err.message}`);
    return res.status(500).json(fail('Failed to load playlist'));
  }
});

playlistRouter.patch('/:id', (req: Request, res: Response) => {
  const { id } = req.params;
  const schema = z.object({
    name: z.string().min(1).max(100).optional(),
    description: z.string().max(500).optional(),
  });

  const parsed = schema.safeParse(req.body);
  if (!parsed.success) {
    return res.status(400).json(fail('Invalid update data'));
  }

  try {
    const playlist = dbData.playlists.find(p => p.id === id);
    if (!playlist) return res.status(404).json(fail('Playlist not found'));

    const { name, description } = parsed.data;
    if (name) playlist.name = name;
    if (description !== undefined) playlist.description = description;
    playlist.updated_at = new Date().toISOString();
    saveDb();

    const tracks = dbData.playlist_tracks
        .filter(t => t.playlist_id === id)
        .sort((a, b) => a.position - b.position)
        .map(mapTrackRow);

    return res.json(success({
      id: playlist.id,
      name: playlist.name,
      description: playlist.description,
      coverUrl: playlist.cover_url,
      trackCount: tracks.length,
      createdAt: playlist.created_at,
      updatedAt: playlist.updated_at,
      tracks,
    }));
  } catch (err: any) {
    logger.error(`Update playlist error: ${err.message}`);
    return res.status(500).json(fail('Failed to update playlist'));
  }
});

playlistRouter.delete('/:id', (req: Request, res: Response) => {
  const { id } = req.params;
  try {
    dbData.playlists = dbData.playlists.filter(p => p.id !== id);
    dbData.playlist_tracks = dbData.playlist_tracks.filter(t => t.playlist_id !== id);
    saveDb();
    return res.json(success(null));
  } catch (err: any) {
    logger.error(`Delete playlist error: ${err.message}`);
    return res.status(500).json(fail('Failed to delete playlist'));
  }
});

// ─── Playlist Tracks ──────────────────────────────────────────────────────────

const trackSchema = z.object({
  sourceId: z.string(),
  title: z.string(),
  artist: z.string(),
  album: z.string().nullable().optional(),
  thumbnailUrl: z.string().nullable().optional(),
  duration: z.number().nullable().optional(),
  source: z.string().default('youtube'),
});

playlistRouter.post('/:id/tracks', (req: Request, res: Response) => {
  const { id } = req.params;
  const parsed = trackSchema.safeParse(req.body);
  if (!parsed.success) {
    return res.status(400).json(fail('Invalid track data'));
  }

  const t = parsed.data;
  const trackId = uuidv4();

  try {
    const existing = dbData.playlist_tracks.find(x => x.playlist_id === id && x.source_id === t.sourceId);
    if (existing) {
        return res.status(400).json(fail('Track already in playlist'));
    }

    const playlistTracks = dbData.playlist_tracks.filter(x => x.playlist_id === id);
    const maxPos = playlistTracks.length > 0 ? Math.max(...playlistTracks.map(x => x.position)) : -1;
    const pos = maxPos + 1;

    dbData.playlist_tracks.push({
        id: trackId,
        playlist_id: id,
        source_id: t.sourceId,
        title: t.title,
        artist: t.artist,
        album: t.album || null,
        thumbnail_url: t.thumbnailUrl || null,
        duration: t.duration || null,
        source: t.source,
        position: pos,
        added_at: new Date().toISOString()
    });

    const playlist = dbData.playlists.find(p => p.id === id);
    if (playlist) playlist.updated_at = new Date().toISOString();

    saveDb();

    return res.json(success(null));
  } catch (err: any) {
    logger.error(`Add track error: ${err.message}`);
    return res.status(500).json(fail('Failed to add track'));
  }
});

playlistRouter.delete('/:id/tracks/:trackId', (req: Request, res: Response) => {
  const { id, trackId } = req.params;
  try {
    dbData.playlist_tracks = dbData.playlist_tracks.filter(t => !(t.playlist_id === id && t.source_id === trackId));
    
    const playlist = dbData.playlists.find(p => p.id === id);
    if (playlist) playlist.updated_at = new Date().toISOString();

    saveDb();
    return res.json(success(null));
  } catch (err: any) {
    logger.error(`Remove track error: ${err.message}`);
    return res.status(500).json(fail('Failed to remove track'));
  }
});

playlistRouter.patch('/:id/tracks/reorder', (req: Request, res: Response) => {
  const { id } = req.params;
  const schema = z.object({
    orderedTrackIds: z.array(z.string()),
  });

  const parsed = schema.safeParse(req.body);
  if (!parsed.success) {
    return res.status(400).json(fail('Invalid order data'));
  }

  const { orderedTrackIds } = parsed.data;

  try {
    orderedTrackIds.forEach((sourceId, index) => {
        const track = dbData.playlist_tracks.find(t => t.playlist_id === id && t.source_id === sourceId);
        if (track) track.position = index;
    });

    const playlist = dbData.playlists.find(p => p.id === id);
    if (playlist) playlist.updated_at = new Date().toISOString();

    saveDb();
    return res.json(success(null));
  } catch (err: any) {
    logger.error(`Reorder tracks error: ${err.message}`);
    return res.status(500).json(fail('Failed to reorder tracks'));
  }
});

function mapTrackRow(row: any) {
  return {
    id: row.id,
    sourceId: row.source_id,
    title: row.title,
    artist: row.artist,
    album: row.album,
    thumbnailUrl: row.thumbnail_url,
    duration: row.duration,
    source: row.source,
  };
}
