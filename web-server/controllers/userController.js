// userController.js
const UserModel = require('../models/userModel');

class UserController {
    constructor() {
    }

    getRandomProfileImageUrl(req) {
        const randomNumber = Math.floor(Math.random() * 21) + 1; // Random number between 1 and 20
        const imageName = `profile${randomNumber}.png`;
        const imageUrl = `public/images/${imageName}`;
        return imageUrl;
    }

    async login(req, res) {
        try {
            const { username, password, device_id, device_name } = req.body;

            var result = await UserModel.findOne({ where: { username: username, password: password }});
            
            if (result == null) {
                throw new Error("User not found.");
            }

            let imagePath = `${req.protocol}://${req.get('host')}/` + result.image_url;

            // TODO: device management
            
            res.json({
                info: {
                    display_name: result.display_name,
                    username: result.username,
                    image_url: imagePath
                },
                token: "ACCESS_TOKEN_HERE", // TODO:
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

    async setUser(req, res) {
        try {
            const { username, display_name, password } = req.body;

            var result = await UserModel.findOne({ where: { username: username }});
            let imageUrl = this.getRandomProfileImageUrl(req);
            
            if (result == null) {
                result = await UserModel.create({ username: username, display_name: display_name, password: password, image_url: imageUrl });
            } else {
                throw new Error("User already exists.");
            }

            let imagePath = `${req.protocol}://${req.get('host')}/` + imageUrl;
            
            res.json({
                info: {
                    display_name: result.display_name,
                    username: result.username,
                    image_url: imagePath
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
            console.log("NINOTEST");
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
