import dotenv from 'dotenv';
dotenv.config();

import app from './app.js';
import connectDB from './config/db.js';
import { connectToRedis } from './services/redis.js';
import { PORT } from './config/utils.js';

console.log('🚀 Starting server...');

let server: any;

async function startServer() {
  try {
    console.log('📡 Connecting to databases...');
    await connectToRedis();
    await connectDB();

    const port = PORT || 3000;

    server = app.listen(port, () => {
      console.log(`✅ Server running on port ${port}`);
      console.log(`🔗 Backend URL: http://localhost:${port}`);
    });

    return server;
  } catch (error) {
    console.error('❌ Failed to start server:', error);
    process.exit(1);
  }
}

startServer();