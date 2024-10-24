const prisma = require("../config/database");
const { admin, storage } = require("../config/firebase");

const cronJob = async () => {
    const now = new Date();
    const fiveMinutesAgo = new Date(now.getTime() - 5 * 60 * 1000);
    console.log("Cron job started at", now);

    try {
      const photos = await prisma.photo.findMany({
        where: {
          isDelete: true,
          deletedAt: {
            gte: fiveMinutesAgo,
          },
        },
      });
      console.log("Photos to delete:", photos);

      const bucket = admin.storage().bucket();
      for (const photo of photos) {
        const fileName = photo.url.split("/o/")[1].split("?")[0];
        const decodedFileName = decodeURIComponent(fileName);
        const file = bucket.file(decodedFileName);

        await file.delete();
        console.log(`File deleted: ${decodedFileName}`);

        await prisma.photo.delete({
          where: {
            photoId: photo.photoId,
          },
        });
        console.log(`Photo record deleted: ${photo.photoId}`);
      }
    } catch (e) {
      console.error("Error in cron job:", e);
    }
};

module.exports = {
  cronJob
};
