import { Router, Request, Response } from 'express';
import { v4 as uuidv4 } from 'uuid';
import { z } from 'zod';
import { dbData, saveDb } from '../db/database';
import { logger } from '../utils/logger';

export const favoritesRouter = Router();
export const historyRouter = Router();

function success(data: unknown) {
  return { success: true, data };
}

function fail(message: string) {
  return { success: false, data: null, message };
}

const trackSchema = z.object({
  sourceId: z.string(),
  title: z.string(),
  artist: z.string(),
  album: z.string().nullable().optional(),
  thumbnailUrl: z.string().nullable().optional(),
  duration: z.number().nullable().optional(),
  source: z.string().default('youtube'),
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

// ─── Favorites ────────────────────────────────────────────────────────────────

favoritesRouter.get('/', (_req: Request, res: Response) => {
  try {
    const tracks = [...dbData.favorites]
      .sort((a, b) => new Date(b.added_at).getTime() - new Date(a.added_at).getTime())
      .map(mapTrackRow);
    return res.json(success(tracks));
  } catch (err: any) {
    logger.error(`Get favorites error: ${err.message}`);
    return res.status(500).json(fail('Failed to load favorites'));
  }
});

favoritesRouter.post('/:trackId', (req: Request, res: Response) => {
  const parsed = trackSchema.safeParse(req.body);
  if (!parsed.success) {
    return res.status(400).json(fail('Invalid track data'));
  }

  const t = parsed.data;
  const id = uuidv4();

  try {
    // Remove if exists to replace
    dbData.favorites = dbData.favorites.filter(f => f.source_id !== t.sourceId);

    dbData.favorites.push({
      id,
      source_id: t.sourceId,
      title: t.title,
      artist: t.artist,
      album: t.album || null,
      thumbnail_url: t.thumbnailUrl || null,
      duration: t.duration || null,
      source: t.source,
      added_at: new Date().toISOString()
    });
    
    saveDb();
    return res.json(success(null));
  } catch (err: any) {
    logger.error(`Add favorite error: ${err.message}`);
    return res.status(500).json(fail('Failed to add favorite'));
  }
});

favoritesRouter.delete('/:trackId', (req: Request, res: Response) => {
  const { trackId } = req.params;
  try {
    dbData.favorites = dbData.favorites.filter(f => f.source_id !== trackId);
    saveDb();
    return res.json(success(null));
  } catch (err: any) {
    logger.error(`Remove favorite error: ${err.message}`);
    return res.status(500).json(fail('Failed to remove favorite'));
  }
});

// ─── History ──────────────────────────────────────────────────────────────────

historyRouter.get('/', (req: Request, res: Response) => {
  const limit = parseInt(req.query.limit as string) || 50;
  try {
    const rows = [...dbData.play_history]
      .sort((a, b) => new Date(b.played_at).getTime() - new Date(a.played_at).getTime())
      .slice(0, limit);
    
    const results = rows.map((r: any) => ({
      playedAt: r.played_at,
      track: mapTrackRow(r),
    }));

    return res.json(success(results));
  } catch (err: any) {
    logger.error(`Get history error: ${err.message}`);
    return res.status(500).json(fail('Failed to load history'));
  }
});

historyRouter.post('/', (req: Request, res: Response) => {
  const parsed = trackSchema.safeParse(req.body);
  if (!parsed.success) {
    return res.status(400).json(fail('Invalid track data'));
  }

  const t = parsed.data;
  const id = uuidv4();

  try {
    dbData.play_history.push({
      id,
      source_id: t.sourceId,
      title: t.title,
      artist: t.artist,
      album: t.album || null,
      thumbnail_url: t.thumbnailUrl || null,
      duration: t.duration || null,
      source: t.source,
      played_at: new Date().toISOString()
    });
    
    saveDb();
    return res.json(success(null));
  } catch (err: any) {
    logger.error(`Add history error: ${err.message}`);
    return res.status(500).json(fail('Failed to add history'));
  }
});

historyRouter.delete('/', (_req: Request, res: Response) => {
  try {
    dbData.play_history = [];
    saveDb();
    return res.json(success(null));
  } catch (err: any) {
    logger.error(`Clear history error: ${err.message}`);
    return res.status(500).json(fail('Failed to clear history'));
  }
});
