const router = require('express').Router();
const controller = require('../controllers/auth.controller');

router.post('/send-otp', controller.sendOtp);
router.post('/verify-otp', controller.verifyOtp);
router.post('/register', controller.register);
router.post('/login', controller.login);
router.post('/reset-password', controller.resetPassword);


module.exports = router;
