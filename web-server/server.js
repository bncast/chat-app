const express = require('express');
const bodyParser = require('body-parser');
const path = require('path');

const Database = require('./config/database');
const UserController = require('./controllers/userController');
const RoomUserController = require('./controllers/roomUserController');
const MessageController = require('./controllers/messageController');
const InvitationController = require('./controllers/invitationController');

const app = express();
const db = new Database();
const userController = new UserController(db);
const roomUserController = new RoomUserController(db);
const messageController = new MessageController(db);
const invitationController = new InvitationController(db);

app.use(bodyParser.json())
app.use(bodyParser.urlencoded({ extended: true }))

const WAITING_TIME_LIMIT = 60 * 1000;
var waitingClients = []; // Store waiting client responses

function removeTimedOutClients() {
  const currentTime = Date.now();
  waitingClients = waitingClients.filter(client => {
    return (currentTime - client.timestamp) <= WAITING_TIME_LIMIT;
  });
}

function notifyClients(roomId) {
  // Filter clients who belong to the target room
  const clientsToNotify = waitingClients.filter(client => client.room_id == roomId);

  // Notify all matching clients
  clientsToNotify.forEach(client => {
    client.clientRes.status(200).json({ success: 1 });
  });

  // Remove notified clients from the waiting list
  waitingClients = waitingClients.filter(client => client.room_id != roomId);
}

app.get('/api/listen', (req, res) => {
  const { device_id, room_id } = req.query;
  
  waitingClients.push({ room_id, clientRes: res, timestamp: Date.now() });
});


app.post('/api/users', (req, res) => userController.setUser(req, res));
app.get('/api/users', (req, res) => userController.getUsers(req, res)); // need to retested during integration

app.get('/api/rooms', (req, res) => roomUserController.getChatRooms(req, res));
app.post('/api/rooms', (req, res) => roomUserController.createChatRoom(req, res));
app.put('/api/rooms', (req, res) => roomUserController.updateChatRoom(req, res));
app.delete('/api/rooms', (req, res) => roomUserController.deleteChatRoom(req, res));

app.post('/api/rooms/join', (req, res) => roomUserController.joinRoom(req, res));

app.get('/api/messages', (req, res) => messageController.getMessagesByRoom(req, res));
app.delete('/api/messages', (req, res) => {
  removeTimedOutClients();

  messageController.deleteMessage(req, res, (targetRoomId) => {
    notifyClients(targetRoomId);
  });
});

app.put('/api/messages', (req, res) => {
  removeTimedOutClients();

  messageController.updateMessage(req, res, (targetRoomId) => {
    notifyClients(targetRoomId);
  });
});

app.post('/api/send', (req, res) => {
  removeTimedOutClients();

  messageController.createMessage(req, res, (targetRoomId) => {
    notifyClients(targetRoomId);
  });
});

app.delete('/api/rooms/detail', (req, res) => roomUserController.deleteRoomUser(req, res));
app.patch('/api/rooms/detail', (req, res) => roomUserController.updateAdminStatus(req, res));

app.get('/api/invites', (req, res) => invitationController.getAll(req, res));
app.post('/api/invites', (req, res) => invitationController.sendInvitation(req, res));


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
