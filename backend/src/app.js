const express = require("express");
const bodyParser = require("body-parser");
const PORT = require("./config/server") || 4321;
const cors = require('cors');

const app = express();

app.get("/", (req, res) => {
    res.send("Api Gallery");
});

app.use(cors({
  origin: 'http://localhost:3000'
}));

// parse application/json
app.use(bodyParser.json());

// routes
const userRoutes = require("./routes/user");
const photoRoutes = require("./routes/photo");
const albumRoutes = require("./routes/album");

app.use('/users', userRoutes);
app.use('/photos', photoRoutes);
app.use('/album', albumRoutes);

// const server = app.listen(PORT, () => {
//   console.log(`Server running on port http://localhost:${PORT}`);
// });

// process.on("SIGINT", () => {
//   server.close(() => {
//     console.log("Server Disconnected");
//     process.exit(0);
//   });
// });
