const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const User = require('../models/User');
const transporter = require('../config/mail');
const generateOtp = require('../utils/generateOtp');


exports.sendOtp = async (req, res) => {
  try {
    const { email, phone } = req.body;

    if (!email) {
      return res.status(400).json({ message: 'Email is required' });
    }

    let user = await User.findOne({ email });
    if (!user) user = new User({ email, phone });

    const otp = generateOtp();

    user.otpCode = otp;
    user.otpExpires = Date.now() + 5 * 60 * 1000;
    await user.save();

    await transporter.sendMail({
      from: `"Animoo" <${process.env.MAIL_USER}>`,
      to: email,
      subject: 'Your OTP Code',
      html: `<h2>Your OTP is: ${otp}</h2><p>Valid for 5 minutes</p>`,
    });

    res.status(200).json({ message: 'OTP sent successfully' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Failed to send OTP' });
  }
};


exports.verifyOtp = async (req, res) => {
  const { email, otp } = req.body;

  const user = await User.findOne({ email });
  if (!user) return res.status(400).json({ message: 'User not found' });

  if (
    user.otpCode !== otp ||
    !user.otpExpires ||
    user.otpExpires < Date.now()
  ) {
    return res.status(400).json({ message: 'Invalid or expired OTP' });
  }

  user.isVerified = true;
  user.otpCode = null;
  user.otpExpires = null;
  await user.save();

  res.json({ message: 'OTP verified' });
};


exports.register = async (req, res) => {
  const { name, email, phone, password } = req.body;

  const hashed = await bcrypt.hash(password, 10);

  const user = await User.findOneAndUpdate(
    { email },
    { name, phone, password: hashed, isVerified: true },
    { new: true }
  );

  res.status(201).json({ message: 'User registered' });
};


exports.login = async (req, res) => {
  const { email, password } = req.body;

  const user = await User.findOne({ email });
  if (!user) return res.status(400).json({ message: 'Invalid credentials' });

  if (user.isBanned) {
  return res.status(403).json({
    message: "Your account has been banned. Please contact support."
  });
}

  const match = await bcrypt.compare(password, user.password);
  if (!match) return res.status(400).json({ message: 'Invalid credentials' });

  const token = jwt.sign({ id: user._id,role: user.role, }, process.env.JWT_SECRET, {
    expiresIn: '7d',
  });

  res.json({ token ,
    role: user.role,
  });
};


exports.resetPassword = async (req, res) => {
  const { email, password } = req.body;

  const hashed = await bcrypt.hash(password, 10);

  await User.findOneAndUpdate({ email }, { password: hashed });

  res.json({ message: 'Password updated' });
};
