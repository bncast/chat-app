const Express = require('express');

const Database = require('../config/database');
const UserController = require('../controllers/userController');
const RoomUserController = require('../controllers/roomUserController');
const MessageController = require('../controllers/messageController');
const InvitationController = require('../controllers/invitationController');

const router = Express.Router();
const userController = new UserController();
const roomUserController = new RoomUserController();
const messageController = new MessageController();
const invitationController = new InvitationController();

const WAITING_TIME_LIMIT = 60 * 1000;
var waitingClients = []; // Store waiting client responses

router.get('/api/listen', (req, res) => {
  const { device_id, room_id } = req.query;
  
  waitingClients.push({ room_id: room_id, clientRes: res, timestamp: Date.now() });
});

router.post('/users/login', (req, res) => userController.login(req, res));

router.post('/users/register', (req, res) => userController.setUser(req, res));
router.get('/users', (req, res) => userController.getUsers(req, res)); 

router.get('/api/rooms', (req, res) => roomUserController.getChatRooms(req, res));
router.post('/api/rooms', (req, res) => roomUserController.createChatRoom(req, res));
router.put('/api/rooms', (req, res) => roomUserController.updateChatRoom(req, res));
router.delete('/api/rooms', (req, res) => roomUserController.deleteChatRoom(req, res));

router.post('/api/rooms/join', (req, res) => roomUserController.joinRoom(req, res));

router.get('/api/messages', (req, res) => messageController.getMessagesByRoom(req, res));
router.delete('/api/messages', (req, res) => {
  removeTimedOutClients();

  messageController.deleteMessage(req, res, (targetRoomId) => {
    notifyClients(targetRoomId);
  });
});

router.put('/api/messages', (req, res) => {
  removeTimedOutClients();

  messageController.updateMessage(req, res, (targetRoomId) => {
    notifyClients(targetRoomId);
  });
});

router.post('/api/send', (req, res) => {
  removeTimedOutClients();

  messageController.createMessage(req, res, (targetRoomId) => {
    notifyClients(targetRoomId);
  });
});

router.delete('/api/rooms/detail', (req, res) => roomUserController.deleteRoomUser(req, res));
router.patch('/api/rooms/detail', (req, res) => roomUserController.updateAdminStatus(req, res));

router.get('/api/invites', (req, res) => invitationController.getAll(req, res));
router.post('/api/invites', (req, res) => invitationController.send(req, res));
router.post('/api/invites/accept', (req, res) => invitationController.accept(req, res));

function removeTimedOutClients() {
    const currentTime = Date.now();
    waitingClients = waitingClients.filter(client => {
        return (currentTime - client.timestamp) <= WAITING_TIME_LIMIT;
    });
}
  
function notifyClients(roomId) {
    const clientsToNotify = waitingClients.filter(client => client.room_id == roomId);
  
    clientsToNotify.forEach(client => {
        client.clientRes.status(200).json({ success: 1 });
    });
  
    waitingClients = waitingClients.filter(client => client.room_id != roomId);
}  

module.exports = router;