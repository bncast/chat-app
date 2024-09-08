// userController.js
const crypto = require("crypto");
const { Op } = require('sequelize');
const UserModel = require('../models/userModel');
const UserDeviceModel = require('../models/userDeviceModel');
const UserTokenModel = require('../models/userTokenModel');
const RoomUserModel = require('../models/roomUserModel');
const CryptHelper = require('../utils/cryptHelper');
const ImageHelper = require('../utils/imageHelper');

class UserController {
    constructor() {
        this.cryptHelper = CryptHelper.getInstance();
    }

    async login(req, res) {
        try {
            const { username, password, device_id, device_name } = req.body;
            
            var result = await UserModel.findOne({ where: { username: username, password: password }});
            if (result == null) { throw new Error("User not found"); }
            
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
            
            let findResult = await UserDeviceModel.findOne({ where: { device_id : device_id, user_id: result.id }});

            if (findResult) {
                let userDeviceResult = await UserDeviceModel.update({ device_name: device_name }, { where: { device_id: device_id }});
			    if (userDeviceResult == null) { throw new Error("Failed to update user device."); }
            } else {
                var userDeviceResult = await UserDeviceModel.create({
                    user_id: result.id,
                    device_name: device_name,
                    device_id: device_id
                });
                if (userDeviceResult == null) { throw new Error("Failed to create user device."); }
            }

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
            const { refresh_token } = req.body;

            if (!this.cryptHelper.verifyToken(refresh_token)) {
                return res.status(401).json({ 
                    error: { 
                        code: "401", 
                        message: "Invalid token signature" 
                    } 
                });
            }

            var fetchTokenResult = await UserTokenModel.findOne({ where: { 
                refresh_token: refresh_token, 
                refresh_expiry: { 
                    [Op.gte]: Date.now()
                },
                is_invalid: 0
            } });


            if (fetchTokenResult != null) {
                UserTokenModel.update({ is_invalid: 1 }, { where: { id: fetchTokenResult.id }});

                const accessTokenExpiresAt = new Date(Date.now() + 15 * 60 * 1000); // 15 minutes
                const refreshTokenExpiresAt = new Date(Date.now() + 7 * 24 * 60 * 60 * 1000); // 7 days
                const accessToken = crypto.randomUUID();
                const refreshToken = crypto.randomUUID();
                let signedAccessToken = this.cryptHelper.signToken(accessToken);
                let signedRefreshToken = this.cryptHelper.signToken(refreshToken);

                var tokenResult = await UserTokenModel.create({
                    access_token: signedAccessToken,
                    refresh_token: signedRefreshToken,
                    user_id: fetchTokenResult.user_id,
                    access_expiry: accessTokenExpiresAt,
                    refresh_expiry: refreshTokenExpiresAt
                });
                if (tokenResult == null) { throw new Error("Failed to create token."); }

                res.json({
                    access_token: signedAccessToken, 
                    refresh_token: signedRefreshToken,
                    success: 1,
                    error: {
                        code: "000",
                        message: ""
                    }
                });
                
            } else {
                throw new Error("Refresh token not found.");
            }
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

            const accessTokenExpiresAt = new Date(Date.now() + 15 * 60 * 1000); // 15 minutes
            const refreshTokenExpiresAt = new Date(Date.now() + 7 * 24 * 60 * 60 * 1000); // 7 days
            const accessToken = crypto.randomUUID();
            const refreshToken = crypto.randomUUID();
            let signedAccessToken = this.cryptHelper.signToken(accessToken);
            let signedRefreshToken = this.cryptHelper.signToken(refreshToken);

            var tokenResult = await UserTokenModel.create({
                access_token: signedAccessToken,
                refresh_token: signedRefreshToken,
                user_id: result.id,
                access_expiry: accessTokenExpiresAt,
                refresh_expiry: refreshTokenExpiresAt
            });
            if (tokenResult == null) { throw new Error("Failed to create token."); }
 
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

    static async getAccessTokenError(accessToken) {
        if (!accessToken) { return { 
                error: {
                    code: "401",
                    message: "Access token required"
                } 
            }
        }

        if (!CryptHelper.getInstance().verifyToken(accessToken)) {
            return { error: {
                code: "401",
                message: "Invalid token signature"
            } };
        }

        var fetchTokenResult = await UserTokenModel.findOne({ where: { 
            access_token: accessToken, 
            access_expiry: { 
                [Op.gte]: Date.now()
            } 
        } });
        
        if (fetchTokenResult == null) {
            return { error:{
                code: "401",
                message: "Token not found"
            } };
        }

        return { result : fetchTokenResult };
    }

    async getUsers(req, res) {
        try {
            const accessToken = req.headers['authorization'];
            let tokenCheck = await UserController.getAccessTokenError(accessToken)
            if (tokenCheck.error != null) {
                return res.status(401).json(tokenCheck);
            }

            const { room_id } = req.query;
            
            let roomUserResult = await RoomUserModel.findAll({ where: {room_id: room_id } });
            let roomUserIds = roomUserResult.map((item) => item.user_id);
            let usersResult = await UserModel.findAll({ where: { id: { [Op.not]: roomUserIds }}});

            const formattedResponse = usersResult.map(member => ({
                name: member.display_name,  
                user_image_url: ImageHelper.getImagePath(req, member.image_url), 
                user_id: member.id
            }));

            if (formattedResponse) {
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
