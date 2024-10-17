import prisma from '../config/database';
import admin from 'firebase-admin'; 
import serviceAccount from '../../serviceAccountKey.json';

const storageBucket = process.env.FIREBASE_STORAGE_BUCKET;

if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    storageBucket: storageBucket
  });
}

export default async function deletePhotoInTrash(req, res) {
  // Cron job authorization (optional)
  const authHeader = req.headers['authorization'];
  if (!authHeader || authHeader !== `Bearer ${process.env.CRON_SECRET}`) {
    return res.status(401).json({ error: 'Unauthorized' });
  }

  const now = new Date();
  const fiveMinutesAgo = new Date(now.getTime() - 5 * 60 * 1000);
  console.log('Scheduled function started at', now);

  try {
    const photos = await prisma.photo.findMany({
      where: {
        isDelete: true,
        deletedAt: {
          gte: fiveMinutesAgo
        }
      }
    });

    const bucket = admin.storage().bucket();
    for (const photo of photos) {
      const fileName = photo.url.split('/o/')[1].split('?')[0];
      const decodedFileName = decodeURIComponent(fileName);
      const file = bucket.file(decodedFileName);

      await file.delete();
      console.log(`File deleted: ${decodedFileName}`);
      
      await prisma.photo.delete({
        where: {
          photoId: photo.photoId
        }
      });
      console.log(`Photo record deleted: ${photo.photoId}`);
    }

    return res.status(200).json({ message: 'Photos deleted successfully' });
  } catch (e) {
    console.error('Error in cron job:', e);
    return res.status(500).json({ error: 'Failed to delete photos' });
  }
}