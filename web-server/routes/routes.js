const Express = require('express');

const UserController = require('../controllers/userController');
const RoomUserController = require('../controllers/roomUserController');
const MessageController = require('../controllers/messageController');
const InvitationController = require('../controllers/invitationController');
const NotificationController = require('../controllers/notificationController');

const router = Express.Router();
const userController = new UserController();
const roomUserController = new RoomUserController();
const messageController = new MessageController();
const invitationController = new InvitationController();
const notificationController = new NotificationController();

const WAITING_TIME_LIMIT = 60 * 1000;
var waitingClients = []; // Store waiting client responses

router.get('/version', (req, res) => res.status(200).json({success: 1, version: "2"}));
router.post('/login', (req, res) => userController.login(req, res));
router.post('/logout', (req, res) => userController.logout(req, res));
router.post('/register', (req, res) => userController.register(req, res));

router.post('/users', (req, res) => userController.setUser(req, res));
router.get('/users', (req, res) => userController.getUsers(req, res));
router.post('/users/password', (req, res) => userController.setPassword(req, res)); 

router.get('/devices', (req, res) => userController.getDevices(req, res)); 
router.delete('/devices', (req, res) => userController.deleteDevice(req, res)); 

router.post('/token', (req, res) => userController.token(req, res));
router.post('/token/extend', (req, res) => userController.extendToken(req, res));

router.get('/rooms', (req, res) => roomUserController.getChatRooms(req, res));   
router.post('/rooms', (req, res) => roomUserController.createChatRoom(req, res));  
router.put('/rooms', (req, res) => roomUserController.updateChatRoom(req, res));
router.delete('/rooms', (req, res) => roomUserController.deleteChatRoom(req, res)); 

router.post('/rooms/join', (req, res) => roomUserController.joinRoom(req, res)); 

router.put('/rooms/mute', (req, res) => roomUserController.muteChatRoom(req, res));

router.delete('/rooms/detail', (req, res) => roomUserController.deleteRoomUser(req, res));  
router.patch('/rooms/detail', (req, res) => roomUserController.updateAdminStatus(req, res)); 

router.get('/invites', (req, res) => invitationController.getAll(req, res));  
router.post('/invites', (req, res) => invitationController.send(req, res));  
router.post('/invites/accept', (req, res) => invitationController.accept(req, res)); 

router.post('/notification', (req, res) => notificationController.saveDeviceToken(req, res));

router.get('/messages', (req, res) => messageController.getMessagesByRoom(req, res));  

router.delete('/messages', async (req, res) => { 
  removeTimedOutClients();
  let targetRoomId = await messageController.deleteMessage(req, res);
  notifyClients(targetRoomId)
});
router.put('/messages', async (req, res) => { 
  removeTimedOutClients();
  let targetRoomId = await messageController.updateMessage(req, res);
  notifyClients(targetRoomId);
});

router.post('/send', async (req, res) => {
  removeTimedOutClients();
  let targetRoomId = await messageController.createMessage(req, res);
  notifyClients(targetRoomId);
});

router.get('/listen', (req, res) => {
  const { room_id } = req.query;
  waitingClients.push({ room_id: room_id, clientRes: res, timestamp: Date.now() });
});

function removeTimedOutClients() {
    const currentTime = Date.now();
    waitingClients = waitingClients.filter(client => {
        return (currentTime - client.timestamp) <= WAITING_TIME_LIMIT;
    });
}
  
function notifyClients(roomId) {
    if (!roomId) { return }

    const clientsToNotify = waitingClients.filter(client => client.room_id == roomId);
  
    clientsToNotify.forEach(client => {
        client.clientRes.status(200).json({ success: 1 });
    });
  
    waitingClients = waitingClients.filter(client => client.room_id != roomId);
}  

module.exports = router;