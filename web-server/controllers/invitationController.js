const UserModel = require('../models/userModel');
const InvitationModel = require('../models/invitationModel');

class InvitationController {
    constructor(database) {
        this.invitationModel = new InvitationModel(database);
        this.userModel = new UserModel(database);
    }

    async getAll(req, res) {
        try {
            const { device_id } = req.query;
            
            let userResult = await this.userModel.getUserById(device_id);
            if (userResult.length <= 0) {
                throw new Error("User not found.");
            }
            const invitations = await this.invitationModel.getAll();
           
            const formattedInvitations = invitations.map(invitation => ({
                chat_name: invitation.room_name, // Room name as chat_name
                chat_image_url: "", // Assuming chat_image_url is not available in the current schema, defaulting to empty
                inviter_name: invitation.inviter_name, // Inviter's display name
                room_id: invitation.room_id // Room ID
            }));

            res.json({
                success: 1,
                invitations: formattedInvitations
            });
        } catch (err) {
            console.error("Error fetching invitations:", err);
            res.status(500).json({
                success: 0,
                error: {
                    code: "500",
                    message: "Failed to fetch invitations"
                }
            });
        }
    }

    // Send a new invitation
    async sendInvitation(req, res) {
        try {
            const { device_id, invitee_devicee_id, room_id } = req.body;

            let userResult = await this.userModel.getUserById(device_id);
            if (userResult.length <= 0) {
                throw new Error("User not found.");
            }

            const result = await this.invitationModel.sendInvitation(invitee_devicee_id, room_id, device_id);
            if (result.affectedRows > 0) {
                res.json({
                    success: 1,
                    error: {
                        code: "000",
                        message: ""
                    }
                });
            } else {
                res.status(500).json({
                    success: 0,
                    error: {
                        code: "500",
                        message: "Failed to send invitation"
                    }
                });
            }
        } catch (err) {
            console.error("Error sending invitation:", err);
            res.status(500).json({
                success: 0,
                error: {
                    code: "500",
                    message: "Failed to send invitation"
                }
            });
        }
    }
}

module.exports = InvitationController;
