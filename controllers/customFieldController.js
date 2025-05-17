const customFieldModel = require("../models/customFieldModel");
const customFieldOptionModel = require("../models/customFieldOptionModel");

exports.addCustomField = async (req, res) => {
  try {
    const fieldData = req.body;
    const fieldId = await customFieldModel.createCustomField(fieldData);

    if (fieldData.options && Array.isArray(fieldData.options)) {
      await customFieldOptionModel.createOptions(fieldId, fieldData.options);
    }

    res.status(201).json({ message: "Field created successfully", fieldId });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Failed to create field" });
  }
};

exports.deleteCustomField = async (req, res) => {
  try {
    const { fieldId } = req.params;
    await customFieldModel.deleteCustomField(fieldId);
    res.status(200).json({ message: "Field and options deleted successfully" });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Failed to delete field" });
  }
};

exports.getCustomFields = async (req, res) => {
  try {
    const { appointmentId } = req.params;
    const fields = await customFieldModel.getCustomFieldsByAppointmentId(
      appointmentId
    );
    res.status(200).json(fields);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Failed to fetch fields" });
  }
};

exports.updateCustomField = async (req, res) => {
  try {
    const { fieldId } = req.params;
    const updatedData = req.body;

    await customFieldModel.updateCustomField(fieldId, updatedData);

    const typesWithOptions = ["dropdown", "checkbox", "radio"];
    if (
      typesWithOptions.includes(updatedData.type) &&
      updatedData.options &&
      Array.isArray(updatedData.options)
    ) {
      await customFieldOptionModel.deleteOptionsByFieldId(fieldId);
      await customFieldOptionModel.createOptions(fieldId, updatedData.options); 
      
    }

    res.status(200).json({ message: "Field and options updated successfully" });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Failed to update field" });
  }
};

exports.getCustomFieldById = async (req, res) => {
  try {
    const { fieldId } = req.params;
    const field = await customFieldModel.getCustomFieldById(fieldId);

    if (!field) {
      return res.status(404).json({ error: "Field not found" });
    }

    res.status(200).json(field);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Failed to fetch field" });
  }
};


exports.updateFieldOrder = async (req, res) => {
  try {
    const { fieldId } = req.params;
    const { display_order } = req.body;
    await customFieldModel.updateFieldOrder(fieldId, display_order);
      res.status(200).json({ message: "Field order updated successfully" });
  } catch (err) {
    res.status(500).json({ error: "Failed to update field order" });
  }
};
