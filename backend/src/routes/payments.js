const express = require('express');
const { body } = require('express-validator');
const authenticate = require('../middleware/auth');
const {
  getAllPayments,
  getUpcoming,
  getSummary,
  getHistory,
  createPayment,
  updatePayment,
  deletePayment,
  markPaid,
  skipPayment,
  getSuggestions,
} = require('../controllers/paymentController');

const router = express.Router();

// All routes require authentication
router.use(authenticate);

// GET routes
router.get('/', getAllPayments);
router.get('/upcoming', getUpcoming);
router.get('/summary', getSummary);
router.get('/history', getHistory);
router.get('/suggestions', getSuggestions);

// POST create
router.post(
  '/',
  [
    body('name').trim().notEmpty().withMessage('Payment name is required'),
    body('amount').isFloat({ min: 0.01 }).withMessage('Valid amount is required'),
    body('recipient').trim().notEmpty().withMessage('Recipient is required'),
    body('category').isIn(['utility', 'subscription', 'education', 'loan', 'insurance', 'other']).withMessage('Invalid category'),
    body('frequency').isIn(['daily', 'weekly', 'monthly', 'quarterly']).withMessage('Invalid frequency'),
    body('nextDueDate').isISO8601().withMessage('Valid date is required'),
  ],
  async (req, res) => {
    const { validationResult } = require('express-validator');
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ error: errors.array()[0].msg });
    }
    await createPayment(req, res);
  }
);

// PUT update
router.put('/:id', updatePayment);

// DELETE
router.delete('/:id', deletePayment);

// Actions
router.post('/:id/pay', markPaid);
router.post('/:id/skip', skipPayment);

module.exports = router;