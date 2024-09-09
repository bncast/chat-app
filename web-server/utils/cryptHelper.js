let crypto = require('crypto');
let fs = require('fs');

class CryptHelper {
    privateKey = fs.readFileSync('./config/private.pem', 'utf8');
    publicKey = fs.readFileSync('./config/public.pem', 'utf8');

    constructor() {}

    signToken(token) {
        return crypto.privateEncrypt(this.privateKey,
            Buffer.from(token, 'utf8'))
            .toString('base64');
    }
    
    verifyToken(token) {
        try {
            const result = Buffer.from(crypto.publicDecrypt(this.publicKey, Buffer.from(token, 'base64')), 'utf8')
            return true
        } catch {
            return false
        }
    }    
}

module.exports = CryptHelper