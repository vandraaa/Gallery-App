const express = require("express");
const router = express.Router();

const user = require("../controllers/userController");

router.get("/", user.getUsersById);
router.post("/", user.createUser);
router.post("/login", user.login);
router.patch("/", user.updateUser);
router.delete("/:id", user.deleteUser);

module.exports = router
