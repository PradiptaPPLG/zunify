import dotenv from 'dotenv';
dotenv.config();
import express from 'express';
import cors from 'cors';
import morgan from 'morgan';
import rateLimit from 'express-rate-limit';
import { initDb } from './db/database';
import { musicRouter } from './routes/music.routes';
import { playlistRouter } from './routes/playlist.routes';
import { favoritesRouter, historyRouter } from './routes/library.routes';
import { logger } from './utils/logger';

const app = express();
const PORT = process.env.PORT || 3000;

// Initialize SQLite DB
initDb();

// Middlewares
app.use(cors());
app.use(express.json());
app.use(
  morgan('short', {
    stream: { write: (message) => logger.http(message.trim()) },
  }),
);

// Rate Limiting
const limiter = rateLimit({
  windowMs: parseInt(process.env.RATE_LIMIT_WINDOW_MS || '60000'), // 1 minute
  max: parseInt(process.env.RATE_LIMIT_MAX_REQUESTS || '60'), // limit each IP to 60 requests per windowMs
  message: { success: false, data: null, message: 'Too many requests, please try again later.' },
  standardHeaders: true,
  legacyHeaders: false,
});
app.use((req, res, next) => {
  if (req.path.startsWith('/api/proxy/')) return next();
  limiter(req, res, next);
});

// Routes
app.use('/api', musicRouter);
app.use('/api/playlists', playlistRouter);
app.use('/api/favorites', favoritesRouter);
app.use('/api/history', historyRouter);

// Error Handling (catch-all)
app.use((err: any, _req: express.Request, res: express.Response, _next: express.NextFunction) => {
  logger.error(`Unhandled error: ${err.stack}`);
  res.status(500).json({ success: false, data: null, message: 'Internal Server Error' });
});

// Start Server
app.listen(PORT, () => {
  logger.info(`Zunify backend listening at http://localhost:${PORT}`);
});
