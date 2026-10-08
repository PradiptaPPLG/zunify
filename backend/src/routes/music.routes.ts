import { Router, Request, Response } from 'express';
import { z } from 'zod';
import * as ytdlp from '../services/ytdlp.service';
import { searchCache, metadataCache, trendingCache, streamCache } from '../cache/cache';
import { logger } from '../utils/logger';

export const musicRouter = Router();

function success(data: unknown, pagination?: unknown) {
  return { success: true, data, ...(pagination ? { pagination } : {}) };
}

function fail(message: string) {
  return { success: false, data: null, message };
}

// ─── Search ───────────────────────────────────────────────────────────────────

const searchSchema = z.object({
  q: z.string().min(1).max(200),
  page: z.coerce.number().int().min(1).default(1),
});

musicRouter.get('/search', async (req: Request, res: Response) => {
  const parsed = searchSchema.safeParse(req.query);
  if (!parsed.success) {
    return res.status(400).json(fail('Invalid search query'));
  }

  const { q, page } = parsed.data;
  const cacheKey = `search:${q}:${page}`;
  const cached = searchCache.get(cacheKey);
  if (cached) {
    return res.json(cached);
  }

  try {
    const limit = 20;
    const results = await ytdlp.searchMusic(q, limit);

    const normalized = results.map((r) => ({
      id: r.id,
      title: r.title,
      artist: r.uploader,
      thumbnailUrl: r.thumbnailUrl,
      duration: r.duration,
      source: r.source,
      sourceId: r.id,
      available: true,
    }));

    const response = success(
      { results: normalized },
      {
        page,
        hasNextPage: results.length >= limit,
        nextCursor: null,
      },
    );

    searchCache.set(cacheKey, response);
    return res.json(response);
  } catch (err: any) {
    logger.error(`Search error: ${err.message}`);
    return res.status(500).json(fail('Search service temporarily unavailable'));
  }
});

// ─── Track metadata ───────────────────────────────────────────────────────────

musicRouter.get('/tracks/:id', async (req: Request, res: Response) => {
  const { id } = req.params;
  if (!id || !/^[a-zA-Z0-9_-]{8,16}$/.test(id)) {
    return res.status(400).json(fail('Invalid track ID'));
  }

  const cached = metadataCache.get(id);
  if (cached) return res.json(success(cached));

  try {
    const info = await ytdlp.getTrackMetadata(id);
    const track = {
      id: info.id,
      title: info.title,
      artist: info.uploader,
      thumbnailUrl: info.thumbnailUrl,
      duration: info.duration,
      source: 'youtube',
      sourceId: info.id,
      available: true,
    };
    metadataCache.set(id, track);
    return res.json(success(track));
  } catch (err: any) {
    logger.error(`Metadata error for ${id}: ${err.message}`);
    return res.status(404).json(fail('Track unavailable'));
  }
});

// ─── Stream URL ───────────────────────────────────────────────────────────────

import https from 'https';

musicRouter.get('/tracks/:id/stream', async (req: Request, res: Response) => {
  const { id } = req.params;
  if (!id || !/^[a-zA-Z0-9_-]{8,16}$/.test(id)) {
    return res.status(400).json(fail('Invalid track ID'));
  }

  // Pre-fetch and cache the actual google video URL
  try {
    let streamUrl = streamCache.get<{ url: string }>(id)?.url;
    if (!streamUrl) {
      const dataSaver = req.query.dataSaver === 'true';
      const stream = await ytdlp.resolveStreamUrl(id, dataSaver);
      streamUrl = stream.url;
      streamCache.set(id, { url: streamUrl });
    }
    
    // Return the direct youtube URL for better streaming performance.
    // (HTML5 <audio> does not require CORS for basic playback)
    return res.json(success({ url: streamUrl }));
  } catch (err: any) {
    logger.error(`Stream error for ${id}: ${err.message}`);
    return res.status(503).json(fail('This track is currently unavailable'));
  }
});

musicRouter.get('/proxy/:id', async (req: Request, res: Response) => {
  const { id } = req.params;
  try {
    let streamUrl = streamCache.get<{ url: string }>(id)?.url;
    if (!streamUrl) {
      const stream = await ytdlp.resolveStreamUrl(id, false);
      streamUrl = stream.url;
      streamCache.set(id, { url: streamUrl });
    }

    const options = {
      headers: {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)',
        ...(req.headers.range ? { 'Range': req.headers.range } : {})
      }
    };

    https.get(streamUrl, options, (streamRes) => {
      // Forward all relevant headers including Content-Range and Content-Type
      const headers = { ...streamRes.headers };
      headers['access-control-allow-origin'] = '*';
      headers['access-control-allow-methods'] = 'GET, HEAD, OPTIONS';
      headers['access-control-allow-headers'] = 'Origin, X-Requested-With, Content-Type, Accept, Range';
      headers['access-control-expose-headers'] = 'Content-Length, Content-Range';
      res.writeHead(streamRes.statusCode || 200, headers);
      streamRes.pipe(res);
    }).on('error', (err) => {
      logger.error(`Proxy stream error: ${err.message}`);
      res.status(500).end();
    });
  } catch (err: any) {
    logger.error(`Proxy setup error: ${err.message}`);
    res.status(500).end();
  }
});

// ─── Trending ─────────────────────────────────────────────────────────────────

musicRouter.get('/trending', async (_req: Request, res: Response) => {
  const cached = trendingCache.get('trending');
  if (cached) return res.json(success(cached));

  try {
    const results = await ytdlp.getTrending();
    const normalized = results.map((r) => ({
      id: r.id,
      title: r.title,
      artist: r.uploader,
      thumbnailUrl: r.thumbnailUrl,
      duration: r.duration,
      source: r.source,
      sourceId: r.id,
      available: true,
    }));
    trendingCache.set('trending', normalized);
    return res.json(success(normalized));
  } catch (err: any) {
    logger.error(`Trending error: ${err.message}`);
    return res.status(500).json(fail('Trending unavailable'));
  }
});
