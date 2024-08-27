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
            WHERE message_id = ?
        `;
        const values = [message_id];
        return this.db.query(sql, values);
    }

    // Get messages in a room
    async getMessagesByRoom(room_id, room_user_id) {
        const sql = `
        SELECT 
            m1.message_id,
            m1.room_user_id AS author_id,
            m1.content,
            m1.created_at,
            m1.updated_at,
            (m1.room_user_id = ?) AS is_current_user,
            User.image_url AS author_image,
            m2.room_user_id AS reply_to_user,
            m2.content AS reply_to_content
        FROM 
            Message m1
        JOIN 
            RoomUser ON m1.room_user_id = RoomUser.room_user_id
        JOIN 
            User ON RoomUser.user_id = User.user_id
        LEFT JOIN
            Message m2 ON m2.message_id = m1.reply_to_id
        WHERE 
            RoomUser.room_id = ? AND m1.deleted_at IS NULL
        ORDER BY 
            m1.created_at ASC
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

    async getLatestMessage(room_id) {
        const sql = `
            SELECT u.display_name, m.content
            FROM Message m
            JOIN RoomUser ru ON m.room_user_id = ru.room_user_id
            JOIN User u ON ru.user_id = u.user_id
            WHERE ru.room_id = ?
            ORDER BY m.created_at DESC
            LIMIT 1;
        `;
        const values = [room_id];
        return this.db.query(sql, values);
    }
}

module.exports = MessageModel;
