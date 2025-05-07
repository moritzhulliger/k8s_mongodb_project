const express = require('express');
const { MongoClient } = require('mongodb');

const app = express();
const port = 3000;

const url = process.env.MONGO_URL || "mongodb://localhost:27017";
const client = new MongoClient(url);

app.get('/', async (req, res) => {
  try {
    await client.connect();
    const db = client.db('moviesdb'); 
    const collection = db.collection('movies');
    const items = await collection.find({}).toArray();
    res.json(items);
  } catch (e) {
    res.status(500).send(e.message);
  }
});

app.get('/movies/add', async (req, res) => {
  const title = req.query.title;

  if(title) {
    try {
      await client.connect();
      const db = client.db('moviesdb'); 
      const collection = db.collection('movies');
      const result = await collection.insertOne({ title });
      const items = await collection.find({}).toArray();
      res.json(items);
    } catch (e) {
      res.status(500).send(e.message);
    }
  } else {
    res.send("Add a movie with the ?title query parameter")
  }
});

app.listen(port, () => {
  console.log(`Webapp listening at http://localhost:${port}`);
});
