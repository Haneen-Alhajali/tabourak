// controllers/authController.js
const userModel = require("../models/userModel");
const bcrypt = require("bcrypt");
const jwt = require("jsonwebtoken");
const { findUserByEmail } = require("../models/userModel");

exports.register = async (req, res) => {
  console.log('DEBUG: Entering register function');
  const { name, email, password } = req.body;
  console.log('DEBUG: Received registration data:', { name, email, password: password ? '***' : null });

  if (!name.includes(" ")) {
    console.log('DEBUG: Validation failed - name does not contain space');
    return res
      .status(400)
      .send({ message: "Please enter full name (first and last)." });
  }

  const [first_name, ...rest] = name.trim().split(" ");
  const last_name = rest.join(" ");
  console.log('DEBUG: Parsed name:', { first_name, last_name });

  try {
    console.log('DEBUG: Starting password hashing');
    const hashedPassword = await bcrypt.hash(password, 10);
    console.log('DEBUG: Password hashed successfully');

    const userData = {
      first_name,
      last_name,
      email,
      password: hashedPassword,
      role: "staff",
    };
    console.log('DEBUG: User data prepared:', { ...userData, password: '***' });

    userModel.createUser(userData, (err, result) => {
      if (err) {
        console.log('DEBUG: User creation error:', err);
        return res.status(500).send(err);
      }

      console.log('DEBUG: User created successfully, ID:', result.insertId);
      const token = jwt.sign({ id: result.insertId }, process.env.JWT_SECRET, {
        expiresIn: "1h",
      });
      console.log('DEBUG: JWT token generated');

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
    console.log('DEBUG: Registration try-catch error:', err);
    res.status(500).send({ message: "Error in server" });
  }
};

exports.loginUser = (req, res) => {
  console.log('DEBUG: Entering loginUser function');
  const { email, password } = req.body;
  console.log('DEBUG: Login attempt for email:', email);

  findUserByEmail(email, async (err, user) => {
    if (err) {
      console.log('DEBUG: Database error during login:', err);
      return res.status(500).json({ message: "error in server" });
    }
    if (!user) {
      console.log('DEBUG: No user found for email:', email);
      return res.status(401).json({ message: "invalid email" });
    }

    console.log('DEBUG: User found, comparing passwords');
    const isMatch = await bcrypt.compare(password, user.password_hash);
    if (!isMatch) {
      console.log('DEBUG: Password comparison failed');
      return res.status(401).json({ message: "invalid password" });
    }

    console.log('DEBUG: Password match, generating token');
    const token = jwt.sign({ id: user.id }, process.env.JWT_SECRET, {
      expiresIn: "5h", //      expiresIn: "1h",
    });
    console.log('DEBUG: Login successful for user ID:', user.id);

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


// // controllers/authController.js
// const userModel = require("../models/userModel");
// const bcrypt = require("bcrypt");
// const jwt = require("jsonwebtoken");
// const { findUserByEmail } = require("../models/userModel");

// exports.register = async (req, res) => {
//   const { name, email, password } = req.body;

//   if (!name.includes(" ")) {
//     return res
//       .status(400)
//       .send({ message: "Please enter full name (first and last)." });
//   }

//   const [first_name, ...rest] = name.trim().split(" ");
//   const last_name = rest.join(" ");

//   try {
//     const hashedPassword = await bcrypt.hash(password, 10);

//     const userData = {
//       first_name,
//       last_name,
//       email,
//       password: hashedPassword,
//       role: "staff",
//     };

//     userModel.createUser(userData, (err, result) => {
//       if (err) return res.status(500).send(err);

//       const token = jwt.sign({ id: result.insertId }, process.env.JWT_SECRET, {
//         expiresIn: "1h",
//       });

//       res.status(201).json({
//         message: "User registered!",
//         token,
//         user: {
//           id: result.insertId,
//           name: `${first_name} ${last_name}`,
//           email,
//         },
//       });
//     });
//   } catch (err) {
//     res.status(500).send({ message: "Error in server" });
//   }
// };

// exports.loginUser = (req, res) => {
//   const { email, password } = req.body;
//   findUserByEmail(email, async (err, user) => {
//     if (err) return res.status(500).json({ message: "error in server" });
//     if (!user) return res.status(401).json({ message: "invalid email" });

//     const isMatch = await bcrypt.compare(password, user.password_hash);
//     if (!isMatch) return res.status(401).json({ message: "invalid password" });

//     const token = jwt.sign({ id: user.id }, process.env.JWT_SECRET, {
//       expiresIn: "1h",
//     });

//     res.status(200).json({
//       message: "login succfully",
//       token,
//       user: {
//         id: user.id,
//         name: user.name,
//         email: user.email,
//         phone: user.phone,
//       },
//     });
//   });
// };
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






// const { createUser, findUserByEmail } = require('../models/userModel');
// const jwt = require('jsonwebtoken');
// const bcrypt = require('bcrypt');

// // Registration function
// const register = async (req, res) => {
//   try {
//     const user = await createUser(req.body);
//     const token = jwt.sign({ user_id: user.insertId }, process.env.JWT_SECRET);
//     res.status(201).json({ token });
//   } catch (err) {
//     console.error('Registration error:', err);
//     res.status(400).send('Registration failed');
//   }
// };

// // Login function
// const login = async (req, res) => {
//   try {
//     const { email, password } = req.body;
//     const user = await findUserByEmail(email);
    
//     if (!user) return res.status(401).send('Invalid email');
    
//     const isMatch = await bcrypt.compare(password, user.password_hash);
//     if (!isMatch) return res.status(401).send('Invalid password');
    
//     const token = jwt.sign({ user_id: user.user_id }, process.env.JWT_SECRET);
//     res.json({ 
//       token,
//       user: {
//         id: user.user_id,
//         name: `${user.first_name} ${user.last_name}`,
//         email: user.email
//       }
//     });
//   } catch (err) {
//     console.error('Login error:', err);
//     res.status(500).send('Server error');
//   }
// };

// module.exports = {
//   register,
//   login
// };