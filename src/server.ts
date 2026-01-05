// src/server.ts

// Main server file to set up Express app and routes
import express from "express";
import dotenv from "dotenv";
import cors from "cors";

// Database connection
import { connectDB } from "./config/db";

// Route imports
import authRoutes from "./routes/authRoutes";
import categoryRoutes from "./routes/categoryRoutes";
import transactionRoutes from "./routes/transactionRoutes";

// Load environment variables and connect to database
dotenv.config();
connectDB();

const PORT = Number(process.env.PORT) || 5000;


// Initialize Express app
const app = express();
app.use(cors());
app.use(express.json());

// Response time logging middleware
app.use((req, res, next) => {
  const start = Date.now();
  res.on('finish', () => {
    const duration = Date.now() - start;
    if (duration > 500) { // Log only slow requests (>500ms)
      console.warn(`[SLOW REQUEST] ${req.method} ${req.originalUrl} - ${duration}ms`);
    }
  });
  next();
});

// Define routes
app.get("/", (_, res) => res.send("API Running"));

// Use imported routes
app.use("/api/auth", authRoutes);
app.use("/api/categories", categoryRoutes);
app.use("/api/transactions", transactionRoutes);


// Start server
app.listen(PORT, () =>
  console.log(`Server running on port ${PORT}`)
);
