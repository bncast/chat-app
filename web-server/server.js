const express = require('express');
const bodyParser = require('body-parser');
const path = require('path');

const Database = require('./config/database');
const UserController = require('./controllers/userController');
const RoomController = require('./controllers/roomController');
const RoomUserController = require('./controllers/roomUserController');
const MessageController = require('./controllers/messageController');

const app = express();
const db = new Database();
const userController = new UserController(db);
const roomController = new RoomController(db);
const roomUserController = new RoomUserController(db);
const messageController = new MessageController(db);

app.use(bodyParser.json())
app.use(bodyParser.urlencoded({ extended: true }))

const WAITING_TIME_LIMIT = 60 * 1000;
var waitingClients = []; // Store waiting client responses

app.get('/api/listen', (req, res) => {
  const { device_id, room_id } = req.query;
  
  waitingClients.push({ room_id, clientRes: res, timestamp: Date.now() });
});

app.post('/api/send', (req, res) => {
  const currentTime = Date.now();

  // Remove clients who have been waiting for more than 1 minute
  waitingClients = waitingClients.filter(client => {
    return (currentTime - client.timestamp) <= WAITING_TIME_LIMIT;
  });

  messageController.createMessage(req, res, (target) => {
    
    // Filter clients who belong to the target room
    const clientsToNotify = waitingClients.filter(client => client.room_id == target);

    // Notify all matching clients
    clientsToNotify.forEach(client => {
      client.clientRes.status(200).json({ success: 1 });
    });

    // Remove notified clients from the waiting list
    waitingClients = waitingClients.filter(client => client.room_id != target);
  });
});


app.post('/api/users', (req, res) => userController.setUser(req, res));
app.get('/api/users', (req, res) => userController.getUsers(req, res)); // need to retested during integration

app.get('/api/rooms', (req, res) => roomUserController.getChatRooms(req, res));
app.post('/api/rooms', (req, res) => roomController.create(req, res));
app.put('/api/rooms', (req, res) => console.log("TODO for editing name"));
app.delete('/api/rooms', (req, res) => console.log("TODO for deleting room"));

app.post('/api/rooms/join', (req, res) => roomUserController.joinRoom(req, res));

app.get('/api/messages', (req, res) => messageController.getMessagesByRoom(req, res));
app.put('/api/messages', (req, res) => console.log("TODO for editing"));

app.delete('/api/rooms/details', (req, res) => console.log("TODO for deleting members"));
app.patch('/api/rooms/details', (req, res) => console.log("TODO for changing to member status admin"));

app.get('/api/invites', (req, res) => console.log("TODO to get all invites for user"));
app.post('/api/invites', (req, res) => console.log("TODO to send invite to user"));


process.on('SIGINT', async () => {
  try {
      await db.close();
      console.log('Database connection closed.');
  } catch (err) {
      console.error('Error closing the database connection:', err.stack);
  } finally {
      process.exit();
  }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`Stub server running on port ${PORT}`);
});
