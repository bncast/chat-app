const UserModel = require('../models/userModel');
const RoomUserModel = require('../models/roomUserModel');
const RoomModel = require('../models/roomModel');
const InvitationModel = require('../models/invitationModel');
const MessageModel = require('../models/messageModel');

class InvitationController {
    constructor(database) {
        this.invitationModel = new InvitationModel(database);
        this.userModel = new UserModel(database);
        this.roomUserModel = new RoomUserModel(database);
        this.roomModel = new RoomModel(database);
        this.messageModel = new MessageModel(database);
    }

    async getAll(req, res) {
        try {
            const { device_id } = req.query;
            
            let userResult = await this.userModel.getUserById(device_id);
            if (userResult.length <= 0) {
                throw new Error("User not found.");
            }

            const invitations = await this.invitationModel.getAll(device_id);
           
            const formattedInvitations = invitations.map(invitation => ({
                chat_name: invitation.room_name, // Room name as chat_name
                chat_image_url: `${req.protocol}://${req.get('host')}/` + invitation.image_url,
                inviter_name: invitation.inviter_name, // Inviter's display name
                room_id: invitation.room_id // Room ID
            }));

            res.json({
                success: 1,
                invitations: formattedInvitations
            });
        } catch (err) {
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
    async send(req, res) {
        try {
            const { device_id, invitee_device_id, room_id } = req.body;

            let userResult = await this.userModel.getUserById(device_id);
            if (userResult.length <= 0) {
                throw new Error("User not found.");
            }

            // Check if an invitation already exists for the invitee in the same room
            let existingInvitation = await this.invitationModel.checkExistingInvitation(invitee_device_id, room_id);
            if (existingInvitation.length > 0) {
                return res.status(409).json({
                    success: 0,
                    error: {
                        code: "409",
                        message: "Invitation already exists."
                    }
                });
            }
            
            const result = await this.invitationModel.sendInvitation(invitee_device_id, room_id, device_id);
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
            res.status(500).json({
                success: 0,
                error: {
                    code: "500",
                    message: "Failed to send invitation"
                }
            });
        }
    }

    async accept(req, res) {
        try {
            const { device_id, room_id } = req.body;

            let userResult = await this.userModel.getUserById(device_id);
            if (userResult.length <= 0) {
                throw new Error("User not found.");
            }

            // Check if the user has an invitation for the room
            const invitation = await this.invitationModel.getByUserIdAndRoomId(device_id, room_id);
            
            if (invitation.length > 0) {
                // If invitation exists, set it to invalid

                let invitationResult = invitation[0];
                const result = await this.invitationModel.setInvitationInvalid(invitationResult.invitation_id);

                if (result.affectedRows === 0) {
                    return res.status(500).json({
                        success: 0,
                        error: {
                            code: "500",
                            message: "Failed to set the invitation as invalid.",
                        },
                    });
                }

                const roomResult = await this.roomModel.getByIdByPassed(room_id);
                if (roomResult.length <= 0) { throw new Error("Room not found."); }
                
                const roomDetails = roomResult[0];

                let roomUserResult = await this.roomUserModel.createRoomUser(room_id, device_id);
                if (!roomUserResult) { throw new Error("Failed to create room"); } 
            
                const members = await this.roomUserModel.getUsersInRoom(room_id);
    
                const roomUserId = members.find(member => member.user_id === device_id)?.room_user_id || null;
    
                const memberDetails = members.map(member => ({
                    name: member.name,  
                    is_admin: member.is_admin == 1,
                    user_image_url: "",  
                    room_user_id: member.room_user_id
                }));
    
                let previewResult = await this.messageModel.getLatestMessage(roomDetails.room_id);
                let lastMessage = previewResult[0];
                
                var preview = "Say hello...";
                if (lastMessage != undefined && lastMessage.display_name != undefined && lastMessage.content != undefined) {
                    preview = lastMessage.display_name + " : " + lastMessage.content;
                }

                const chatRoom = {
                    room_id: roomDetails.room_id,
                    author_id: roomDetails.creator_id,  
                    author_name: roomDetails.creator_name || "Unknown",  
                    preview: preview,
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
                console.log(response);
                return res.json(response);
            } else {
                // If no invitation exists
                return res.status(404).json({
                    success: 0,
                    error: {
                        code: "404",
                        message: "No invitation found for the user and room.",
                    },
                });
            }
        } catch (err) {
            return res.status(500).json({
                success: 0,
                error: {
                    code: "500",
                    message: "An error occurred while invalidating the invitation.",
                },
            });
        }
    }

}

module.exports = InvitationController;
