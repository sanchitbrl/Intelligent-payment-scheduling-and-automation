const { PrismaClient } = require('@prisma/client');

const prisma = new PrismaClient();

// Frequency to days mapping (matches Flutter enum)
const FREQUENCY_DAYS = {
  daily: 1,
  weekly: 7,
  monthly: 30,
  quarterly: 90,
};

// GET /api/payments — all user payments
async function getAllPayments(req, res) {
  try {
    const payments = await prisma.payment.findMany({
      where: { userId: req.userId },
      orderBy: { nextDueDate: 'asc' },
    });
    res.json(payments);
  } catch (err) {
    console.error('Get payments error:', err);
    res.status(500).json({ error: 'Failed to fetch payments.' });
  }
}

// GET /api/payments/upcoming — active upcoming payments
async function getUpcoming(req, res) {
  try {
    const payments = await prisma.payment.findMany({
      where: { userId: req.userId, isActive: true },
      orderBy: { nextDueDate: 'asc' },
    });
    res.json(payments);
  } catch (err) {
    console.error('Get upcoming error:', err);
    res.status(500).json({ error: 'Failed to fetch upcoming payments.' });
  }
}

// GET /api/payments/summary — dashboard stats
async function getSummary(req, res) {
  try {
    const payments = await prisma.payment.findMany({
      where: { userId: req.userId, isActive: true },
    });

    const now = new Date();
    const today = new Date(now.getFullYear(), now.getMonth(), now.getDate());

    let dueSoon = 0;
    let overdue = 0;
    let monthlyTotal = 0;

    for (const p of payments) {
      const due = new Date(p.nextDueDate.getFullYear(), p.nextDueDate.getMonth(), p.nextDueDate.getDate());
      const diffDays = Math.floor((due - today) / (1000 * 60 * 60 * 24));
      if (diffDays < 0) overdue++;
      if (diffDays <= 7) dueSoon++;
      monthlyTotal += p.amount;
    }

    res.json({
      count: payments.length,
      due_soon: dueSoon,
      overdue,
      monthly_total: monthlyTotal,
    });
  } catch (err) {
    console.error('Summary error:', err);
    res.status(500).json({ error: 'Failed to get summary.' });
  }
}

// GET /api/payments/history — payment history
async function getHistory(req, res) {
  try {
    const history = await prisma.paymentHistory.findMany({
      where: { payment: { userId: req.userId } },
      include: { payment: { select: { name: true, category: true } } },
      orderBy: { paidAt: 'desc' },
      take: 50,
    });
    res.json(history);
  } catch (err) {
    console.error('History error:', err);
    res.status(500).json({ error: 'Failed to fetch history.' });
  }
}

// POST /api/payments — create payment
async function createPayment(req, res) {
  try {
    const { name, amount, recipient, category, frequency, nextDueDate, remindDaysBefore } = req.body;

    const payment = await prisma.payment.create({
      data: {
        userId: req.userId,
        name,
        amount: parseFloat(amount),
        recipient,
        category,
        frequency,
        nextDueDate: new Date(nextDueDate),
        remindDaysBefore: remindDaysBefore ?? 3,
      },
    });

    res.status(201).json(payment);
  } catch (err) {
    console.error('Create payment error:', err);
    res.status(500).json({ error: 'Failed to create payment.' });
  }
}

// PUT /api/payments/:id — update payment
async function updatePayment(req, res) {
  try {
    const id = parseInt(req.params.id);

    // Verify ownership
    const existing = await prisma.payment.findFirst({
      where: { id, userId: req.userId },
    });
    if (!existing) return res.status(404).json({ error: 'Payment not found.' });

    const { name, amount, recipient, category, frequency, nextDueDate, remindDaysBefore, isActive } = req.body;

    const payment = await prisma.payment.update({
      where: { id },
      data: {
        ...(name !== undefined && { name }),
        ...(amount !== undefined && { amount: parseFloat(amount) }),
        ...(recipient !== undefined && { recipient }),
        ...(category !== undefined && { category }),
        ...(frequency !== undefined && { frequency }),
        ...(nextDueDate !== undefined && { nextDueDate: new Date(nextDueDate) }),
        ...(remindDaysBefore !== undefined && { remindDaysBefore }),
        ...(isActive !== undefined && { isActive }),
      },
    });

    res.json(payment);
  } catch (err) {
    console.error('Update payment error:', err);
    res.status(500).json({ error: 'Failed to update payment.' });
  }
}

// DELETE /api/payments/:id
async function deletePayment(req, res) {
  try {
    const id = parseInt(req.params.id);

    const existing = await prisma.payment.findFirst({
      where: { id, userId: req.userId },
    });
    if (!existing) return res.status(404).json({ error: 'Payment not found.' });

    await prisma.payment.delete({ where: { id } });
    res.json({ message: 'Payment deleted.' });
  } catch (err) {
    console.error('Delete payment error:', err);
    res.status(500).json({ error: 'Failed to delete payment.' });
  }
}

// POST /api/payments/:id/pay — mark as paid
async function markPaid(req, res) {
  try {
    const id = parseInt(req.params.id);

    const payment = await prisma.payment.findFirst({
      where: { id, userId: req.userId },
    });
    if (!payment) return res.status(404).json({ error: 'Payment not found.' });

    const days = FREQUENCY_DAYS[payment.frequency] || 30;
    const nextDue = new Date(payment.nextDueDate);
    nextDue.setDate(nextDue.getDate() + days);

    // Create history record and update next due date in a transaction
    await prisma.$transaction([
      prisma.paymentHistory.create({
        data: {
          paymentId: id,
          amount: payment.amount,
          status: 'paid',
        },
      }),
      prisma.payment.update({
        where: { id },
        data: { nextDueDate: nextDue },
      }),
    ]);

    const updated = await prisma.payment.findUnique({ where: { id } });
    res.json(updated);
  } catch (err) {
    console.error('Mark paid error:', err);
    res.status(500).json({ error: 'Failed to mark as paid.' });
  }
}

// POST /api/payments/:id/skip — skip payment
async function skipPayment(req, res) {
  try {
    const id = parseInt(req.params.id);

    const payment = await prisma.payment.findFirst({
      where: { id, userId: req.userId },
    });
    if (!payment) return res.status(404).json({ error: 'Payment not found.' });

    const days = FREQUENCY_DAYS[payment.frequency] || 30;
    const nextDue = new Date(payment.nextDueDate);
    nextDue.setDate(nextDue.getDate() + days);

    await prisma.$transaction([
      prisma.paymentHistory.create({
        data: {
          paymentId: id,
          amount: payment.amount,
          status: 'skipped',
        },
      }),
      prisma.payment.update({
        where: { id },
        data: { nextDueDate: nextDue },
      }),
    ]);

    const updated = await prisma.payment.findUnique({ where: { id } });
    res.json(updated);
  } catch (err) {
    console.error('Skip payment error:', err);
    res.status(500).json({ error: 'Failed to skip payment.' });
  }
}

// GET /api/payments/suggestions — AI-powered pattern detection
async function getSuggestions(req, res) {
  try {
    // 1. Fetch history for this user
    const history = await prisma.paymentHistory.findMany({
      where: { payment: { userId: req.userId } },
      include: { payment: true },
      orderBy: { paidAt: 'desc' },
    });

    // 2. Group history by payment name
    const groups = history.reduce((acc, item) => {
      const key = item.payment.name;
      if (!acc[key]) acc[key] = [];
      acc[key].push(item);
      return acc;
    }, {});

    const suggestions = [];

    // 3. AI Heuristic: detect recurring patterns
    for (const name in groups) {
      const txns = groups[name];

      // Need at least 2 payments to detect a pattern
      if (txns.length >= 2) {
        const daysOfMonth = txns.map(t => new Date(t.paidAt).getDate());

        // Calculate average day of month
        const avgDay = Math.round(
          daysOfMonth.reduce((a, b) => a + b, 0) / daysOfMonth.length
        );

        // Check consistency: all payments within ±3 days of average
        const isConsistent = daysOfMonth.every(
          day => Math.abs(day - avgDay) <= 3
        );

        if (isConsistent) {
          suggestions.push({
            name: name,
            suggestedDay: avgDay,
            amount: txns[0].amount,
            category: txns[0].payment.category,
            frequency: txns[0].payment.frequency,
            paymentCount: txns.length,
            message: `You pay "${name}" around day ${avgDay} every month. Automate it?`,
          });
        }
      }
    }

    res.json(suggestions);
  } catch (err) {
    console.error('Suggestions error:', err);
    res.status(500).json({ error: 'Failed to analyze payment patterns.' });
  }
}

module.exports = {
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
};
