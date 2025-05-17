const express = require('express');
const router = express.Router();
const customFieldController = require('../controllers/customFieldController');

router.post('/custom-fields', customFieldController.addCustomField);
router.delete('/custom-fields/:fieldId', customFieldController.deleteCustomField);
router.get('/custom-fields/:appointmentId', customFieldController.getCustomFields);
router.put('/custom-fields/:fieldId', customFieldController.updateCustomField);
router.get('/GETcustom-field/:fieldId', customFieldController.getCustomFieldById);
router.put('/custom-fields/order/:fieldId', customFieldController.updateFieldOrder);

module.exports = router;
