class RoomUserModel {
    constructor(database) {
        this.db = database;  // Create an instance of the Database class
    }

    // Add a user to a room
    async create(room_id, user_id, is_admin = 0) {
        const sql = `
            INSERT INTO RoomUser (room_id, user_id, is_admin, is_deleted, is_muted)
            VALUES (?, ?, ?, ?, ?)
        `;
        const values = [room_id, user_id, is_admin, 0, 0];
        return this.db.query(sql, values);
    }

    // Get all users in a room
    async getUsersInRoom(room_id) {
        const sql = `
            SELECT 
                RoomUser.room_user_id,
                RoomUser.room_id,
                RoomUser.user_id,
                RoomUser.is_admin,
                RoomUser.is_deleted,
                RoomUser.is_muted,
                User.display_name AS name,  -- Get the display_name from Users table
                User.image_url AS user_image_url  -- Get the image_url from Users table
            FROM 
                RoomUser
            JOIN 
                User ON RoomUser.user_id = User.user_id  -- Join with Users table
            WHERE 
                RoomUser.room_id = ? 
                AND RoomUser.is_deleted = 0
        `;

        const values = [room_id];
        return this.db.query(sql, values);
    }

    // Get all rooms a user is in
    async getRoomsForUser(user_id) {
        const sql = 'SELECT * FROM RoomUser WHERE user_id = ? AND is_deleted = 0';
        const values = [user_id];
        return this.db.query(sql, values);
    }

    async getRoomForRoomUserId(room_user_id) {
        const sql = 'SELECT * FROM RoomUser WHERE room_user_id = ? AND is_deleted = 0';
        const values = [room_user_id];
        return this.db.query(sql, values);
    }

    // // Update user status in a room
    // async updateUserStatus(room_id, user_id, is_admin, is_muted) {
    //     const sql = `
    //         UPDATE RoomUsers
    //         SET is_admin = ?, is_muted = ?
    //         WHERE room_id = ? AND user_id = ? AND is_deleted = 0
    //     `;
    //     const values = [is_admin, is_muted, room_id, user_id];
    //     return this.db.query(sql, values);
    // }

    // // Remove a user from a room (soft delete)
    // async removeUserFromRoom(room_id, user_id) {
    //     const sql = `
    //         UPDATE RoomUsers
    //         SET is_deleted = 1
    //         WHERE room_id = ? AND user_id = ?
    //     `;
    //     const values = [room_id, user_id];
    //     return this.db.query(sql, values);
    // }
}

module.exports = RoomUserModel;
