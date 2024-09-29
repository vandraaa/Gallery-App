const express = require("express");
const router = express.Router();

const album = require("../controllers/albumController");

router.post('/create', album.createAlbum);
router.patch('/add', album.addPhotoToAlbum);
router.get('/', album.getAlbumsByUserId);
router.delete('/remove', album.removeFromAlbum);
router.delete('/delete', album.deleteAlbum);

module.exports = router