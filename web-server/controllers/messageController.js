
const MessageModel = require('../models/messageModel');
const UserModel = require('../models/userModel');
const UserDeviceModel = require('../models/userDeviceModel');
const RoomModel = require('../models/roomModel');
const RoomUserModel = require('../models/roomUserModel');
const UserController = require('../controllers/userController');
const NotificationController = require('../controllers/notificationController');
const ImageHelper = require('../utils/imageHelper');
const { Op } = require('sequelize');

class MessageController {
    constructor() {
        this.userController = new UserController();
        this.notificationController = new NotificationController();
    }

    // Create a new message
    async createMessage(req, res) {
        try {
            const accessToken = req.headers['authorization'];
            let tokenCheck = await this.userController.getAccessTokenError(accessToken);
            if (tokenCheck.error != null) {
                return res.status(401).json(tokenCheck);
            }
            let userId = tokenCheck.result.user_id;

            const { room_user_id, message, reply_to_id } = req.body;

            await MessageModel.create({ 
                room_user_id: room_user_id,
                content: message,
                reply_to_id: reply_to_id
            });
            
            let roomUserResult = await RoomUserModel.findOne({ where: { room_user_id: room_user_id}});
            
            const roomUsers = await RoomUserModel.findAll({ where: { room_id: roomUserResult.room_id, is_muted: false, user_id: { [Op.not] : [userId]} } });
            const userIds = roomUsers.map((item) => item.user_id);
            const userDeviceResult = await UserDeviceModel.findAll({ where: { user_id: userIds }});
            
            for await(const result of userDeviceResult) {
                let senderResult = await UserModel.findOne({ where: { id: result.user_id }});
                let roomResult = await RoomModel.findOne({ where: { room_id: roomUserResult.room_id }});
                let deviceToken = result.device_push_token;

                await this.notificationController.sendNotification(deviceToken,
                    senderResult.display_name,
                    message,
                    "NEW_MESSAGE",
                    {"roomId" : roomUserResult.room_id}
                );
            }; 

            res.status(201).json({ 
                success: 1,
                error: {
                    code: "000",
                    message: ""
                }
            });
            
            return roomUserResult.room_id;
        } catch (err) {
            res.status(500).json({ error: "Failed to create message" });
        }

        return null
    }

    // Get all messages in a room
    async getMessagesByRoom(req, res) {
        try {
            const accessToken = req.headers['authorization'];
            let tokenCheck = await this.userController.getAccessTokenError(accessToken);
            if (tokenCheck.error != null) {
                return res.status(401).json(tokenCheck);
            }
            let userId = tokenCheck.result.user_id;

            const { room_id } = req.query

            const roomUsers = await RoomUserModel.findAll({ where: { room_id: room_id }});
            const roomUserIds = roomUsers.map((item) => item.room_user_id);
            const messages = await MessageModel.findAll({ 
                where: { 
                    room_user_id: roomUserIds,  
                    deleted_at: null
                }
            });

            var formattedMessages = [];

            for await (const msg of messages) {
                const authorRoomUser = await RoomUserModel.findOne({ where: { room_user_id: msg.room_user_id }});
                const author = await UserModel.findOne({ where: { id: authorRoomUser.user_id }});
                const isCurrentUser = author.id == userId
                formattedMessages.push({
                    message_id: msg.message_id,
                    author_id: msg.room_user_id,
                    author_image_url: ImageHelper.getImagePath(req, author.image_url),
                    content: msg.content,
                    created_at: msg.created_at,
                    updated_at: msg.updated_at,
                    is_current_user: isCurrentUser,
                    is_replying_to: null, // TODO:
                    is_replying_to_content: null // TODO:
                });
            }
            
            let response = {
                messages: formattedMessages,
                success: 1,
                error: {
                    code: "000",
                    message: ""
                }
            };

            res.status(200).json(response);
        } catch (err) {
            res.status(500).json({ error: "Failed to fetch messages" });
        }
    }

    // Update a message
    async updateMessage(req, res) {
        try {
            const accessToken = req.headers['authorization'];
            let tokenCheck = await this.userController.getAccessTokenError(accessToken);
            if (tokenCheck.error != null) {
                return res.status(401).json(tokenCheck);
            }

            const { message_id, message } = req.body;

            let result = await MessageModel.update(
                { content: message, updated_at: Date.now() },
                { where: { message_id: message_id } }
            );
            if (!result) { throw new Error("Failed to delete message"); }

            let messageResult = await MessageModel.findOne({ where: { message_id: message_id } });
            let roomUserResult = await RoomUserModel.findOne({ where: { room_user_id: messageResult.room_user_id } } );
            
            res.status(200).json({ 
                success: 1,
                error: {
                    code: "000",
                    message: ""
                }
            });
            
            return roomUserResult.room_id;
        } catch (err) {
            res.status(500).json({ error: "Failed to create message" });
        }

        return null
    }

    // Soft delete a message
    async deleteMessage(req, res) {
        try {
            const accessToken = req.headers['authorization'];
            let tokenCheck = await this.userController.getAccessTokenError(accessToken);
            if (tokenCheck.error != null) {
                return res.status(401).json(tokenCheck);
            }

            const { message_id } = req.body;

            let result = await MessageModel.update(
                { deleted_at: Date.now(), updated_at: Date.now() },
                { where: { message_id: message_id } }
            );
            if (!result) { throw new Error("Failed to delete message"); }

            let messageResult = await MessageModel.findOne({ where: { message_id: message_id } });
            let roomUserResult = await RoomUserModel.findOne({ where: { room_user_id: messageResult.room_user_id } } );
            
            res.status(200).json({ 
                success: 1,
                error: {
                    code: "000",
                    message: ""
                }
            });
            
            return roomUserResult.room_id;
        } catch (err) {
            res.status(500).json({ error: "Failed to create message" });
        }

        return null
    }
}

module.exports = MessageController;
