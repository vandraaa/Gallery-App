const prisma = require("../config/database");
const multer = require('multer');
const admin = require('firebase-admin');

const serviceAccount = require('../../serviceAccountKey.json');
const storageBucket = process.env.FIREBASE_STORAGE_BUCKET;

admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    storageBucket: storageBucket
});

const uploadImageToFirebase = async (file) => {
    try {
        const bucket = admin.storage().bucket();
        const fileName = `${Date.now()}-${file.originalname}`;
        const fileUpload = bucket.file(`images/${fileName}`);
        
        await fileUpload.save(file.buffer, {
            contentType: file.mimetype,
            resumable: false
        })

        const url = `https://firebasestorage.googleapis.com/v0/b/${storageBucket}/o/images%2F${encodeURIComponent(fileName)}?alt=media`;
        return url;
    } catch (error) {
        console.error(error);
        throw new Error("Failed to upload image");
    }
}

const createPhoto = async (req, res) => {
    try {
        const { userId, description, albumId } = req.body;
        const file = req.file;

        if (!file) {
            return res.status(400).send({ message: "File is required" });
        }

        const filename = file.originalname;
        const sizeInBytes = file.size;

        const formatSizeFile = (bytes) => {
            if (bytes >= 1024 * 1024) {
                return `${(bytes / 1024 / 1024).toFixed(2)} MB`;
            } else {
                return `${(bytes / 1024).toFixed(2)} KB`;
            }
        }

        const imageUrl = await uploadImageToFirebase(file);

        const photo = await prisma.photo.create({
            data: {
                userId: parseInt(userId),
                filename,
                size: formatSizeFile(sizeInBytes),
                url: imageUrl,
                description: description ? description : null,
                albumId: albumId ? parseInt(albumId) : null
            }
        })

        res.status(201).send({ message: "Create Photo Successfully", data: photo });
    } catch (error) {
        console.log(error);
        res.status(500).send({ message: "Failed to create photo" });
    }
}

const getPhotosByUserId = async (req, res) => {
    try {
        const userId = req.query.id;
        const photos = await prisma.photo.findMany({
            where: {
                userId: parseInt(userId),
                isDelete: false
            },
            orderBy: {
                createdAt: 'desc'
            }
        });

        const photosExist = photos.length > 0;
        if (!photosExist) {
            return res.status(400).send({ message: "Photos not found" });
        }

        res.status(200).send({ message: "Get Photos Successfully", data: photos });
    } catch (error) {
        console.log(error);
        res.status(500).send({ message: "Failed to get photos" });
    }
}

const getFavoritePhoto = async (req, res) => {
    try {
        const userId = req.query.id;

        const photos = await prisma.photo.findMany({
            where: {
                userId: parseInt(userId),
                isFavorite: true,
                isDelete: false
            },
            orderBy: {
                createdAt: 'desc'
            }
        });

        const photosExist = photos.length > 0;
        if (!photosExist) {
            return res.status(400).send({ message: "Favorites photos not found" });
        }

        res.status(200).send({ message: "Get Photos Successfully", data: photos });
    } catch (e) {
        console.log(error);
        res.status(500).send({ message: "Failed to get photos" });
    }
}

const getTrashPhoto = async (req, res) => {
    try {
        const userId = req.query.id;

        const photo = await prisma.photo.findMany({
            where: {
                userId: parseInt(userId),
                isDelete: true
            },
            orderBy: {
                createdAt: 'desc'
            }
        });

        const photosExist = photo.length > 0;
        if (!photosExist) {
            return res.status(400).send({ message: "Trash photos not found" });
        }

        res.status(200).send({ message: "Get Photos Successfully", data: photo });
    } catch (error) {
        console.log(error);
        res.status(500).send({ message: "Failed to get photos" });
    }
}

const getDetailPhoto = async (req, res) => {
    try {
        const photoId = req.query.id;
        const userId = req.query.userId;

        const photo = await prisma.photo.findUnique({
            where: {
                userId: parseInt(userId),
                photoId: parseInt(photoId)
            },
            include: {
                user: true
            }
        })

        res.status(200).send({ message: "Get Detail Photo Successfully", data: photo });
    } catch (error) {
        console.log(error);
        res.status(500).send({ message: "Failed to get detail photo" });
    }
}

const deletePhoto = async (req, res) => {
    try {
        const photoId = req.query.id;
        const userId = req.query.userId;

        const photo = await prisma.photo.findUnique({
            where: {
                userId: parseInt(userId),
                photoId: parseInt(photoId),
                isDelete: true,
            }
        })

        if(!photo) {
            return res.status(400).send({ message: "Photo not found" });
        }

        const bucket = admin.storage().bucket();
        const fileName = photo.url.split('/o/')[1].split('?')[0];
        const decodedFileName = decodeURIComponent(fileName);
        const file = bucket.file(decodedFileName);

        await file.delete();

        await prisma.photo.delete({
            where: {
                photoId: parseInt(photoId)
            }
        })

        res.status(200).send({ message: "Delete Photo Successfully" });
    } catch (error) {
        console.log(error);
        res.status(500).send({ message: "Failed to delete photo" });
    }
}

const trash = async (req, res) => {
    try {
        const photoId = req.query.id;
        const userId = req.query.userId;

        const photo = await prisma.photo.findUnique({
            where: {
                userId: parseInt(userId),
                photoId: parseInt(photoId),
            }
        })

        if(!photo) {
            return res.status(400).send({ message: "Photo not found" });
        }

        const data = await prisma.photo.update({
            where: {
                userId: parseInt(userId),
                photoId: parseInt(photoId),
            },
            data: {
                isDelete: !photo.isDelete,
                isFavorite: false,
                albumId: null
            }
        })

        if (photo.isDelete === true) {
            return res.status(200).send({ message: "Successfully restored", data });
        } else {
            return res.status(200).send({ message: "Successfully deleted", data });
        }
    } catch (error) {
        console.log(error);
        res.status(500).send({ message: "Failed to update photo" });
    }
}

const favoritePhoto = async (req, res) => {
    try {
        const photoId = req.query.id;
        const userId = req.query.userId;

        const photo = await prisma.photo.findUnique({
            where: {
                userId: parseInt(userId),
                photoId: parseInt(photoId),
                isDelete: false
            }
        })

        if(!photo) {
            return res.status(400).send({ message: "Photo not found" });
        }

        const data = await prisma.photo.update({
            where: {
                userId: parseInt(userId),
                photoId: parseInt(photoId)
            },
            data: {
                isFavorite: !photo.isFavorite
            }
        })

        if(photo.isFavorite === true) {
            return res.status(200).send({ message: "Successfully unfavorited photo", data });
        } else {
            return res.status(200).send({ message: "Successfully added to favorites", data });
        }
    } catch (error) {
        console.log(error);
        res.status(500).send({ message: "Failed to update photo" });
    }
}

module.exports = { 
    createPhoto, 
    getPhotosByUserId, 
    getDetailPhoto, 
    deletePhoto, 
    trash, 
    favoritePhoto,
    getFavoritePhoto,
    getTrashPhoto
}