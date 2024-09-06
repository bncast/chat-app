// userController.js
const crypto = require("crypto");
const { Op } = require('sequelize');
const UserModel = require('../models/userModel');
const UserTokenModel = require('../models/userTokenModel');
const CryptHelper = require('../utils/cryptHelper');
const ImageHelper = require('../utils/imageHelper');

class UserController {
    constructor() {
        this.cryptHelper = new CryptHelper();
    }

    async login(req, res) {
        try {
            const { username, password, device_id, device_name } = req.body;

            var result = await UserModel.findOne({ where: { username: username, password: password }});
            if (result == null) { throw new Error("User not found."); }

            var fetchTokenResult = await UserTokenModel.findOne({ where: { 
                user_id: result.id, 
                access_expiry: { 
                    [Op.gte]: Date.now()
                } 
            } });

            let signedAccessToken
            let signedRefreshToken

            if (fetchTokenResult == null) {
                const accessTokenExpiresAt = new Date(Date.now() + 15 * 60 * 1000); // 15 minutes
                const refreshTokenExpiresAt = new Date(Date.now() + 7 * 24 * 60 * 60 * 1000); // 7 days
                const accessToken = crypto.randomUUID();
                console.log("origin access token:" + accessToken);
                const refreshToken = crypto.randomUUID();
                signedAccessToken = this.cryptHelper.signToken(accessToken);
                signedRefreshToken = this.cryptHelper.signToken(refreshToken);

                var tokenResult = await UserTokenModel.create({
                    access_token: signedAccessToken,
                    refresh_token: signedRefreshToken,
                    user_id: result.id,
                    access_expiry: accessTokenExpiresAt,
                    refresh_expiry: refreshTokenExpiresAt
                });
                if (tokenResult == null) { throw new Error("Failed to create token."); }
                
            } else {
                signedAccessToken = fetchTokenResult.access_token;
                signedRefreshToken = fetchTokenResult.refresh_token;
            }

            // TODO: Manage devices

            res.json({
                info: {
                    display_name: result.display_name,
                    username: result.username,
                    image_url: ImageHelper.getImagePath(req, result.image_url)
                },
                access_token: signedAccessToken, 
                refresh_token: signedRefreshToken,
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

    async token(req, res) {
        try {
            const { refresh_token, password, device_id, device_name } = req.body;

            if (!this.cryptHelper.verifyToken(refresh_token)) {
                return res.status(401).json({ error: 'Invalid token signature' });
            }

            var fetchTokenResult = await UserTokenModel.findOne({ where: { 
                refreshToken: refresh_token, 
                refresh_expiry: { 
                    [Op.gte]: Date.now()
                } 
            } });

            

            var result = await UserModel.findOne({ where: { username: username, password: password }});
            if (result == null) { throw new Error("User not found."); }

            var fetchTokenResult = await UserTokenModel.findOne({ where: { 
                user_id: result.id, 
                access_expiry: { 
                    [Op.gte]: Date.now()
                } 
            } });

            let signedAccessToken
            let signedRefreshToken

            if (fetchTokenResult == null) {
                const accessTokenExpiresAt = new Date(Date.now() + 15 * 60 * 1000); // 15 minutes
                const refreshTokenExpiresAt = new Date(Date.now() + 7 * 24 * 60 * 60 * 1000); // 7 days
                const accessToken = crypto.randomUUID();
                console.log("origin access token:" + accessToken);
                const refreshToken = crypto.randomUUID();
                signedAccessToken = this.cryptHelper.signToken(accessToken);
                signedRefreshToken = this.cryptHelper.signToken(refreshToken);

                var tokenResult = await UserTokenModel.create({
                    access_token: signedAccessToken,
                    refresh_token: signedRefreshToken,
                    user_id: result.id,
                    access_expiry: accessTokenExpiresAt,
                    refresh_expiry: refreshTokenExpiresAt
                });
                if (tokenResult == null) { throw new Error("Failed to create token."); }
                
            } else {
                signedAccessToken = fetchTokenResult.access_token;
                signedRefreshToken = fetchTokenResult.refresh_token;
            }

            // TODO: Manage devices

            res.json({
                info: {
                    display_name: result.display_name,
                    username: result.username,
                    image_url: ImageHelper.getImagePath(req, result.image_url)
                },
                access_token: signedAccessToken, 
                refresh_token: signedRefreshToken,
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

    async register(req, res) {
        try {
            const { username, display_name, password } = req.body;

            var result = await UserModel.findOne({ where: { username: username }});
            let imageUrl = ImageHelper.getRandomProfileImageUrl(req);
            
            if (result == null) {
                result = await UserModel.create({ username: username, display_name: display_name, password: password, image_url: imageUrl });
            } else {
                throw new Error("User already exists.");
            }

            const accessToken = UUID().toString();
            const refreshToken = UUID().toString();
            const signedAccessToken = this.cryptHelper.signToken(accessToken);
            const signedRefreshToken = this.cryptHelper.signToken(refreshToken);
 
            res.json({
                info: {
                    display_name: result.display_name,
                    username: result.username,
                    image_url: ImageHelper.getImagePath(req, imageUrl)
                },
                access_token: signedAccessToken, 
                refresh_token: signedRefreshToken,
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
            const accessToken = req.headers['authorization'];
            if (!accessToken) return res.status(401).json({ error: 'Access token required' });

            if (!this.cryptHelper.verifyToken(accessToken)) {
                return res.status(401).json({ error: 'Invalid token signature' });
            }

            var fetchTokenResult = await UserTokenModel.findOne({ where: { 
                access_token: accessToken, 
                access_expiry: { 
                    [Op.gte]: Date.now()
                } 
            } });

            const { device_id, room_id } = req.query;
            

            throw new Error("TODO: Create request, get users not in room, move function to room user");

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
            res.status(500).json({ 
                error: {
                    code: "500",
                    message: err.message
                } 
            });
        }
    }
}

module.exports = UserController;
