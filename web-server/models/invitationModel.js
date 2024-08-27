class InvitationModel {
    constructor(db) {
        this.db = db;
    }

    async getAll(user_id) {
        const sql = `
            SELECT 
                UserInvitation.invitation_id,
                UserInvitation.user_id,
                UserInvitation.room_id,
                UserInvitation.is_invalid,
                UserInvitation.created_at,
                UserInvitation.updated_at,
                Room.room_name,
                Room.image_url,
                Inviter.display_name AS inviter_name
            FROM UserInvitation
            JOIN Room ON UserInvitation.room_id = Room.room_id
            JOIN User Inviter ON UserInvitation.created_by = Inviter.user_id
            WHERE 
                UserInvitation.is_invalid = 0 
                AND UserInvitation.user_id = ?

        `;
        const values = [user_id];
        return this.db.query(sql, values);
    }

    async sendInvitation(user_id, room_id, created_by) {
        const sql = `
            INSERT INTO UserInvitation (user_id, room_id, created_by, is_invalid)
            VALUES (?, ?, ?, 0)
        `;
        const values = [user_id, room_id, created_by];
        return this.db.query(sql, values);
    }

    async getByUserIdAndRoomId(user_id, room_id) {
        const sql = `
            SELECT * 
            FROM UserInvitation
            WHERE user_id = ? AND room_id = ? AND is_invalid = 0
        `;
        const values = [user_id, room_id];
        return this.db.query(sql, values);
    }

    async setInvitationInvalid(invitation_id) {
        const sql = `
            UPDATE UserInvitation
            SET is_invalid = 1
            WHERE invitation_id = ?
        `;
        const values = [invitation_id];
        return this.db.query(sql, values);
    }

    async checkExistingInvitation(invitee_device_id, room_id) {
        const sql = `
            SELECT * 
            FROM UserInvitation 
            WHERE user_id = ? 
            AND room_id = ? 
            AND is_invalid = 0
        `;
        const values = [invitee_device_id, room_id];
        return this.db.query(sql, values);
    }
}

module.exports = InvitationModel;
