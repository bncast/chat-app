const RoomUserModel = require('../models/roomUserModel');
const RoomModel = require('../models/roomModel');
const UserModel = require('../models/userModel');
const UserController = require('../controllers/userController');
const ImageHelper = require('../utils/imageHelper');
const MessageModel = require('../models/messageModel');

class RoomUserController {
    constructor() {
        this.userController = new UserController();
    }

    async getRandomChatImageUrl(req) {
        const randomNumber = Math.floor(Math.random() * 21) + 1; // Random number between 1 and 20
        const imageName = `group${randomNumber}.png`;
        const imageUrl = `public/images/${imageName}`;
        return imageUrl;
    }

    async getChatRoomDetails(req, roomResult, userId){
        var memberDetails = [];
        const members = await RoomUserModel.findAll({ where: { room_id: roomResult.room_id, is_deleted: 0 }});
        
        for await (const member of members) {
            const user = await UserModel.findOne({ where: { id: member.user_id }});
            memberDetails.push({
                name: user.display_name,  
                is_admin: member.is_admin == 1,
                user_image_url: ImageHelper.getImagePath(req, user.image_url),  
                room_user_id: member.room_user_id
            });
        }    
        
        const creator = await UserModel.findOne({ where: { id: roomResult.creator_id }});
        const creatorName = creator.display_name || "Unknown";

        const currentUser = members.find(member => member.user_id === userId);
        const roomUserId = currentUser?.room_user_id || null;

        const roomUserIds = members.map((item) => item.room_user_id);
        const lastMessage = await MessageModel.findOne({ 
            where: { 
                room_user_id: roomUserIds,  
                deleted_at: null
            }, 
            order: [['created_at', 'DESC']]
        });
        
        var preview = "Say hello...";
        if (lastMessage != undefined) {
            const lastSender = memberDetails.find(x => x.room_user_id === lastMessage.room_user_id)?.name || "Unknown";
            preview = lastSender + " : " + lastMessage.content;
        }

        return {
            room_id: roomResult.room_id,
            author_id: roomResult.creator_id,  
            author_name: creatorName, 
            preview: preview,
            is_joined: roomUserId != null,
            current_room_user_id: roomUserId,
            has_password: roomResult.password != null,
            chat_name: roomResult.room_name,
            chat_image_url: ImageHelper.getImagePath(req, roomResult.image_url),
            member_details: memberDetails
        };
    }

    async createChatRoom(req, res) {
        try {
            const accessToken = req.headers['authorization'];
            let tokenCheck = await this.userController.getAccessTokenError(accessToken)
            if (tokenCheck.error != null) {
                return res.status(401).json(tokenCheck);
            }

            let userId = tokenCheck.result.user_id;

            const { name, password } = req.body;

            let imageUrl = await this.getRandomChatImageUrl(req);

            let createResult = await RoomModel.create({
                room_name: name,
                creator_id: userId,
                password: password,
                image_url: imageUrl
            });
            if (!createResult) { throw new Error("Failed to create room"); } 

            let roomUserResult = await RoomUserModel.create({
                room_id: createResult.room_id,
                user_id: userId,
                is_admin: 1
            });
            if (!roomUserResult) { throw new Error("Failed to create room user"); } 

            let chatRoomDetails = await this.getChatRoomDetails(req, createResult, userId);

            let response = {
                chatroom: chatRoomDetails,
                success: 1,
                error: {
                    code: "000",
                    message: ""
                }
            }

            res.status(200).json(response);
        } catch (err) {
            res.status(500).json({
                success: 0,
                error: {
                    code: "002",
                    message: err.message || "An error occurred while processing the request"
                }
            });    
        }
    }


    async updateChatRoom(req, res) {
        try {
            const accessToken = req.headers['authorization'];
            let tokenCheck = await this.userController.getAccessTokenError(accessToken);
            if (tokenCheck.error != null) {
                return res.status(401).json(tokenCheck);
            }
            let userId = tokenCheck.result.user_id;

            const { room_user_id, name } = req.body;

            let roomUserResult = await RoomUserModel.findOne({ where: { room_user_id: room_user_id } });
            if (!roomUserResult) { throw new Error("Failed to fetch room"); }

            let updateResult = await RoomModel.update(
                { room_name: name, updated_at: Date.now() },
                { where: { room_id: roomUserResult.room_id }}
            );
            if (!updateResult) { throw new Error("Failed to update room"); }

            let roomResult = await RoomModel.findOne({ where: { room_id: roomUserResult.room_id } });
            let chatRoomDetails = await this.getChatRoomDetails(req, roomResult, userId);

            let response = {
                chatroom : chatRoomDetails,
                success: 1,
                error: {
                    code: "000",
                    message: ""
                }
            }

            res.status(200).json(response);
        } catch (err) {
            res.status(500).json({
                success: 0,
                error: {
                    code: "002",
                    message: err.message || "An error occurred while processing the request"
                }
            });    
        }
    }

    async deleteChatRoom(req, res) {
        try {
            const accessToken = req.headers['authorization'];
            let tokenCheck = await this.userController.getAccessTokenError(accessToken);
            if (tokenCheck.error != null) {
                return res.status(401).json(tokenCheck);
            }

            const { room_user_id } = req.body;

            let roomUserResult = await RoomUserModel.findOne({ where: { room_user_id: room_user_id } });
            if (!roomUserResult) { throw new Error("Failed to fetch room"); }

            let updateResult = await RoomModel.update(
                { is_deleted: 1, updated_at: Date.now() },
                { where: { room_id: roomUserResult.room_id }}
            );
            if (!updateResult) { throw new Error("Failed to delete room"); }

            let response = {
                success: 1,
                error: {
                    code: "000",
                    message: ""
                }
            }

            res.status(200).json(response);
        } catch (err) {
            res.status(500).json({
                success: 0,
                error: {
                    code: "002",
                    message: err.message || "An error occurred while processing the request"
                }
            });    
        }
    }

    async getChatRooms(req, res) {
        try {
            const accessToken = req.headers['authorization'];
            let tokenCheck = await this.userController.getAccessTokenError(accessToken);
            if (tokenCheck.error != null) {
                return res.status(401).json(tokenCheck);
            }
            let userId = tokenCheck.result.user_id;

            const allRooms = await RoomModel.findAll({ where: { is_deleted: 0 } });
            const chatRooms = [];
    
            for (const room of allRooms) {
                let chatRoomDetails = await this.getChatRoomDetails(req, room, userId);
                chatRooms.push(chatRoomDetails);
            }
            
            let response = {
                chat_rooms: chatRooms,
                success: 1,
                error: {
                    code: "000",
                    message: ""
                }
            }
            res.status(200).json(response);
        } catch (err) {
            res.status(500).json({
                error: {
                    code: '002',
                    message: err.message || 'An error occurred while fetching chat rooms'
                }
            });
        }
    }

    async joinRoom(req, res) {
        try {
            const accessToken = req.headers['authorization'];
            let tokenCheck = await this.userController.getAccessTokenError(accessToken)
            if (tokenCheck.error != null) {
                return res.status(401).json(tokenCheck);
            }
            let userId = tokenCheck.result.user_id;

            const { room_id, password } = req.body;
            
            const roomResult = await RoomModel.findOne({ where: {
                room_id: room_id
            }});
            if (!roomResult) { throw new Error("Room not found."); }
            if (roomResult.password != null && roomResult.password != password) { throw new Error("Incorrect password");}

            let roomUserResult = await RoomUserModel.create({
                room_id: room_id,
                user_id: userId
            });
            if (!roomUserResult) { throw new Error("Failed to create room"); } 
        
            let chatRoomDetails = await this.getChatRoomDetails(req, roomResult, userId);

            let response = {
                chat_room: chatRoomDetails,
                success: 1,
                error: {
                    code: "000",
                    message: ""
                }
            }

            res.status(200).json(response);
        } catch (err) {
            res.status(500).json({
                error: {
                    code: '002',
                    message: err.message || 'An error occurred while fetching chat rooms'
                }
            });
        }
    }

    async updateAdminStatus(req, res) {
        try {
            const accessToken = req.headers['authorization'];
            let tokenCheck = await this.userController.getAccessTokenError(accessToken)
            if (tokenCheck.error != null) {
                return res.status(401).json(tokenCheck);
            }
            
            const { room_user_id, is_admin } = req.body;
            
            let result = await RoomUserModel.update(
                { is_admin: is_admin },
                { where: { room_user_id: room_user_id } }
            );
            if (!result) { throw new Error("Failed to update user status"); }

            res.status(200).json({
                success: 1,
                error: {
                    code: "000",
                    message: ""
                }
            });
        } catch (err) {
            res.status(500).json({
                success: 0,
                error: {
                    code: "500",
                    message: err.message
                }
            });
        }
    }

    async deleteRoomUser(req, res) {
        try {
            const accessToken = req.headers['authorization'];
            let tokenCheck = await this.userController.getAccessTokenError(accessToken)
            if (tokenCheck.error != null) {
                return res.status(401).json(tokenCheck);
            }
            
            const { room_user_id } = req.body;
            
            let result = await RoomUserModel.update(
                { is_deleted: 1 },
                { where: { room_user_id: room_user_id } }
            );
            if (!result) { throw new Error("Failed to update user status"); }
            
            res.status(200).json({
                success: 1,
                error: {
                    code: "000",
                    message: ""
                }
            });
        } catch (err) {
            res.status(500).json({
                success: 0,
                error: {
                    code: "500",
                    message: err.message
                }
            });
        }
    }
}

module.exports = RoomUserController;
