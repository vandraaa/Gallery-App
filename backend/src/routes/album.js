const express = require("express");
const router = express.Router();

const album = require("../controllers/albumController");

router.post('/create', album.createAlbum);
router.patch('/add', album.addPhotoToAlbum);
router.get('/:id', album.getAlbumsByUserId);
router.get('/photos/:id', album.getPhotoNotExist);
router.get('/photo/:id', album.getPhotoFromAlbumId);
router.delete('/remove', album.removeFromAlbum);
router.delete('/delete', album.deleteAlbum);
router.patch('/update/:id', album.updateAlbum);

module.exports = router