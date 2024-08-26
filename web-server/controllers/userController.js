// userController.js
const UserModel = require('../models/userModel');

class UserController {
    constructor(database) {
        this.userModel = new UserModel(database);
    }

    async setUser(req, res) {
        try {
            const { name, device_id } = req.body;

            let user = await this.userModel.getUserById(device_id)
            let result;
            
            if (user.length > 0) {
                result = await this.userModel.updateUserById(device_id, name);
                if (!result) throw new Error("Failed to update user");
            } else {
                result = await this.userModel.createUser(device_id, name);
                if (!result) throw new Error("Failed to create user");
            }

            res.json({
                user: {
                    device_id: device_id,
                    user_image_url: ""
                },
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
                    code: "002",
                    message: err.message || "An error occurred while processing the request"
                }
            });    
        }
    }

    async getUsers(req, res) {
        try {
            const { device_id, room_id } = req.query;
            
            let userResult = await this.userModel.getUserById(device_id);
            if (userResult.length <= 0) {
                throw new Error("User not found.");
            }

            let result = await this.userModel.getUsersNotInRoom(room_id);

            const formattedResponse = result.map(member => ({
                name: member.display_name,  
                user_image_url: "",  
                device_id: member.user_id
            }));

            if (result) {
                res.json({
                    users: formattedResponse,
                    success: 1,
                    error: {
                        code: "000",
                        message: ""
                    }
                });
            } else {
                throw new Error("No result.")
            }
            
        } catch (err) {
            res.status(500).json({ error: err.message });
        }
    }
}

module.exports = UserController;
