
const MessageModel = require('../models/messageModel');
const UserModel = require('../models/userModel');
const RoomUserModel = require('../models/roomUserModel');


class MessageController {
    constructor(database) {
        this.messageModel = new MessageModel(database);
        this.userModel = new UserModel(database);
        this.roomUserModel = new RoomUserModel(database);
    }

    // Create a new message
    async createMessage(req, res, completion) {
        try {
            const { device_id, room_user_id, message, reply_to_id } = req.body;

            let userResult = await this.userModel.getUserById(device_id);
            if (userResult.length <= 0) {
                throw new Error("User not found.");
            }

            let result = await this.messageModel.createMessage(room_user_id, message, reply_to_id);
            
            res.status(201).json({ 
                success: 1,
                error: {
                    code: "000",
                    message: ""
                }
            });

            let roomUserResult = await this.roomUserModel.getRoomUserForRoomUserId(room_user_id);
            let room = await roomUserResult[0];

            completion(room.room_id);
        } catch (err) {
            res.status(500).json({ error: "Failed to create message" });
        }
    }

    // Get all messages in a room
    async getMessagesByRoom(req, res) {
        try {
            const { device_id, room_id, room_user_id } = req.query

            let userResult = await this.userModel.getUserById(device_id);
            if (userResult.length <= 0) {
                throw new Error("User not found.");
            }

            const messages = await this.messageModel.getMessagesByRoom(room_id, room_user_id);
            
            const formattedMessages = messages.map(msg => ({
                message_id: msg.message_id,
                author_id: msg.author_id,
                author_image_url: `${req.protocol}://${req.get('host')}/` + msg.author_image,
                content: msg.content,
                created_at: msg.created_at,
                updated_at: msg.updated_at,
                is_current_user: msg.is_current_user == 1,
                is_replying_to: msg.reply_to_user,
                is_replying_to_content: msg.reply_to_content
            }));
            
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
            res.status(500).json({ error: "Failed to delete message" });
        }
    }
}

module.exports = MessageController;
