const RoomUserModel = require('../models/roomUserModel');
const RoomModel = require('../models/roomModel');
const UserModel = require('../models/userModel');

class RoomUserController {
    constructor(database) {
        this.roomModel = new RoomModel(database);
        this.roomUserModel = new RoomUserModel(database);
        this.userModel = new UserModel(database);
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

                const roomDetails = roomResult.pop();            
    
                const members = await this.roomUserModel.getUsersInRoom(room.room_id);

                const roomUserId = members.find(member => member.user_id === device_id)?.room_user_id || null;
    
                // Step 3: Format member details
                const memberDetails = members.map(member => ({
                    name: member.name,  
                    is_admin: member.is_admin == 1,
                    user_image_url: "",  
                    room_user_id: member.room_user_id
                }));
    
                // Step 4: Format the room data
                const chatRoom = {
                    room_id: room.room_id,
                    author_id: roomDetails.creator_id,  // Assuming `creator_id` is the author ID
                    author_name: roomDetails.creator_name || "Unknown",  // Find the author's name from members
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
            
            const roomDetails = roomResult.pop();

            let roomUserResult = await this.roomUserModel.create(room_id, device_id, 1);
            if (!roomUserResult) { throw new Error("Failed to create room"); } 
        
            const members = await this.roomUserModel.getUsersInRoom(roomDetails.room_id);

            const roomUserId = members.find(member => member.user_id === device_id)?.room_user_id || null;

            // Step 3: Format member details
            const memberDetails = members.map(member => ({
                name: member.name,  
                is_admin: member.is_admin == 1,
                user_image_url: "",  
                room_user_id: member.room_user_id
            }));

            // Step 4: Format the room data
            const chatRoom = {
                room_id: roomDetails.room_id,
                author_id: roomDetails.creator_id,  // Assuming `creator_id` is the author ID
                author_name: roomDetails.creator_name || "Unknown",  // Find the author's name from members
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
