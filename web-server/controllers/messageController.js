
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

            let roomUserResult = await this.roomUserModel.getRoomForRoomUserId(room_user_id);
            let room = await roomUserResult.pop();

            completion(room.room_id);
        } catch (err) {
            console.error("Error creating message:", err);
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
                content: msg.content,
                created_at: msg.created_at,
                updated_at: msg.updated_at,
                is_current_user: msg.is_current_user == 1
            }));
    
            res.json({
                messages: formattedMessages,
                success: 1,
                error: {
                    code: "000",
                    message: ""
                }
            });
        } catch (err) {
            console.error("Error fetching messages:", err);
            res.status(500).json({ error: "Failed to fetch messages" });
        }
    }

    // Update a message
    async updateMessage(req, res) {
        try {
            const message_id = req.params.message_id;
            const { content } = req.body;
            const result = await this.messageModel.updateMessage(message_id, content);
            if (result.affectedRows === 0) {
                return res.status(404).json({ error: "Message not found or already deleted" });
            }
            res.json({ success: true });
        } catch (err) {
            console.error("Error updating message:", err);
            res.status(500).json({ error: "Failed to update message" });
        }
    }

    // Soft delete a message
    async deleteMessage(req, res) {
        try {
            const message_id = req.params.message_id;
            const result = await this.messageModel.deleteMessage(message_id);
            if (result.affectedRows === 0) {
                return res.status(404).json({ error: "Message not found or already deleted" });
            }
            res.json({ success: true });
        } catch (err) {
            console.error("Error deleting message:", err);
            res.status(500).json({ error: "Failed to delete message" });
        }
    }
}

module.exports = MessageController;
