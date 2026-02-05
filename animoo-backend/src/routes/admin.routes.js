const express = require('express');
const router = express.Router();

const adminController = require('../controllers/admin.controller');
const auth = require('../../middleware/auth');
const admin = require('../../middleware/admin');


router.get('/users', auth, admin, adminController.getUsers);


router.put('/users/:id/ban', auth, admin, adminController.toggleBan);


router.put('/users/:id/role', auth, admin, adminController.changeRole);




module.exports = router;
