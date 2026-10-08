/// JSON based database since better-sqlite3 failed to build
import path from 'path';
import fs from 'fs';
import { logger } from '../utils/logger';

const DB_PATH = process.env.DB_PATH || './data/zunify.json';
const dbDir = path.dirname(DB_PATH);

if (!fs.existsSync(dbDir)) {
  fs.mkdirSync(dbDir, { recursive: true });
}

export let dbData = {
  playlists: [] as any[],
  playlist_tracks: [] as any[],
  favorites: [] as any[],
  play_history: [] as any[]
};

export function initDb(): void {
  if (fs.existsSync(DB_PATH)) {
    try {
      const data = fs.readFileSync(DB_PATH, 'utf-8');
      dbData = JSON.parse(data);
      logger.info(`Database loaded from ${DB_PATH}`);
    } catch (err: any) {
      logger.error(`Failed to read database: ${err.message}`);
    }
  } else {
    saveDb();
    logger.info(`Database initialized at ${DB_PATH}`);
  }
}

export function saveDb(): void {
  fs.writeFileSync(DB_PATH, JSON.stringify(dbData, null, 2), 'utf-8');
}
