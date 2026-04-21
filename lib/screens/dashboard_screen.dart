import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../services/payment_provider.dart';
import '../widgets/app_theme.dart';
import '../widgets/payment_card.dart';
import 'add_payment_screen.dart';
import 'edit_payment_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PaymentProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(
              child: CircularProgressIndicator(color: AppColors.green));
        }

        final summary = provider.summary;
        final payments = provider.activePayments.take(5).toList();
        final fmt = NumberFormat('#,###');
        final overdue = (summary['overdue'] ?? 0) as int;

        return RefreshIndicator(
          color: AppColors.green,
          onRefresh: provider.load,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.green,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: Text(
                          'eS',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Smart Scheduler',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          'Payment automation',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Summary cards
                Row(
                  children: [
                    _SummaryCard(
                      label: 'Monthly',
                      value: 'Rs ${fmt.format((summary['monthly_total'] ?? 0).toInt())}',
                      sub: 'total',
                      color: AppColors.green,
                    ),
                    const SizedBox(width: 10),
                    _SummaryCard(
                      label: 'Due soon',
                      value: '${summary['due_soon'] ?? 0}',
                      sub: 'this week',
                      color: AppColors.warning,
                    ),
                    const SizedBox(width: 10),
                    _SummaryCard(
                      label: 'Active',
                      value: '${summary['count'] ?? 0}',
                      sub: 'payments',
                      color: AppColors.info,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Overdue alert
                if (overdue > 0) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.danger.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: AppColors.danger.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded,
                            color: AppColors.danger, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '$overdue payment(s) overdue. Pay immediately.',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.danger,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Payments list
                const Text(
                  'Upcoming payments',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                if (payments.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        children: [
                          const Icon(Icons.calendar_today_outlined,
                              size: 48, color: AppColors.textSecondary),
                          const SizedBox(height: 12),
                          const Text(
                            'No payments scheduled yet.\nTap + to add one.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: 160,
                            child: ElevatedButton(
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        const AddPaymentScreen()),
                              ),
                              child: const Text('Add payment'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ...payments.map((p) => PaymentCard(
                        payment: p,
                        onPay: () => _confirmPay(context, provider, p),
                        onEdit: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => EditPaymentScreen(payment: p)),
                        ),
                        onSkip: () => provider.skipPayment(p),
                        onDelete: () =>
                            _confirmDelete(context, provider, p),
                      )),
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmPay(context, PaymentProvider provider, payment) {
    final fmt = NumberFormat('#,###');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm payment'),
        content: Text(
            'Pay Rs ${fmt.format(payment.amount)} to ${payment.name}?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(minimumSize: const Size(80, 36)),
            onPressed: () {
              Navigator.pop(ctx);
              provider.payNow(payment);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Paid Rs ${fmt.format(payment.amount)} to ${payment.name}'),
                  backgroundColor: AppColors.green,
                ),
              );
            },
            child: const Text('Pay now'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(context, PaymentProvider provider, payment) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete payment?'),
        content: Text('Remove "${payment.name}" permanently?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              provider.deletePayment(payment);
            },
            child: const Text('Delete',
                style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label, value, sub;
  final Color color;
  const _SummaryCard(
      {required this.label,
      required this.value,
      required this.sub,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 11, color: AppColors.textSecondary)),
            const SizedBox(height: 4),
            Text(value,
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: color),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            Text(sub,
                style: const TextStyle(
                    fontSize: 10, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
