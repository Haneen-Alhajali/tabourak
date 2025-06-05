const express = require('express');
const router = express.Router();
const db = require('../../config/db');

// GET /api/page-id/:slug
router.get('/page-id/:slug', async (req, res) => {
  console.log('🚀 استُقبل طلب GET على /api/page-id/:slug');

  const pageSlug = req.params.slug;
  console.log('🚀 استُقبل طلب GET على /api/page-id/:slug');
  console.log(`🔎 Slug المستلم من الرابط: ${pageSlug}`);

  try {
    const query = `
      SELECT page_id 
      FROM scheduling_pages 
      WHERE page_slug = ? AND is_active = TRUE
    `;

    console.log('📡 تنفيذ استعلام SQL للبحث عن الصفحة...');
    console.log(`📝 الاستعلام: ${query}`);
    console.log(`📦 القيم المستخدمة: [${pageSlug}]`);

    db.query(query, [pageSlug], (err, results) => {
      if (err) {
        console.error('❌ حدث خطأ في قاعدة البيانات:', err.message);
        return res.status(500).json({ message: '❌ Database error' });
      }

      console.log('✅ تم تنفيذ الاستعلام بنجاح');
      console.log(`📊 عدد النتائج: ${results.length}`);

      if (results.length === 0) {
        console.warn('⚠️ لا توجد صفحة مطابقة للـ slug المحدد');
        return res.status(404).json({ message: 'Page not found' });
      }

      const pageId = results[0].page_id;
      console.log('🎯 تم العثور على page_id:', pageId);


      res.setHeader('Content-Type', 'application/json');
      return res.json({ page_id: pageId });
    });
  } catch (err) {
    console.error('🔥 خطأ غير متوقع في الخادم:', err.message);
    res.status(500).json({ message: 'Server error' });
  }
});

module.exports = router;
