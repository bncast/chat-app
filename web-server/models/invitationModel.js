class InvitationModel {
    constructor(db) {
        this.db = db;
    }

    async getAll() {
        const sql = `
            SELECT 
                UserInvitation.invitation_id,
                UserInvitation.user_id,
                UserInvitation.room_id,
                UserInvitation.is_invalid,
                UserInvitation.created_at,
                UserInvitation.updated_at,
                Room.room_name,
                Inviter.display_name AS inviter_name
            FROM UserInvitation
            JOIN Room ON UserInvitation.room_id = Room.room_id
            JOIN User Inviter ON UserInvitation.created_by = Inviter.user_id
            WHERE UserInvitation.is_invalid = 0
        `;
        return this.db.query(sql);
    }

    // Send a new invitation
    async sendInvitation(user_id, room_id, created_by) {
        const sql = `
            INSERT INTO UserInvitation (user_id, room_id, created_by, is_invalid)
            VALUES (?, ?, ?, 0)
        `;
        const values = [user_id, room_id, created_by];
        return this.db.query(sql, values);
    }

}

module.exports = InvitationModel;
