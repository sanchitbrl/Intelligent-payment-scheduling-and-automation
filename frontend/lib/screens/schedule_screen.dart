import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../services/payment_provider.dart';
import '../widgets/app_theme.dart';
import '../widgets/payment_card.dart';
import 'edit_payment_screen.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PaymentProvider>(
      builder: (context, provider, _) {
        final payments = provider.activePayments;
        return RefreshIndicator(
          color: AppColors.green,
          onRefresh: provider.load,
          child: payments.isEmpty
              ? const Center(
                  child: Text(
                    'No scheduled payments.\nTap + to add one.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 14),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: payments.length,
                  itemBuilder: (context, i) {
                    final p = payments[i];
                    return PaymentCard(
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
                    );
                  },
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
        content: Text('Pay Rs ${fmt.format(payment.amount)} to ${payment.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(minimumSize: const Size(80, 36)),
            onPressed: () {
              Navigator.pop(ctx);
              provider.payNow(payment);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Paid to ${payment.name}'), backgroundColor: AppColors.green),
              );
            },
            child: const Text('Pay'),
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
        content: Text('Remove "${payment.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () { Navigator.pop(ctx); provider.deletePayment(payment); },
            child: const Text('Delete', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }
}
