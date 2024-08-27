// userController.js
const UserModel = require('../models/userModel');

class UserController {
    constructor(database) {
        this.userModel = new UserModel(database);
    }

    async getRandomProfileImageUrl(req) {
        const randomNumber = Math.floor(Math.random() * 21) + 1; // Random number between 1 and 20
        const imageName = `profile${randomNumber}.png`;
        const imageUrl = `/public/images/${imageName}`;
        return imageUrl;
    }

    async setUser(req, res) {
        try {
            const { name, device_id } = req.body;

            let userResult = await this.userModel.getUserById(device_id);
            let user = userResult[0];
            let result;

            let imageUrl
            
            if (userResult.length > 0) {
                result = await this.userModel.updateUserById(device_id, name);
                imageUrl = user.image_url
                if (!result) throw new Error("Failed to update user");
            } else {
                imageUrl = await this.getRandomProfileImageUrl(req);
                result = await this.userModel.createUser(device_id, name, imageUrl);
                if (!result) throw new Error("Failed to create user");
            }

            let imagePath = `${req.protocol}://${req.get('host')}/` + imageUrl;
            
            res.json({
                user: {
                    device_id: device_id,
                    user_image_url: imagePath
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
                user_image_url: `${req.protocol}://${req.get('host')}/` + member.image_url,  
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
