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
        // const sign = crypto.createSign('SHA256');
        // sign.update(token);
        // sign.end();
        // return sign.sign(this.privateKey, 'base64');
    }
    
    verifyToken(token) {
        // const verify = crypto.createVerify('SHA256');
        // publicDecript.
        // verify.update(signature);
        // verify.end();
        // return verify.verify(this.publicKey, token, 'base64');
        try {
            const result = Buffer.from(crypto.publicDecrypt(this.publicKey, Buffer.from(token, 'base64')), 'utf8')
            return true
        } catch {
            return false
        }
    }    
}

module.exports = CryptHelper