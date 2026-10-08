import NodeCache from 'node-cache';

// Search cache: 5 minutes
export const searchCache = new NodeCache({
  stdTTL: parseInt(process.env.CACHE_TTL_SEARCH || '300'),
  checkperiod: 60,
});

// Metadata cache: 1 hour
export const metadataCache = new NodeCache({
  stdTTL: parseInt(process.env.CACHE_TTL_METADATA || '3600'),
  checkperiod: 120,
});

// Trending cache: 10 minutes
export const trendingCache = new NodeCache({
  stdTTL: parseInt(process.env.CACHE_TTL_TRENDING || '600'),
  checkperiod: 60,
});

// Stream URL cache: 4 hours (URLs expire, so keep short-ish)
export const streamCache = new NodeCache({
  stdTTL: 14400,
  checkperiod: 300,
});
