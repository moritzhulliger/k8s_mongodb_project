const express = require('express');
const { MongoClient } = require('mongodb');

const app = express();
const port = 3000;

const url = process.env.MONGO_URL || "mongodb://localhost:27017";
const client = new MongoClient(url);

app.get('/', async (req, res) => {
  try {
    await client.connect();
    const db = client.db("test");
    const collection = db.collection("items");
    const items = await collection.find({}).toArray();
    res.json(items);
  } catch (e) {
    res.status(500).send(e.message);
  }
});

app.listen(port, () => {
  console.log(`Webapp listening at http://localhost:${port}`);
});
