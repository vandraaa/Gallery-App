const multer = require('multer');

const storage = multer.memoryStorage(); // Menyimpan file di memory buffer
const upload = multer({ storage: storage });

module.exports = { upload }