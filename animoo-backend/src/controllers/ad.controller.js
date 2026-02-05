const Ad = require('../models/Ad');


exports.addAd = async (req, res) => {
  try {
    const {
      name,
      description,
      price,
      category,
      age,
      vaccinated,
      healthStatus,
      location,
    } = req.body;

    if (
      !name ||
      !description ||
      !price ||
      !category ||
      !req.files?.images ||
      !req.files?.idCard
    ) {
      return res.status(400).json({ message: 'Missing fields' });
    }

    const images = req.files.images.map(f => f.filename);
    const idCardImage = req.files.idCard[0].filename;

    const ad = await Ad.create({
      name,
      description,
      price,
      category,
      images,
      idCardImage,

      
      age: age || null,
      vaccinated: vaccinated === 'true',
      healthStatus: healthStatus || null,
      location: location || null,

      user: req.user.id,      
      status: 'pending',      
    });

    res.status(201).json(ad);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};


exports.getAnimals = async (req, res) => {
  try {
    const { category } = req.query;

    const filter = { status: 'approved' };

    if (category) {
      filter.category = category;
    }

    const ads = await Ad.find(filter).sort({ createdAt: -1 });
    res.json(ads);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};


exports.getMyAds = async (req, res) => {
  try {
    const ads = await Ad.find({ user: req.user.id })
      .sort({ createdAt: -1 });

    res.json(ads);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};


exports.getPendingAds = async (req, res) => {
  try {
    const ads = await Ad.find({ status: 'pending' })
      .sort({ createdAt: -1 });

    res.json(ads);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

exports.approveAd = async (req, res) => {
  try {
    const ad = await Ad.findByIdAndUpdate(
      req.params.id,
      { status: 'approved' },
      { new: true }
    );

    if (!ad) return res.status(404).json({ message: 'Not found' });

    res.json(ad);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

exports.rejectAd = async (req, res) => {
  try {
    const ad = await Ad.findByIdAndUpdate(
      req.params.id,
      { status: 'rejected' },
      { new: true }
    );

    if (!ad) return res.status(404).json({ message: 'Not found' });

    res.json(ad);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }


};


exports.updateAd = async (req, res) => {
  try {
    console.log(' UPDATE AD HIT');
    console.log('PARAM ID:', req.params.id);
    console.log('BODY:', req.body);

    const ad = await Ad.findById(req.params.id);

    if (!ad) {
      return res.status(404).json({ message: 'Ad not found' });
    }

    
    if (ad.user.toString() !== req.user._id.toString()) {
      return res.status(403).json({ message: 'Not allowed' });
    }
if (ad.status !== 'pending') {
  return res.status(403).json({
    message: 'You cannot edit this ad after approval or rejection',
  });
}

  
    Object.keys(req.body).forEach((key) => {
      ad[key] = req.body[key];
    });

    
    if (req.files?.images?.length) {
      ad.images = req.files.images.map((f) => f.filename);
    }

    await ad.save();

    res.json({
      message: 'Ad updated successfully',
      ad,
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: err.message });
  }
};
exports.deleteAd = async (req, res) => {
  try {
    const { id } = req.params;

    const ad = await Ad.findById(id);

    if (!ad) {
      return res.status(404).json({ message: 'Ad not found' });
    }

    
    if (ad.user.toString() !== req.user.id) {
      return res.status(403).json({ message: 'Not allowed' });
    }

    await ad.deleteOne();

    res.json({ message: 'Ad deleted successfully' });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};


exports.getAdStats = async (req, res) => {
  try {
    const pending = await Ad.countDocuments({ status: 'pending' });
    const approved = await Ad.countDocuments({ status: 'approved' });
    const rejected = await Ad.countDocuments({ status: 'rejected' });

    res.json({
      pending,
      approved,
      rejected,
    });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};


exports.getApprovedAds = async (req, res) => {
  try {
    const ads = await Ad.find({ status: 'approved' })
      .sort({ createdAt: -1 });
    res.json(ads);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};
