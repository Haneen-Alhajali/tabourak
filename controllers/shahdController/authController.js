const userModel = require("../../models/shahdModels/userModel");
const bcrypt = require("bcrypt");
const jwt = require("jsonwebtoken");
const { findUserByEmail } = require("../../models/shahdModels/userModel");
const { verifyGoogleToken } = require("./googleAuthController");
const { use } = require("../../routes/shahdRoutes/authRoutes");

exports.register = async (req, res) => {
  const { name, email, password } = req.body;
  const [first_name, ...rest] = name.trim().split(" ");
  const last_name = rest.join(" ");
  console.log("inside the regiter");

  if (!name.includes(" ")) {
    return res
      .status(400)
      .send({ message: "Please enter full name (first and last)." });
  }

  findUserByEmail(email, async (err, user) => {
    if (err) return res.status(500).json({ message: "error in server" });
    if (!user) {
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

          const token = jwt.sign(
            { id: result.insertId },
            process.env.JWT_SECRET,
            {
              expiresIn: "1h",
            }
          );

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
    } else {
      return res.status(401).json({ message: "invalid email" });
    }
  });
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
        id: user.user_id,
        name: user.name,
        email: user.email,
        phone: user.phone,
      },
    });
  });
};

const { OAuth2Client } = require("google-auth-library");
const client = new OAuth2Client(process.env.GOOGLE_CLIENT_ID_WEB);

exports.verifyGoogleToken = async (idToken) => {
  try {
    const ticket = await client.verifyIdToken({
      idToken,
      audience: process.env.GOOGLE_CLIENT_ID_WEB,
    });
    return ticket.getPayload();
  } catch (error) {
    console.error("Google token verification error:", error);
    throw new Error("Invalid Google token");
  }
};

exports.googleLogin = async (req, res) => {
  try {
    const { token: idToken, email, name } = req.body;
    console.log("Google login id token :" + email + name + idToken);

    if (!idToken || !email) {
      return res.status(400).json({
        message: "ID token and email are required",
      });
    }

    console.log("Google login id token to verfiy know :");

    const payload = await verifyGoogleToken(idToken);

    console.log("Google login id token to verfiy doneeeeeeee :");

    if (payload.email !== email) {
      return res.status(401).json({
        message: "Email does not match token",
      });
    }

    findUserByEmail(email, async (err, user) => {
      if (err) {
        return res.status(500).json({
          message: "Database error",
          error: err.message,
        });
      }

      if (user) {
        const jwtToken = jwt.sign(
          { id: user.user_id },
          process.env.JWT_SECRET,
          { expiresIn: "1h" }
        );

        return res.json({
          message: "Login successful",
          token: jwtToken,
          user: {
            id: user.user_id,
            name: user.first_name || name,
            email: user.email,
          },
        });
      } else {
        return res.status(500).json({
          message: "Email not found . Please register first.",
        });
      }
    });
  } catch (error) {
    console.error("Google login error:", error);
    return res.status(401).json({
      message: "Authentication failed",
      error: error.message,
    });
  }
};
