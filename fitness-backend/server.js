require('dotenv').config();
const express = require('express');
const cors = require('cors');
const { MongoClient, ServerApiVersion } = require('mongodb');

const app = express();
const PORT = process.env.PORT || 3000;

// Dev mode: use in-memory store when MONGODB_URI is not set (e.g. local dev without MongoDB)
const DEV_MODE = !process.env.MONGODB_URI;
if (DEV_MODE) {
  console.log('⚠️  Running in DEV mode (no MONGODB_URI). Data is in-memory only and will be lost on restart.');
}

// Middleware
app.use(cors());
app.use(express.json());

let db;
let client = null;

// ---------- In-memory store for dev mode ----------
function createInMemoryStore() {
  const stores = {
    users: [],
    fitness_metrics: [],
    workouts: [],
    devices: []
  };
  let idCounter = 0;
  function nextId() {
    idCounter += 1;
    return `dev_${idCounter}_${Date.now()}`;
  }
  function match(doc, query) {
    if (!doc || !query) return true;
    for (const [key, value] of Object.entries(query)) {
      if (value && typeof value === 'object' && !Array.isArray(value) && value.$gte !== undefined) {
        if (doc[key] < value.$gte) return false;
      } else if (doc[key] !== value) {
        return false;
      }
    }
    return true;
  }
  function createCollection(name) {
    const list = stores[name] || (stores[name] = []);
    return {
      findOne: async (query) => list.find((d) => match(d, query)) || null,
      find: (query) => ({
        sort: (sortObj) => {
          const run = async (limitCount) => {
            let out = list.filter((d) => match(d, query));
            const key = Object.keys(sortObj)[0];
            const desc = sortObj[key] === -1;
            out.sort((a, b) => (a[key] > b[key] ? (desc ? -1 : 1) : (desc ? 1 : -1)));
            return limitCount != null ? out.slice(0, limitCount) : out;
          };
          return {
            limit: (n) => ({ toArray: () => run(n) }),
            toArray: () => run(null)
          };
        }
      }),
      insertOne: async (doc) => {
        const _id = nextId();
        const newDoc = { ...doc, _id };
        list.push(newDoc);
        return { insertedId: _id };
      },
      findOneAndUpdate: async (filter, updateDoc, options) => {
        const idx = list.findIndex((d) => match(d, filter));
        if (idx === -1) return null;
        const set = updateDoc.$set || updateDoc;
        list[idx] = { ...list[idx], ...set };
        return options?.returnDocument === 'after' ? list[idx] : list[idx];
      },
      deleteOne: async (filter) => {
        const idx = list.findIndex((d) => match(d, filter));
        if (idx === -1) return { deletedCount: 0 };
        list.splice(idx, 1);
        return { deletedCount: 1 };
      },
      deleteMany: async (filter) => {
        const before = list.length;
        for (let i = list.length - 1; i >= 0; i--) {
          if (match(list[i], filter)) list.splice(i, 1);
        }
        return { deletedCount: before - list.length };
      }
    };
  }
  return {
    collection: (name) => createCollection(name)
  };
}

// Connect to MongoDB (or use in-memory store in dev)
async function connectDB() {
  if (DEV_MODE) {
    db = createInMemoryStore();
    console.log('✅ Using in-memory store (dev mode)');
    return;
  }
  const uri = process.env.MONGODB_URI;
  client = new MongoClient(uri, {
    serverApi: {
      version: ServerApiVersion.v1,
      strict: true,
      deprecationErrors: true,
    }
  });
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
    
    // Add default privacy preferences if not provided
    if (!userData.privacyPreferences) {
      userData.privacyPreferences = {
        shareActivityData: true,
        allowAnalytics: false,
        shareWorkoutData: true,
        allowAIInsights: true
      };
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
    
    // Remove fields that should NOT be updated
    delete updates._id;           // MongoDB internal ID - immutable
    delete updates.id;            // Alternative ID field
    delete updates.firebaseUid;   // User identifier - immutable
    delete updates.createdAt;     // Creation timestamp - immutable
    
    // Add updated timestamp
    updates.updatedAt = new Date();
    
    console.log(`Updating user ${authId} with:`, JSON.stringify(updates, null, 2));
    
    const result = await db.collection('users').findOneAndUpdate(
      { firebaseUid: authId },
      { $set: updates },
      { returnDocument: 'after' }
    );
    
    if (!result) {
      console.error(`User not found: ${authId}`);
      return res.status(404).json({ error: 'User not found' });
    }
    
    console.log(`✅ User ${authId} updated successfully`);
    res.json(serializeUser(result));
  } catch (error) {
    console.error('Error updating user:', error);
    console.error('Error stack:', error.stack);
    res.status(500).json({ 
      error: 'Internal server error',
      message: error.message // Include error details for debugging
    });
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

// DELETE /v1/users/:authId - Delete user and all related data (GDPR compliance)
app.delete('/v1/users/:authId', async (req, res) => {
  try {
    const { authId } = req.params;
    
    console.log(`🗑️ Deleting user account: ${authId}`);
    
    // Delete user's fitness metrics
    const metricsResult = await db.collection('fitness_metrics').deleteMany({ userId: authId });
    console.log(`  ├─ Deleted ${metricsResult.deletedCount} fitness metrics`);
    
    // Delete user's workouts
    const workoutsResult = await db.collection('workouts').deleteMany({ userId: authId });
    console.log(`  ├─ Deleted ${workoutsResult.deletedCount} workouts`);
    
    // Delete user's devices
    const devicesResult = await db.collection('devices').deleteMany({ userId: authId });
    console.log(`  ├─ Deleted ${devicesResult.deletedCount} devices`);
    
    // Delete user
    const userResult = await db.collection('users').deleteOne({ firebaseUid: authId });
    
    if (userResult.deletedCount === 0) {
      return res.status(404).json({ error: 'User not found' });
    }
    
    console.log(`  └─ ✅ User account deleted successfully`);
    res.status(200).json({ 
      message: 'User account and all related data deleted successfully',
      deleted: {
        user: 1,
        metrics: metricsResult.deletedCount,
        workouts: workoutsResult.deletedCount,
        devices: devicesResult.deletedCount
      }
    });
  } catch (error) {
    console.error('Error deleting user:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// GET /v1/users/:authId/export - Export all user data (GDPR compliance)
app.get('/v1/users/:authId/export', async (req, res) => {
  try {
    const { authId } = req.params;
    
    console.log(`📦 Exporting data for user: ${authId}`);
    
    // Fetch user
    const user = await db.collection('users').findOne({ firebaseUid: authId });
    
    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }
    
    // Fetch all related data
    const metrics = await db.collection('fitness_metrics')
      .find({ userId: authId })
      .sort({ date: -1 })
      .toArray();
    
    const workouts = await db.collection('workouts')
      .find({ userId: authId })
      .sort({ startDate: -1 })
      .toArray();
    
    const devices = await db.collection('devices')
      .find({ userId: authId })
      .sort({ lastActive: -1 })
      .toArray();
    
    // Create export package
    const exportData = {
      exportDate: new Date().toISOString(),
      user: serializeUser(user),
      fitnessMetrics: metrics,
      workouts: workouts,
      devices: devices,
      summary: {
        totalMetrics: metrics.length,
        totalWorkouts: workouts.length,
        totalDevices: devices.length,
        memberSince: user.createdAt
      }
    };
    
    console.log(`  ✅ Exported ${metrics.length} metrics, ${workouts.length} workouts, ${devices.length} devices`);
    
    res.json(exportData);
  } catch (error) {
    console.error('Error exporting user data:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// GET /v1/users/:authId/devices - Get all devices for user
app.get('/v1/users/:authId/devices', async (req, res) => {
  try {
    const { authId } = req.params;
    
    const devices = await db.collection('devices')
      .find({ userId: authId })
      .sort({ lastActive: -1 })
      .toArray();
    
    res.json({ data: devices, count: devices.length });
  } catch (error) {
    console.error('Error fetching devices:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// POST /v1/users/:authId/devices - Register a new device
app.post('/v1/users/:authId/devices', async (req, res) => {
  try {
    const { authId } = req.params;
    const deviceData = req.body;
    
    // Ensure userId matches authId
    deviceData.userId = authId;
    deviceData.createdAt = new Date();
    deviceData.updatedAt = new Date();
    deviceData.lastActive = new Date();
    
    // Check if device already exists
    const existing = await db.collection('devices').findOne({ 
      userId: authId, 
      deviceId: deviceData.deviceId 
    });
    
    if (existing) {
      // Update existing device
      const result = await db.collection('devices').findOneAndUpdate(
        { userId: authId, deviceId: deviceData.deviceId },
        { $set: { lastActive: new Date(), updatedAt: new Date() } },
        { returnDocument: 'after' }
      );
      return res.json(result);
    }
    
    // Insert new device
    const result = await db.collection('devices').insertOne(deviceData);
    const newDevice = await db.collection('devices').findOne({ 
      _id: result.insertedId 
    });
    
    res.status(201).json(newDevice);
  } catch (error) {
    console.error('Error registering device:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// PUT /v1/users/:authId/devices/:deviceId - Update device
app.put('/v1/users/:authId/devices/:deviceId', async (req, res) => {
  try {
    const { authId, deviceId } = req.params;
    const updates = req.body;
    
    // Remove immutable fields
    delete updates._id;
    delete updates.id;
    delete updates.userId;
    delete updates.deviceId;
    delete updates.createdAt;
    
    updates.updatedAt = new Date();
    updates.lastActive = new Date();
    
    const result = await db.collection('devices').findOneAndUpdate(
      { userId: authId, deviceId: deviceId },
      { $set: updates },
      { returnDocument: 'after' }
    );
    
    if (!result) {
      return res.status(404).json({ error: 'Device not found' });
    }
    
    res.json(result);
  } catch (error) {
    console.error('Error updating device:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// DELETE /v1/users/:authId/devices/:deviceId - Remove device
app.delete('/v1/users/:authId/devices/:deviceId', async (req, res) => {
  try {
    const { authId, deviceId } = req.params;
    
    const result = await db.collection('devices').deleteOne({ 
      userId: authId, 
      deviceId: deviceId 
    });
    
    if (result.deletedCount === 0) {
      return res.status(404).json({ error: 'Device not found' });
    }
    
    res.status(200).json({ message: 'Device removed successfully' });
  } catch (error) {
    console.error('Error removing device:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// DELETE /v1/users/:authId/devices - Remove all devices (sign out all)
app.delete('/v1/users/:authId/devices', async (req, res) => {
  try {
    const { authId } = req.params;
    
    const result = await db.collection('devices').deleteMany({ userId: authId });
    
    res.status(200).json({ 
      message: 'All devices removed successfully',
      deletedCount: result.deletedCount
    });
  } catch (error) {
    console.error('Error removing all devices:', error);
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
  if (client) {
    console.log('\n🔌 Closing MongoDB connection...');
    await client.close();
  }
  process.exit(0);
});

