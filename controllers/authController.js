const userModel = require("../models/userModel");
const bcrypt = require("bcrypt");
const jwt = require("jsonwebtoken");
const { findUserByEmail } = require("../models/userModel");

exports.register = async (req, res) => {
  const { name, email, password } = req.body;

  if (!name.includes(" ")) {
    return res
      .status(400)
      .send({ message: "Please enter full name (first and last)." });
  }

  const [first_name, ...rest] = name.trim().split(" ");
  const last_name = rest.join(" ");

  try {
    const hashedPassword = await bcrypt.hash(password, 10);

    const userData = {
      first_name,
      last_name,
      email,
      password: hashedPassword,
      role: "staff",
    };

    userModel.createUser(userData, (err, result) => {
      if (err) return res.status(500).send(err);

      const token = jwt.sign({ id: result.insertId }, process.env.JWT_SECRET, {
        expiresIn: "1h",
      });

      res.status(201).json({
        message: "User registered!",
        token,
        user: {
          id: result.insertId,
          name: `${first_name} ${last_name}`,
          email,
        },
      });
    });
  } catch (err) {
    res.status(500).send({ message: "Error in server" });
  }
};

exports.loginUser = (req, res) => {
  const { email, password } = req.body;
  findUserByEmail(email, async (err, user) => {
    if (err) return res.status(500).json({ message: "error in server" });
    if (!user) return res.status(401).json({ message: "invalid email" });

    const isMatch = await bcrypt.compare(password, user.password_hash);
    if (!isMatch) return res.status(401).json({ message: "invalid password" });

    const token = jwt.sign({ id: user.id }, process.env.JWT_SECRET, {
      expiresIn: "1h",
    });

    res.status(200).json({
      message: "login succfully",
      token,
      user: {
        id: user.id,
        name: user.name,
        email: user.email,
        phone: user.phone,
      },
    });
  });
};
/*
exports.oauthLogin = (req, res) => {
  const { email, password } = req.body;
  findUserByEmail(email, async (err, user) => {
    if (err) return res.status(500).json({ message: "error in server" });
    if (!user) return res.status(401).json({ message: "invalid email" });

    const token = jwt.sign({ id: user.id }, process.env.JWT_SECRET, {
      expiresIn: "1h",
    });

    res.status(200).json({
      message: "login succfully",
      token,
      user: {
        id: user.id,
        name: user.name,
        email: user.email,
        phone: user.phone,
      },
    });
  });
};
*/






