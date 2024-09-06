// database.js
require('dotenv').config();
const Sequelize = require('sequelize');

class Database {
    constructor() {
        if (Database.instance) {
            return Database.instance;
        }

        this.sequelize = new Sequelize(process.env.DB_NAME, process.env.DB_USER, process.env.DB_PASS, {
            host: process.env.DB_HOST,
            dialect: 'mysql'
        });

        this.connect();

        Database.instance = this;
    }

    static getInstance() {
        if (!Database.instance) {
            Database.instance = new Database();
        }
        return Database.instance;
    }

    async connect() {
        try {
            await this.sequelize.authenticate();
            console.log('Connection has been established successfully.');
          } catch (error) {
            console.error('Unable to connect to the database:', error);
          }
    }

    close() {
        return this.sequelize.close();
    }
}

module.exports = Database;
