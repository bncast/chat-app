// models/roomModel.js

class RoomModel {
    constructor(database) {
        this.db = database;  // Create an instance of the Database class
    }

    // Create a new room
    async create(room_name, creator_id, password, image_url) {
        const sql = `
            INSERT INTO Room (room_name, creator_id, password, image_url, is_deleted, updated_by, updated_at)
            VALUES (?, ?, ?, ?, ?, ?, ?)
        `;
        const values = [room_name, creator_id, password, image_url, 0, creator_id, new Date()];
        return this.db.query(sql, values);
    }

    // Get all rooms
    async getAll() {
        const sql = `
            SELECT 
                Room.room_id,
                Room.room_name,
                Room.creator_id,
                Room.password,
                Room.image_url,
                Room.is_deleted,
                Room.updated_by,
                Room.updated_at,
                User.display_name AS creator_name  -- Get the display_name from Users table
            FROM 
                Room
            JOIN 
                User ON Room.creator_id = User.user_id  -- Join with Users table
            WHERE 
                Room.is_deleted = 0
        `;
        return this.db.query(sql);
    }

    // Get a room by ID
    async getById(room_id, password) {
        const sql = `
            SELECT 
                Room.room_id,
                Room.room_name,
                Room.creator_id,
                Room.password,
                Room.image_url,
                Room.is_deleted,
                Room.updated_by,
                Room.updated_at,
                User.display_name AS creator_name  -- Get the display_name from Users table
            FROM 
                Room
            JOIN 
                User ON Room.creator_id = User.user_id  -- Join with Users table
            WHERE 
                Room.room_id = ? 
                AND Room.is_deleted = 0
                AND (Room.password IS NULL OR Room.password = ?)
        `;
        const values = [room_id, password];
        return this.db.query(sql, values);
    }

        // Get a room by ID
        async getByIdByPassed(room_id) {
            const sql = `
                SELECT 
                    Room.room_id,
                    Room.room_name,
                    Room.creator_id,
                    Room.password,
                    Room.image_url,
                    Room.is_deleted,
                    Room.updated_by,
                    Room.updated_at,
                    User.display_name AS creator_name  -- Get the display_name from Users table
                FROM 
                    Room
                JOIN 
                    User ON Room.creator_id = User.user_id  -- Join with Users table
                WHERE 
                    Room.room_id = ? 
                    AND Room.is_deleted = 0
            `;
            const values = [room_id];
            return this.db.query(sql, values);
        }

    async updateNameById(room_name, user_id, room_id) {
        const sql = `
            UPDATE Room
            SET room_name = ?, updated_by = ?, updated_at = ?
            WHERE room_id = ? AND is_deleted = 0
        `;
        const values = [room_name, user_id, new Date(), room_id];
        return this.db.query(sql, values);
    }

    // Delete a room by ID (soft delete)
    async deleteById(room_id, updated_by) {
        const sql = `
            UPDATE Room
            SET is_deleted = 1, updated_by = ?, updated_at = ?
            WHERE room_id = ?
        `;
        const values = [updated_by, new Date(), room_id];
        return this.db.query(sql, values);
    }
}

module.exports = RoomModel;
