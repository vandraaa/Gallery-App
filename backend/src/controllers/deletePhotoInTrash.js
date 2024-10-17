import { NextResponse } from 'next/server';
import prisma from '../config/database';
import admin from 'firebase-admin'; 
import serviceAccount from '../../serviceAccountKey.json';

const storageBucket = process.env.FIREBASE_STORAGE_BUCKET;

admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    storageBucket: storageBucket
});

export async function GET() {
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
        console.log('Photos to delete:', photos);

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
    } catch (e) {
        console.error('Error in scheduled function:', e);
        return NextResponse.json({ error: 'Failed to delete photos' }, { status: 500 });
    }

    return NextResponse.json({ message: 'Photos deleted successfully' }, { status: 200 });
}
