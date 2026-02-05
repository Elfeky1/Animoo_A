const mongoose = require('mongoose');

const adSchema = new mongoose.Schema(
  {
    name: String,
    description: String,
    price: String,
    category: {
      type: String,
      enum: ['dogs', 'cats', 'food'],
    },

    images: [String],
    idCardImage: String,

    age: Number,
    vaccinated: Boolean,
    healthStatus: String,
    location: String,

    
    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },
    status: {
  type: String,
  enum: ['pending', 'approved', 'rejected'],
  default: 'pending',
},

  
    isApproved: {
      type: Boolean,
      default: false,
    },
  },
  { timestamps: true }
);

module.exports = mongoose.model('Ad', adSchema);
