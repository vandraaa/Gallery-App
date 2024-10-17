const express = require("express");
const router = express.Router();
const { upload } = require("../config/multer");

const photo = require("../controllers/photoController");

router.get('/', photo.getPhotosByUserId);
router.get('/detail', photo.getDetailPhoto);
router.get('/favorite', photo.getFavoritePhoto);
router.patch('/favorite', photo.favoritePhoto);
router.get('/trash', photo.getTrashPhoto);
router.patch('/trash', photo.trash);
router.delete('/delete', photo.deletePhoto);
router.post('/upload', upload.single('image'), photo.createPhoto);

module.exports = router
