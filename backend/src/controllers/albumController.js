const prisma = require("../config/database");

const createAlbum = async (req, res) => {
  try {
    const { userId, title, description, photos } = req.body;

    if (!photos || photos.length === 0) {
      return res.status(400).send({ message: "Photos are required" });
    }

    const album = await prisma.album.create({
      data: {
        userId: parseInt(userId),
        title: title,
        description: description ? description : null,
        photos: {
          connect: photos.map((photo) => ({ photoId: parseInt(photo) })),
        },
      },
    });

    res.status(201).send({ message: "Create Album Successfully", data: album });
  } catch (error) {
    console.log(error);
    res.status(500).send({ message: "Failed to create album" });
  }
};

const addPhotoToAlbum = async (req, res) => {
  try {
    const { albumId, photoId } = req.body;

    const isAdded = await prisma.album.findFirst({
      where: {
        albumId: parseInt(albumId),
        photos: {
          some: {
            photoId: parseInt(photoId),
          },
        },
      },
    });

    if (isAdded) {
      return res.status(400).send({ message: "Photo already added to album" });
    }

    const album = await prisma.photo.update({
      where: {
        photoId: parseInt(photoId),
      },
      data: {
        album: {
          connect: {
            albumId: parseInt(albumId),
          },
        },
      },
    });

    res
      .status(200)
      .send({ message: "Add photo to album successfully", data: album });
  } catch (error) {
    console.log(error);
    res.status(500).send({ message: "Failed to add photo to album" });
  }
};

const getAlbumsByUserId = async (req, res) => {
  try {
    const userId = req.params.id;

    const albums = await prisma.album.findMany({
      where: {
        userId: parseInt(userId),
      },
      orderBy: {
        createdAt: "desc",
      },
      include: {
        photos: {
          take: 1,
          orderBy: {
            createdAt: "desc",
          },
          where: {
            isDelete: false,
          },
        },
        _count: {
          select: {
            photos: true,
          },
        },
      },
    });

    res.status(200).send({ message: "Get albums successfully", data: albums });
  } catch (error) {
    console.log(error);
    res.status(500).send({ message: "Failed to get albums" });
  }
};

const getPhotoNotExist = async (req, res) => {
  const albumId = req.params.id;
  const userId = req.query.userId;

  try {
    const photos = await prisma.photo.findMany({
      where: {
        userId: parseInt(userId),
        album: {
          none: {
            albumId: parseInt(albumId),
          },
        },
      },
    });

    res.status(200).send({ message: "Get photo successfully", data: photos });
  } catch (e) {
    console.log(e);
    res.status(500).send({ message: "Failed to get photo" });
  }
}

const getPhotoFromAlbumId = async (req, res) => {
  try {
    const albumId = req.params.id;

    const photos = await prisma.album.findFirst({
      where: {
        albumId: parseInt(albumId),
      },
      include: {
        photos: {
          orderBy: {
            createdAt: "desc",
          },
          where: {
            isDelete: false,
          },
        },
        _count: {
          select: {
            photos: true,
          },
        },
      },
    });

    res
      .status(200)
      .send({ message: "Get photos from album successfully", data: photos });
  } catch (error) {
    console.log(error);
    res.status(500).send({ message: "Failed to get albums" });
  }
};

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
            albumId: parseInt(albumId),
          },
        },
      },
    });

    res
      .status(200)
      .send({ message: "Remove photo from album successfully", data: album });
  } catch (error) {
    console.log(error);
    res.status(500).send({ message: "Failed to remove photo from album" });
  }
};

const deleteAlbum = async (req, res) => {
  try {
    const albumId = req.query.id;

    const album = await prisma.album.delete({
      where: {
        albumId: parseInt(albumId),
      },
      include: {
        photos: true,
      },
    });

    res.status(200).send({ message: "Delete album successfully", data: album });
  } catch (error) {
    console.log(error);
    res.status(500).send({ message: "Failed to delete album" });
  }
};

const updateAlbum = async (req, res) => {
  try {
    const albumId = req.params.id;
    const { title, description } = req.body;

    const album = await prisma.album.update({
      where: {
        albumId: parseInt(albumId),
      },
      data: {
        title: title,
        description: description ? description : null,
      },
    });

    res.status(200).send({ message: "Update album successfully", data: album });
  } catch (e) {
    console.log(e);
    res.status(500).send({ message: "Failed to update album" });
  }
}

module.exports = {
  createAlbum,
  addPhotoToAlbum,
  getAlbumsByUserId,
  getPhotoNotExist,
  getPhotoFromAlbumId,
  removeFromAlbum,
  deleteAlbum,
  updateAlbum
};
