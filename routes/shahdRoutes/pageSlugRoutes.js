const express = require('express');
const router = express.Router();
const db = require('../../config/db');

// GET /api/page-id/:slug
router.get('/page-id/:slug', async (req, res) => {
  const pageSlug = req.params.slug;

  try {
    const query = `
      SELECT page_id 
      FROM scheduling_pages 
      WHERE page_slug = ? AND is_active = TRUE
    `;
    db.query(query, [pageSlug], (err, results) => {
      if (err) {
        console.error('❌ Database error:', err.message);
        return res.status(500).json({ message: 'Database error' });
      }

      if (results.length === 0) {
        return res.status(404).json({ message: 'Page not found' });
      }
      console.error('✅✅page_id'+ results[0].page_id );
      console.error('✅✅pageSlug'+ pageSlug );

      return res.json({ page_id: results[0].page_id });
    });
  } catch (err) {
    console.error('❌ Server error:', err.message);
    res.status(500).json({ message: 'Server error' });
  }
});

module.exports = router;
