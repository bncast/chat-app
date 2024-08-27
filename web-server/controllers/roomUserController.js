const RoomUserModel = require('../models/roomUserModel');
const RoomModel = require('../models/roomModel');
const UserModel = require('../models/userModel');
const MessageModel = require('../models/messageModel');

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
        const imageUrl = `/public/images/${imageName}`;
        return imageUrl;
    }

    async createChatRoom(req, res) {
        try {
            const { name, device_id, password } = req.body;

            let author_name;

            let userResult = await this.userModel.getUserById(device_id)
            if (userResult.length > 0) {
                let user = userResult[0];
                author_name = user.display_name;
            } else {
                throw new Error("User not found.");
            }
            
            let image_url = getRandomChatImageUrl(req);
            let roomResult = await this.roomModel.create(name, device_id, password, image_url);
            if (!roomResult) { throw new Error("Failed to create room"); } 

            let roomId = roomResult.insertId;
            
            let roomUserResult = await this.roomUserModel.createRoomUser(roomId, device_id, 1);
            if (!roomUserResult) { throw new Error("Failed to create room user"); } 

            let roomUserId = roomUserResult.insertId;

            let imagePath = `${req.protocol}://${req.get('host')}/` + image_url;
            
            let response = {
                chatroom : {
                    room_id: roomId,
                    author_id: roomUserId,
                    author_name: author_name,
                    preview: "Say hello...",
                    is_joined: true,
                    current_room_user_id: roomUserId,
                    has_password: password != null,
                    chat_name: name,
                    chat_image_url: imagePath,
                    member_details: []
                },
                success: 1,
                error: {
                    code: "000",
                    message: ""
                }
            }

            // console.log(response);
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


            let roomResult = await this.roomModel.updateNameById(name, userId, roomId);
            if (!roomResult) { throw new Error("Failed to create room"); } 

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
                chatroom : {
                    room_id: roomId,
                    author_id: roomId,
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

            // console.log(response);
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

            // console.log(response);
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
            const { device_id } = req.query;
            
            let userResult = await this.userModel.getUserById(device_id);
            if (userResult.length <= 0) {
                throw new Error("User not found.");
            }
    
            const allRooms = await this.roomModel.getAll();
            const chatRooms = [];
    
            for (const room of allRooms) {
                const roomResult = await this.roomModel.getById(room.room_id);
                if (roomResult.length <= 0) continue;  

                const roomDetails = roomResult[0];            
    
                const members = await this.roomUserModel.getUsersInRoom(room.room_id);

                const memberDetails = members.map(member => ({
                    name: member.name,  
                    is_admin: member.is_admin == 1,
                    user_image_url: `${req.protocol}://${req.get('host')}/` + member.image_url,  
                    room_user_id: member.room_user_id
                }));

                const roomUserId = members.find(member => member.user_id === device_id)?.room_user_id || null;

                let previewResult = await this.messageModel.getLatestMessage(room.room_id);
                let lastMessage = previewResult[0];
                
                var preview = "Say hello...";
                if (lastMessage != undefined && lastMessage.display_name != undefined && lastMessage.content != undefined) {
                    preview = lastMessage.display_name + " : " + lastMessage.content;
                }

                const chatRoom = {
                    room_id: room.room_id,
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

            // console.log(response);
            res.json(response);
        } catch (err) {
            console.error('Error getting chat rooms:', err);
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

            // console.log(response);
            res.json(response);
        } catch (err) {
            console.error('Error getting chat rooms:', err);
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
            console.error("Error setting user as admin:", err);
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
            console.error("Error soft deleting room user:", err);
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
