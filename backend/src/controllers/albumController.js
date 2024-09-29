const prisma = require("../config/database");

const createAlbum = async (req, res) => {
    try {
        const { userId, title, description } = req.body;

        const album = await prisma.album.create({
            data: {
                userId: parseInt(userId),
                title: title,
                description: description ? description : null
            }
        });

        res.status(201).send({ message: "Create Album Successfully", data: album });
    } catch (error) {
        console.log(error);
        res.status(500).send({ message: "Failed to create album" });
    }
}

const addPhotoToAlbum = async (req, res) => {
    try {
        const { albumId, photoId } = req.body;

        const album = await prisma.photo.update({
            where: {
                photoId: parseInt(photoId),
            },
            data: {
                album: {
                    connect: {
                        albumId: parseInt(albumId),
                    }
                }
            }
        })

        res.status(200).send({ message: "Add photo to album successfully", data: album });
    } catch (error) {
        console.log(error);
        res.status(500).send({ message: "Failed to add photo to album" });
    }
}

const getAlbumsByUserId = async (req, res) => {
    try {
        const userId = req.query.id;

        const albums = await prisma.album.findMany({
            where: {
                userId: parseInt(userId),
            },
            include: {
                photos: true
            }
        })

        res.status(200).send({ message: "Get albums successfully", data: albums });
    } catch (error) {
        console.log(error);
        res.status(500).send({ message: "Failed to get albums" });
    }
}

const removeFromAlbum = async (req, res) => {
    try {
        const albumId = req.query.id;
        const photoId = req.query.photoId;

        const album = await prisma.photo.update({
            where: {
                photoId: parseInt(photoId),
            },
            data: {
                album: {
                    disconnect: {
                        albumId: parseInt(albumId)
                    }
                }
            }
        })

        res.status(200).send({ message: "Remove photo from album successfully", data: album });
    } catch (error) {
        console.log(error);
        res.status(500).send({ message: "Failed to remove photo from album" });
    }
}

const deleteAlbum = async (req, res) => {
    try {
        const albumId = req.query.id;

        const album = await prisma.album.delete({
            where: {
                albumId: parseInt(albumId),
            },
            include: {
                photos: true
            }
        })

        res.status(200).send({ message: "Delete album successfully", data: album });
    } catch (error) {
        console.log(error);
        res.status(500).send({ message: "Failed to delete album" });
    }
}


module.exports ={
    createAlbum,
    addPhotoToAlbum,
    getAlbumsByUserId,
    removeFromAlbum,
    deleteAlbum
}