class MessageModel {
    constructor(db) {
        this.db = db;
    }

    // Create a new message
    async createMessage(room_user_id, content, reply_to_id = null) {
        const sql = `
            INSERT INTO Message (room_user_id, content, created_at, reply_to_id)
            VALUES (?, ?, NOW(), ?)
        `;
        const values = [room_user_id, content, reply_to_id];
        return this.db.query(sql, values);
    }

    // Get message by ID
    async getMessageById(message_id) {
        const sql = `
            SELECT * FROM Message 
            WHERE message_id = ? AND deleted_at IS NULL
        `;
        const values = [message_id];
        return this.db.query(sql, values);
    }

    // Get messages in a room
    async getMessagesByRoom(room_id, room_user_id) {
        const sql = `
        SELECT 
            Message.message_id,
            Message.room_user_id AS author_id,
            Message.content,
            Message.created_at,
            Message.updated_at,
            (Message.room_user_id = ?) AS is_current_user
        FROM 
            Message
        JOIN 
            RoomUser ON Message.room_user_id = RoomUser.room_user_id
        WHERE 
            RoomUser.room_id = ? AND Message.deleted_at IS NULL
        ORDER BY 
            Message.created_at ASC
    `;
        const values = [room_user_id, room_id];
        return this.db.query(sql, values);
    }

    // Update a message
    async updateMessage(message_id, content) {
        const sql = `
            UPDATE Message 
            SET content = ?, updated_at = NOW() 
            WHERE message_id = ? AND deleted_at IS NULL
        `;
        const values = [content, message_id];
        return this.db.query(sql, values);
    }

    // Soft delete a message
    async deleteMessage(message_id) {
        const sql = `
            UPDATE Message 
            SET deleted_at = NOW() 
            WHERE message_id = ?
        `;
        const values = [message_id];
        return this.db.query(sql, values);
    }
}

module.exports = MessageModel;
