
const MessageModel = require('../models/messageModel');
const UserModel = require('../models/userModel');
const RoomUserModel = require('../models/roomUserModel');
const UserController = require('../controllers/userController');
const ImageHelper = require('../utils/imageHelper');


class MessageController {
    constructor(database) {
        this.messageModel = new MessageModel(database);
        this.userModel = new UserModel(database);
        this.roomUserModel = new RoomUserModel(database);
    }

    // Create a new message
    async createMessage(req, res, completion) {
        try {
            const accessToken = req.headers['authorization'];
            let tokenCheck = await UserController.getAccessTokenError(accessToken);
            if (tokenCheck.error != null) {
                return res.status(401).json(tokenCheck);
            }
            let userId = tokenCheck.result.user_id;

            const { room_user_id, message, reply_to_id } = req.body;

            let messageResult = await MessageModel.create({ 
                room_user_id: room_user_id,
                content: message,
                reply_to_id: reply_to_id
            });//this.messageModel.createMessage(room_user_id, message, reply_to_id);
            
            res.status(201).json({ 
                success: 1,
                error: {
                    code: "000",
                    message: ""
                }
            });

            let roomUserResult = await RoomUserModel.findOne({ where: { room_user_id: room_user_id}});
            
            completion(roomUserResult.room_id);
        } catch (err) {
            res.status(500).json({ error: "Failed to create message" });
        }
    }

    // Get all messages in a room
    async getMessagesByRoom(req, res) {
        try {
            const accessToken = req.headers['authorization'];
            let tokenCheck = await UserController.getAccessTokenError(accessToken);
            if (tokenCheck.error != null) {
                return res.status(401).json(tokenCheck);
            }
            let userId = tokenCheck.result.user_id;

            const { room_id, room_user_id } = req.query

            const roomUsers = await RoomUserModel.findAll({ where: { room_id: room_id }});
            const roomUserIds = roomUsers.map((item) => item.room_user_id);
            const messages = await MessageModel.findAll({ where: { room_user_id: roomUserIds }});

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

            res.json(response);
        } catch (err) {
            res.status(500).json({ error: "Failed to fetch messages" });
        }
    }

    // Update a message
    async updateMessage(req, res, completion) {
        try {
            const { device_id, message_id, message } = req.body

            let userResult = await this.userModel.getUserById(device_id);
            if (userResult.length <= 0) {
                throw new Error("User not found.");
            }

                // Retrieve the updated message details
            const updateResult = await this.messageModel.updateMessage(message_id, message);
            if (updateResult.length <= 0) {
                return res.status(404).json({ error: "Message not found after update" });
            }

            const updatedMessageResult = await this.messageModel.getMessageById(message_id);
            let updatedMessage = updatedMessageResult[0];

            // Send the response
            res.json({
                success: 1,
                error: {
                    code: "000",
                    message: ""
                }
            });

            let roomUserResult = await this.roomUserModel.getRoomUserForRoomUserId(updatedMessage.room_user_id);
            let room = await roomUserResult.pop();

            completion(room.room_id);
        } catch (err) {
            res.status(500).json({ error: "Failed to update message" });
        }
    }

    // Soft delete a message
    async deleteMessage(req, res, completion) {
        try {
            const { device_id, message_id } = req.body

            let userResult = await this.userModel.getUserById(device_id);
            if (userResult.length <= 0) {
                throw new Error("User not found.");
            }

            // Retrieve the updated message details
            const updateResult = await this.messageModel.deleteMessage(message_id);
            if (updateResult.length <= 0) {
                return res.status(404).json({ error: "Message not found after update" });
            }

            const updatedMessageResult = await this.messageModel.getMessageById(message_id);
            let updatedMessage = updatedMessageResult[0];
            
            let roomUserResult = await this.roomUserModel.getRoomUserForRoomUserId(updatedMessage.room_user_id);
            let room = await roomUserResult[0];

            completion(room.room_id);

            res.json({
                success: 1,
                error: {
                    code: "000",
                    message: ""
                }
            });
        } catch (err) {
            res.status(500).json({ error: "Failed to delete message" });
        }
    }
}

module.exports = MessageController;
