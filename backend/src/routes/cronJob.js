const express = require("express");
const router = express.Router();

const cron = require('../controllers/cronJobController');

router.post('/', cron.cronJob);

module.exports = router