const RoomUserModel = require('../models/roomUserModel');
const RoomModel = require('../models/roomModel');
const UserModel = require('../models/userModel');

class RoomUserController {
    constructor(database) {
        this.roomModel = new RoomModel(database);
        this.roomUserModel = new RoomUserModel(database);
        this.userModel = new UserModel(database);
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
            
            let roomResult = await this.roomModel.create(name, device_id, password);
            if (!roomResult) { throw new Error("Failed to create room"); } 

            let roomId = roomResult.insertId;
            
            let roomUserResult = await this.roomUserModel.createRoomUser(roomId, device_id, 1);
            if (!roomUserResult) { throw new Error("Failed to create room user"); } 

            let roomUserId = roomUserResult.insertId;

            let response = {
                chatroom : {
                    room_id: roomId,
                    author_id: roomUserId,
                    author_name: author_name,
                    preview: "",
                    is_joined: true,
                    current_room_user_id: roomUserId,
                    has_password: password != null,
                    chat_name: name,
                    chat_image_url: "",
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
                user_image_url: "",  
                room_user_id: member.room_user_id
            }));

            let response = {
                chatroom : {
                    room_id: roomId,
                    author_id: roomId,
                    author_name: userDisplayName,
                    preview: "",
                    is_joined: true,
                    current_room_user_id: room_user_id,
                    has_password: hasPassword,
                    chat_name: newName,
                    chat_image_url: "",
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
                    user_image_url: "",  
                    room_user_id: member.room_user_id
                }));

                const roomUserId = members.find(member => member.user_id === device_id)?.room_user_id || null;
    
                const chatRoom = {
                    room_id: room.room_id,
                    author_id: roomDetails.creator_id,  
                    author_name: roomDetails.creator_name || "Unknown", 
                    preview: "TODO",
                    is_joined: roomUserId != null,
                    current_room_user_id: roomUserId,
                    has_password: roomDetails.password != null,
                    chat_name: roomDetails.room_name,
                    chat_image_url: roomDetails.image_url || "",
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
    
            const roomResult = await this.roomModel.getById(room_id);
            if (roomResult.length <= 0) { throw new Error("Room not found."); }
            
            const roomDetails = roomResult[0];

            let roomUserResult = await this.roomUserModel.createRoomUser(room_id, device_id);
            if (!roomUserResult) { throw new Error("Failed to create room"); } 
        
            const members = await this.roomUserModel.getUsersInRoom(roomDetails.room_id);

            const roomUserId = members.find(member => member.user_id === device_id)?.room_user_id || null;

            const memberDetails = members.map(member => ({
                name: member.name,  
                is_admin: member.is_admin == 1,
                user_image_url: "",  
                room_user_id: member.room_user_id
            }));

            const chatRoom = {
                room_id: roomDetails.room_id,
                author_id: roomDetails.creator_id,  
                author_name: roomDetails.creator_name || "Unknown",  
                preview: "TODO",
                is_joined: roomUserId != null,
                current_room_user_id: roomUserId,
                has_password: roomDetails.password != null,
                chat_name: roomDetails.room_name,
                chat_image_url: roomDetails.image_url || "",
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
}

module.exports = RoomUserController;
