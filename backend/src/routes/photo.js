const express = require("express");
const router = express.Router();
const { upload } = require("../config/multer");

const photo = require("../controllers/photoController");

router.get('/', photo.getPhotosByUserId);
router.get('/detail', photo.getDetailPhoto);
router.patch('/trash', photo.trash);
router.patch('/favorite', photo.favoritePhoto);
router.delete('/delete', photo.deletePhoto);
router.post('/upload', upload.single('image'), photo.createPhoto);

module.exports = router
