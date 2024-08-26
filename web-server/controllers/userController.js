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
            let result = await this.userModel.getAllUsers()

            const formattedResponse = members.map(member => ({
                name: member.name,  
                user_image_url: "",  
                device_id: member.device_id
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
