// firebaseConfig.js
const admin = require('firebase-admin');
const serviceAccount = require('../../serviceAccountKey.json');
const { initializeApp } = require("firebase/app");
const { getStorage } = require("firebase/storage"); // Ubah dari firebase/analytics ke firebase/storage untuk storage
// Pastikan Anda telah menginstal firebase-admin dan firebase SDK menggunakan npm

// Konfigurasi Firebase Admin SDK
const storageBucket = process.env.FIREBASE_STORAGE_BUCKET;

if (!admin.apps.length) {
    admin.initializeApp({
        credential: admin.credential.cert(serviceAccount),
        storageBucket: storageBucket
    });
}

// Konfigurasi Firebase JavaScript SDK
const firebaseConfig = {
    apiKey: process.env.FIREBASE_API_KEY,
    authDomain: process.env.FIREBASE_AUTH_DOMAIN,
    projectId: process.env.FIREBASE_PROJECT_ID,
    storageBucket: process.env.FIREBASE_STORAGE_BUCKET,
    messagingSenderId: process.env.FIREBASE_MESSAGING_SENDER_ID,
    appId: process.env.FIREBASE_APP_ID,
    measurementId: process.env.FIREBASE_MEASUREMENT_ID
};

// Inisialisasi Firebase
const app = initializeApp(firebaseConfig);
const storage = getStorage(app); // Gunakan getStorage dari firebase/storage

// Ekspor admin dan storage untuk digunakan di file lain
module.exports = { admin, storage };
