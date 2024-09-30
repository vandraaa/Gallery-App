const prisma = require("../config/database");
const bcrypt = require("bcrypt");
const jwt = require("jsonwebtoken");

const hashPassword = async (password) => {
  const length = 10;
  try {
    const hashedPassword = await bcrypt.hash(password, length);
    return hashedPassword;
  } catch (error) {
    console.error("Error hashing password:", error);
    throw new Error("Failed to hash password");
  }
};

const login = async (req, res) => {
  try {
    const user = await prisma.user.findUnique({
      where: {
        email: req.body.email,
      },
    });

    if (!user) {
      return res.status(400).send({ message: "User not found" });
    }

    const isPasswordCorrect = await bcrypt.compare(
      req.body.password,
      user.password
    );

    const payload = {
      userId: user.userId,
      name: user.name,
      email: user.email,
    };

    const jwtSecretKey = process.env.JWT_SECRET;

    if (isPasswordCorrect) {
      const token = jwt.sign(payload, jwtSecretKey,{ expiresIn: "7d" }
      );
      return res.status(200).send({
        message: "Login Successfully",
        data: payload,
        token,
      });
    } else {
      return res.status(400).send({ message: "Invalid password" });
    }
  } catch (error) {
    console.error(error);
    res.status(400).send({ message: "Login Failed" });
  }
};

const getUsersById = async (req, res) => {
  try {
    const id = req.query.id;
    const users = await prisma.user.findUnique({
      where: {
        userId: parseInt(id),
      },
    });

    if (!users) {
      return res.status(400).send({ message: "User not found" });
    }

    res.status(200).send({ message: "Get Users Successfully", data: users });
  } catch (error) {
    console.error(error);
    res.status(400).send({ message: "Get Users Failed" });
  }
};

const createUser = async (req, res) => {
  try {
    const newUser = req.body;

    const emailExist = await prisma.user.findUnique({
      where: {
        email: newUser.email,
      },
    });

    if (emailExist) {
      return res.status(400).send({ message: "Email already exist" });
    }

    const hashedPassword = await hashPassword(newUser.password);

    const user = await prisma.user.create({
      data: {
        name: newUser.name,
        email: newUser.email,
        password: hashedPassword,
      },
    });

    res.status(201).send({ message: "Create User Successfully", data: user });
  } catch (error) {
    console.error(error);
    res.status(500).send({ message: "Failed to create user" });
  }
};

const updateUser = async (req, res) => {
  try {
    const updateData = req.body;

    const emailExist = await prisma.user.findUnique({
      where: {
        email: updateData.email,
      },
    });

    if(!emailExist) {
      return res.status(400).send({ message: "Email already exist" });
    }

    const hashedPassword = await hashPassword(updateData.password);

    const jwtSecretKey = process.env.JWT_SECRET;

    const user = await prisma.user.update({
      where: {
        email: updateData.email,
      },
      data: {
        name: updateData.name,
        email: updateData.email,
        password: hashedPassword,
        updatedAt: new Date(),
      },
      include: {
        user: true,
      },
    });

    const token = jwt.sign(
      {
        userId: user.userId,
        name: user.name,
        email: user.email,
      },
      jwtSecretKey,
      { expiresIn: "7d" }
    );

    res.status(200).send({ message: "Update User Successfully", data: user, token });
  } catch (error) {
    console.error(error);
    res.status(500).send({ message: "Failed to update user" });
  }
};

const deleteUser = async (req, res) => {
  try {
    const userId = req.params.id;
    await prisma.user.delete({
      where: {
        userId: parseInt(userId),
      },
    });
    res.status(200).send({ message: "Delete User Successfully" });
  } catch (error) {
    console.error(error);
    res.status(500).send({ message: "Failed to delete user" });
  }
};

module.exports = { createUser, getUsersById, updateUser, deleteUser, login };
