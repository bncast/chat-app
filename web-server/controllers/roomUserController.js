const RoomUserModel = require('../models/roomUserModel');
const RoomModel = require('../models/roomModel');
const UserModel = require('../models/userModel');
const MessageModel = require('../models/messageModel');
const UserController = require('../controllers/userController');
const ImageHelper = require('../utils/imageHelper');

class RoomUserController {
    constructor(database) {
        this.roomModel = new RoomModel(database);
        this.roomUserModel = new RoomUserModel(database);
        this.userModel = new UserModel(database);
        this.messageModel = new MessageModel(database);
    }

    async getRandomChatImageUrl(req) {
        const randomNumber = Math.floor(Math.random() * 21) + 1; // Random number between 1 and 20
        const imageName = `group${randomNumber}.png`;
        const imageUrl = `public/images/${imageName}`;
        return imageUrl;
    }

    async createChatRoom(req, res) {
        try {
            const accessToken = req.headers['authorization'];
            let tokenCheck = await UserController.getAccessTokenError(accessToken)
            if (tokenCheck.error != null) {
                return res.status(401).json({ 
                    error: {
                        code: "401",
                        message: tokenCheck.error
                    } 
                });
            }

            let userId = tokenCheck.result.user_id;

            const { name, password } = req.body;

            let authorName;

            let userResult = await UserModel.findOne({ where: { id: userId }});
            if (userResult != null) {
                authorName = userResult.display_name;
            } else {
                throw new Error("User not found.");
            }
            
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

            let roomUserId = roomUserResult.room_user_id;
            
            let response = {
                chatroom : {
                    room_id: createResult.room_id,
                    author_id: userId,
                    author_name: authorName,
                    preview: "Say hello...",
                    is_joined: true,
                    current_room_user_id: roomUserId,
                    has_password: password != null,
                    chat_name: name,
                    chat_image_url: ImageHelper.getImagePath(req, imageUrl),
                    member_details: []
                },
                success: 1,
                error: {
                    code: "000",
                    message: ""
                }
            }

            res.json(response);
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
            const { device_id, room_user_id, name } = req.body;

            let userResult = await this.userModel.getUserById(device_id);
            if (userResult.length <= 0) {
                throw new Error("User not found.");
            }
            
            let roomUserResult = await this.roomUserModel.getRoomUserForRoomUserId(room_user_id);
            if (!roomUserResult) { throw new Error("Failed to fetch room user"); } 

            let roomUser = roomUserResult[0];
            let roomId = roomUser.room_id;
            let userId = roomUser.user_id;

            let otherUserResult = await this.userModel.getUserById(userId);
            if (!otherUserResult) { throw new Error("Failed to fetch user"); } 

            let otherUser = otherUserResult[0];
            let userDisplayName = otherUser.display_name;


            let updateRoomResult = await this.roomModel.updateNameById(name, userId, roomId);
            if (!updateRoomResult) { throw new Error("Failed to create room"); } 

            let roomResult = await this.roomModel.getByIdByPassed(roomId);
            let room = roomResult[0];
            let hasPassword = room.hasPassword != null;
            let newName = room.room_name;
            
            const members = await this.roomUserModel.getUsersInRoom(room.room_id);

            const memberDetails = members.map(member => ({
                name: member.name,  
                is_admin: member.is_admin == 1,
                user_image_url: `${req.protocol}://${req.get('host')}/` + member.image_url,
                room_user_id: member.room_user_id
            }));

            let roomImagePath = `${req.protocol}://${req.get('host')}/` + room.image_url;
            
            let previewResult = await this.messageModel.getLatestMessage(roomId);
            let lastMessage = previewResult[0];
            
            var preview = "Say hello...";
            if (lastMessage != undefined && lastMessage.display_name != undefined && lastMessage.content != undefined) {
                preview = lastMessage.display_name + " : " + lastMessage.content;
            }

            let response = {
                chatrooms : {
                    room_id: roomId,
                    author_id: room.creator_id,
                    author_name: userDisplayName,
                    preview: preview,
                    is_joined: true,
                    current_room_user_id: room_user_id,
                    has_password: hasPassword,
                    chat_name: newName,
                    chat_image_url: roomImagePath,
                    member_details: memberDetails
                },
                success: 1,
                error: {
                    code: "000",
                    message: ""
                }
            }

            res.json(response);
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
            const { device_id, room_user_id } = req.body;

            let userResult = await this.userModel.getUserById(device_id);
            if (userResult.length <= 0) {
                throw new Error("User not found.");
            }
            
            let roomUserResult = await this.roomUserModel.getRoomUserForRoomUserId(room_user_id);
            if (!roomUserResult) { throw new Error("Failed to fetch room user"); } 

            let roomUser = roomUserResult[0];
            let roomId = roomUser.room_id;
            
            let roomResult = await this.roomModel.deleteById(roomId);
            if (!roomResult) { throw new Error("Failed to create room"); } 

            let response = {
                success: 1,
                error: {
                    code: "000",
                    message: ""
                }
            }

            res.json(response);
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
            let tokenCheck = await UserController.getAccessTokenError(accessToken)
            if (tokenCheck.error != null) {
                return res.status(401).json({ 
                    error: {
                        code: "401",
                        message: tokenCheck.error
                    } 
                });
            }
            let userId = tokenCheck.result.user_id;

            const allRooms = await RoomModel.findAll();
            const chatRooms = [];
    
            for (const room of allRooms) {
                const members = await RoomUserModel.findAll({ where: {
                    room_id: room.room_id
                }});

                var memberDetails = [];
                
                for await (const member of members) {
                    const user = await UserModel.findOne({ where: { id: member.user_id }});
                    memberDetails.push({
                        name: user.display_name,  
                        is_admin: member.is_admin == 1,
                        user_image_url: ImageHelper.getImagePath(req, user.image_url),  
                        room_user_id: member.room_user_id
                    });
                }    
                  
                // const memberDetails = members.map(member => ());

                const creator = await UserModel.findOne({ where: { id: room.creator_id }});
                const creatorName = creator.display_name;

                const currentUser = members.find(member => member.user_id === userId);
                const roomUserId = currentUser?.room_user_id || null;

                let previewResult = null;//await this.messageModel.getLatestMessage(room.room_id);
                let lastMessage = null;
                
                var preview = "Say hello...";
                if (lastMessage != undefined && lastMessage.display_name != undefined && lastMessage.content != undefined) {
                    preview = lastMessage.display_name + " : " + lastMessage.content;
                }

                const chatRoom = {
                    room_id: room.room_id,
                    author_id: room.creator_id,  
                    author_name: creatorName || "Unknown", 
                    preview: preview,
                    is_joined: roomUserId != null,
                    current_room_user_id: roomUserId,
                    has_password: room.password != null,
                    chat_name: room.room_name,
                    chat_image_url: ImageHelper.getImagePath(req, room.image_url),
                    member_details: memberDetails
                };
    
                chatRooms.push(chatRoom);
            }
            
            let response = {
                chat_rooms: chatRooms,
                success: 1,
                error: {
                    code: "000",
                    message: ""
                }
            }
            res.json(response);
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
            const { room_id, device_id, password } = req.body;
            
            let userResult = await this.userModel.getUserById(device_id);
            if (userResult.length <= 0) {
                throw new Error("User not found.");
            }
    
            const roomResult = await this.roomModel.getById(room_id, password);
            if (roomResult.length <= 0) { throw new Error("Room not found."); }
            
            const roomDetails = roomResult[0];

            let roomUserResult = await this.roomUserModel.createRoomUser(room_id, device_id);
            if (!roomUserResult) { throw new Error("Failed to create room"); } 
        
            const members = await this.roomUserModel.getUsersInRoom(roomDetails.room_id);

            const roomUserId = members.find(member => member.user_id === device_id)?.room_user_id || null;

            const memberDetails = members.map(member => ({
                name: member.name,  
                is_admin: member.is_admin == 1,
                user_image_url: `${req.protocol}://${req.get('host')}/` + member.image_url,  
                room_user_id: member.room_user_id
            }));

            let previewResult = await this.messageModel.getLatestMessage(roomDetails.room_id);
            let lastMessage = previewResult[0];
            
            var preview = "Say hello...";
            if (lastMessage != undefined && lastMessage.display_name != undefined && lastMessage.content != undefined) {
                preview = lastMessage.display_name + " : " + lastMessage.content;
            }

            const chatRoom = {
                room_id: roomDetails.room_id,
                author_id: roomDetails.creator_id,  
                author_name: roomDetails.creator_name || "Unknown",  
                preview: preview,
                is_joined: roomUserId != null,
                current_room_user_id: roomUserId,
                has_password: roomDetails.password != null,
                chat_name: roomDetails.room_name,
                chat_image_url: `${req.protocol}://${req.get('host')}/` + roomDetails.image_url,
                member_details: memberDetails
            };
    
            let response = {
                chat_room: chatRoom,
                success: 1,
                error: {
                    code: "000",
                    message: ""
                }
            }

            res.json(response);
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
            const { device_id, room_user_id, is_admin } = req.body;
            
            let userResult = await this.userModel.getUserById(device_id);
            if (userResult.length <= 0) {
                throw new Error("User not found.");
            }
    
            const result = await this.roomUserModel.updateAdminStatus(room_user_id, is_admin);
            
            if (result.affectedRows > 0) {
                res.json({
                    success: 1,
                    error: {
                        code: "000",
                        message: ""
                    }
                });
            } else {
                res.status(404).json({
                    success: 0,
                    error: {
                        code: "404",
                        message: "Room user not found or already deleted"
                    }
                });
            }
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
            const { device_id, room_user_id } = req.body;

            let userResult = await this.userModel.getUserById(device_id);
            if (userResult.length <= 0) {
                throw new Error("User not found.");
            }
    
            const result = await this.roomUserModel.removeUserFromRoom(room_user_id);
            if (result.affectedRows > 0) {
                res.json({
                    success: 1,
                    error: {
                        code: "000",
                        message: ""
                    }
                });
            } else {
                res.status(404).json({
                    success: 0,
                    error: {
                        code: "404",
                        message: "Room user not found or already deleted"
                    }
                });
            }
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
