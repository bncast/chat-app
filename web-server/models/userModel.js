// models/userModel.js

class UserModel {
    constructor(database) {
        this.database = database;
    }

    // Create a new user
    async createUser(user_id, display_name) {
        const sql = 'INSERT INTO User (user_id, display_name) VALUES (?, ?)';
        const values = [user_id, display_name];
        return this.database.query(sql, values);
    };

    // Get a user by ID
    async getUserById(user_id) {
        const sql = 'SELECT * FROM User WHERE user_id = ?';
        const values = [user_id];
        return this.database.query(sql, values);
    };

    // Update a user by ID
    async updateUserById(user_id, display_name) {
        const sql = 'UPDATE User SET display_name = ? WHERE user_id = ?';
        const values = [display_name, user_id];
        return this.database.query(sql, values);
    };

    async getAllUsers() {
        const sql = 'SELECT * FROM User';
        return this.database.query(sql);
    };

}
// Export the CRUD functions
module.exports = UserModel;