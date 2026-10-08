/// yt-dlp wrapper service — search, metadata, stream resolution.
import { exec } from 'child_process';
import { promisify } from 'util';
import { logger } from '../utils/logger';

const execAsync = promisify(exec);

const YTDLP = process.env.YTDLP_PATH || 'yt-dlp';
const TIMEOUT_MS = 30000;

export interface YtdlpSearchResult {
  id: string;
  title: string;
  uploader: string;
  duration: number;
  thumbnailUrl: string;
  source: 'youtube';
}

export interface YtdlpTrackInfo {
  id: string;
  title: string;
  uploader: string;
  duration: number;
  thumbnailUrl: string;
  description?: string;
  uploadDate?: string;
}

export interface YtdlpStreamInfo {
  url: string;
  ext: string;
  quality?: string;
}

async function runYtdlp(args: string[]): Promise<string> {
  const cmd = `${YTDLP} ${args.join(' ')}`;
  try {
    const { stdout } = await execAsync(cmd, {
      timeout: TIMEOUT_MS,
      maxBuffer: 10 * 1024 * 1024,
    });
    return stdout;
  } catch (err: any) {
    logger.error(`yt-dlp error: ${err.message}`);
    throw new Error(`yt-dlp failed: ${err.stderr || err.message}`);
  }
}

/**
 * Search YouTube Music for tracks.
 * Uses ytsearch: prefix for standard search.
 */
export async function searchMusic(
  query: string,
  limit = 20,
): Promise<YtdlpSearchResult[]> {
  try {
    const args = [
      `"ytsearch${limit}:${query}"`,
      '--dump-json',
      '--no-playlist',
      '--skip-download',
      '--no-warnings',
      '--flat-playlist',
      '--match-filter',
      '"!is_live"',
    ];

    const output = await runYtdlp(args);
    const lines = output.trim().split('\n').filter((l) => l.trim());

    return lines.map((line) => {
      const data = JSON.parse(line);
      return normalizeSearchResult(data);
    });
  } catch (err: any) {
    logger.error(`Search failed: ${err.message}`);
    throw err;
  }
}

/**
 * Get track metadata by YouTube video ID.
 */
export async function getTrackMetadata(
  videoId: string,
): Promise<YtdlpTrackInfo> {
  const args = [
    `"https://www.youtube.com/watch?v=${videoId}"`,
    '--dump-json',
    '--no-playlist',
    '--skip-download',
    '--no-warnings',
  ];

  const output = await runYtdlp(args);
  const data = JSON.parse(output.trim().split('\n')[0]);
  return normalizeTrackInfo(data);
}

/**
 * Resolve audio stream URL for a video ID.
 * Requests best audio-only stream.
 */
export async function resolveStreamUrl(
  videoId: string,
  dataSaver = false,
): Promise<YtdlpStreamInfo> {
  const format = dataSaver
    ? 'bestaudio[abr<=64]/worstaudio'
    : 'bestaudio/best';

  const args = [
    `"https://www.youtube.com/watch?v=${videoId}"`,
    `--format "${format}"`,
    '--get-url',
    '--no-playlist',
    '--no-warnings',
  ];

  const url = (await runYtdlp(args)).trim();
  if (!url || !url.startsWith('http')) {
    throw new Error('Stream URL not available');
  }
  return { url, ext: 'webm' };
}

/**
 * Get trending / popular music via YouTube Music charts.
 * Falls back to searching for popular tracks if chart extraction fails.
 */
export async function getTrending(): Promise<YtdlpSearchResult[]> {
  // Trending via YouTube Music "New releases" or top searches
  // We use a curated popular search as trending source
  try {
    return await searchMusic('trending music 2024', 16);
  } catch {
    return searchMusic('popular songs', 16);
  }
}

// ─── Normalizers ──────────────────────────────────────────────────────────────

function normalizeSearchResult(data: any): YtdlpSearchResult {
  return {
    id: data.id || data.webpage_url_basename || '',
    title: data.title || 'Unknown Title',
    uploader: data.uploader || data.channel || data.creator || 'Unknown Artist',
    duration: typeof data.duration === 'number' ? Math.round(data.duration) : 0,
    thumbnailUrl: getBestThumbnail(data),
    source: 'youtube',
  };
}

function normalizeTrackInfo(data: any): YtdlpTrackInfo {
  return {
    id: data.id || '',
    title: data.title || 'Unknown Title',
    uploader: data.uploader || data.channel || 'Unknown Artist',
    duration: typeof data.duration === 'number' ? Math.round(data.duration) : 0,
    thumbnailUrl: getBestThumbnail(data),
    description: data.description,
    uploadDate: data.upload_date,
  };
}

function getBestThumbnail(data: any): string {
  if (data.thumbnails && Array.isArray(data.thumbnails)) {
    // Prefer ~540px width thumbnails (good quality, not too large)
    const sorted = [...data.thumbnails].sort(
      (a, b) => (b.width || 0) - (a.width || 0),
    );
    const preferred = sorted.find(
      (t) => t.width && t.width <= 720 && t.url,
    );
    if (preferred?.url) return preferred.url;
    if (sorted[0]?.url) return sorted[0].url;
  }
  if (data.thumbnail) return data.thumbnail;
  return `https://i.ytimg.com/vi/${data.id}/mqdefault.jpg`;
}
