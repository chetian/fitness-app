require('dotenv').config();
const express = require('express');
const cors = require('cors');
const { MongoClient, ServerApiVersion } = require('mongodb');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());

// MongoDB Connection
const uri = process.env.MONGODB_URI;
const client = new MongoClient(uri, {
  serverApi: {
    version: ServerApiVersion.v1,
    strict: true,
    deprecationErrors: true,
  }
});

let db;

// Connect to MongoDB
async function connectDB() {
  try {
    await client.connect();
    db = client.db('fitness_app');
    console.log('✅ Connected to MongoDB Atlas');
  } catch (error) {
    console.error('❌ MongoDB connection error:', error);
    process.exit(1);
  }
}

// Helper to serialize MongoDB documents
function serializeUser(user) {
  if (!user) return null;
  const serialized = {
    ...user,
    _id: user._id.toString() // Convert ObjectId to string
  };
  // Remove the 'id' field if it exists to avoid confusion
  delete serialized.id;
  return serialized;
}

// Routes

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'ok', message: 'FitnessApp API is running' });
});

// GET /v1/users/:authId - Get user by Firebase UID
app.get('/v1/users/:authId', async (req, res) => {
  try {
    const { authId } = req.params;
    const user = await db.collection('users').findOne({ firebaseUid: authId });
    
    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }
    
    res.json(serializeUser(user));
  } catch (error) {
    console.error('Error fetching user:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// POST /v1/users - Create new user
app.post('/v1/users', async (req, res) => {
  try {
    const userData = req.body;
    
    // Remove _id field if present (MongoDB will auto-generate it)
    // This handles cases where client sends empty string or any invalid _id
    delete userData._id;
    delete userData.id;
    
    // Check if user already exists
    const existing = await db.collection('users').findOne({ 
      firebaseUid: userData.firebaseUid 
    });
    
    if (existing) {
      return res.status(409).json({ error: 'User already exists' });
    }
    
    // Add timestamps
    userData.createdAt = new Date();
    userData.updatedAt = new Date();
    
    // Insert user
    const result = await db.collection('users').insertOne(userData);
    
    // Return created user with _id field
    const newUser = await db.collection('users').findOne({ 
      _id: result.insertedId 
    });
    
    res.status(201).json(serializeUser(newUser));
  } catch (error) {
    console.error('Error creating user:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// PUT /v1/users/:authId - Update user
app.put('/v1/users/:authId', async (req, res) => {
  try {
    const { authId } = req.params;
    const updates = req.body;
    
    // Add updated timestamp
    updates.updatedAt = new Date();
    
    const result = await db.collection('users').findOneAndUpdate(
      { firebaseUid: authId },
      { $set: updates },
      { returnDocument: 'after' }
    );
    
    if (!result) {
      return res.status(404).json({ error: 'User not found' });
    }
    
    res.json(serializeUser(result));
  } catch (error) {
    console.error('Error updating user:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// POST /v1/fitness-metrics - Create fitness metrics
app.post('/v1/fitness-metrics', async (req, res) => {
  try {
    const metricsData = req.body;
    metricsData.createdAt = new Date();
    
    const result = await db.collection('fitness_metrics').insertOne(metricsData);
    const newMetrics = await db.collection('fitness_metrics').findOne({ 
      _id: result.insertedId 
    });
    
    res.status(201).json(newMetrics);
  } catch (error) {
    console.error('Error creating fitness metrics:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// GET /v1/fitness-metrics/:userId - Get fitness metrics for user
app.get('/v1/fitness-metrics/:userId', async (req, res) => {
  try {
    const { userId } = req.params;
    const days = parseInt(req.query.days) || 7;
    
    const startDate = new Date();
    startDate.setDate(startDate.getDate() - days);
    
    const metrics = await db.collection('fitness_metrics')
      .find({ 
        userId: userId,
        date: { $gte: startDate }
      })
      .sort({ date: -1 })
      .toArray();
    
    res.json(metrics);
  } catch (error) {
    console.error('Error fetching fitness metrics:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// POST /v1/workouts - Create workout
app.post('/v1/workouts', async (req, res) => {
  try {
    const workoutData = req.body;
    workoutData.createdAt = new Date();
    
    const result = await db.collection('workouts').insertOne(workoutData);
    const newWorkout = await db.collection('workouts').findOne({ 
      _id: result.insertedId 
    });
    
    res.status(201).json(newWorkout);
  } catch (error) {
    console.error('Error creating workout:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// GET /v1/workouts/:userId - Get workouts for user
app.get('/v1/workouts/:userId', async (req, res) => {
  try {
    const { userId } = req.params;
    const limit = parseInt(req.query.limit) || 50;
    
    const workouts = await db.collection('workouts')
      .find({ userId: userId })
      .sort({ startDate: -1 })
      .limit(limit)
      .toArray();
    
    res.json(workouts);
  } catch (error) {
    console.error('Error fetching workouts:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Start server
connectDB().then(() => {
  app.listen(PORT, () => {
    console.log(`🚀 FitnessApp Backend API running on http://localhost:${PORT}`);
    console.log(`📊 Health check: http://localhost:${PORT}/health`);
  });
});

// Graceful shutdown
process.on('SIGINT', async () => {
  console.log('\n🔌 Closing MongoDB connection...');
  await client.close();
  process.exit(0);
});

