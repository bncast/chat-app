
const RoomModel = require('../models/roomModel');
const RoomUserModel = require('../models/roomUserModel');
const UserModel = require('../models/userModel');

class RoomController {
    constructor(database) {
        this.roomModel = new RoomModel(database);
        this.roomUserModel = new RoomUserModel(database);
        this.userModel = new UserModel(database);
    }

    async create(req, res) {
        try {
            const { name, device_id, password } = req.body;

            let author_name;

            let userResult = await this.userModel.getUserById(device_id)
            if (userResult.length > 0) {
                let user = userResult.pop();
                author_name = user.display_name;
            } else {
                throw new Error("User not found.");
            }
            
            let roomResult = await this.roomModel.create(name, device_id, password);
            if (!roomResult) { throw new Error("Failed to create room"); } 

            let roomId = roomResult.insertId;
            
            let roomUserResult = await this.roomUserModel.create(roomId, device_id, 1);
            if (!roomUserResult) { throw new Error("Failed to create room user"); } 

            let roomUserId = roomUserResult.insertId;

            let response = {
                chatroom : {
                    room_id: roomId,
                    author_id: roomUserId,
                    author_name: author_name,
                    preview: "",
                    is_joined: true,
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

    // async getAll(req, res) {
    //     try {
    //         let roomResults = await this.roomModel.getAll();
    //         if (!roomResults) { throw new Error("Failed to create room"); } 

    //         let chatRoomArray = roomResults.map((element) => {
    //             return {
    //                 room_id: element.room_id,
    //                 author_id: element.creator_id,
    //                 author_name: "Author1",
    //                 preview: "Test preview",
    //                 is_joined: false,
    //                 has_password: element.password != null,
    //                 chat_name: element.room_name,
    //                 chat_image_url: "",
    //                 member_details: []
    //             }
    //           });
              
    //         let response = {
    //             chat_rooms: chatRoomArray,
    //             success: 1,
    //             error: {
    //                 code: "000",
    //                 message: ""
    //             }
    //         }

    //         res.json(response);
    //     } catch (err) {
    //         console.log("NINOTEST", err);
    //         res.status(500).json({
    //             success: 0,
    //             error: {
    //                 code: "002",
    //                 message: err.message || "An error occurred while processing the request"
    //             }
    //         });    
    //     }
    // }
}

module.exports = RoomController;
