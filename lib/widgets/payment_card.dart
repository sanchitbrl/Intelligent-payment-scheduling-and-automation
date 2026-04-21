import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/payment.dart';
import 'app_theme.dart';

class PaymentCard extends StatelessWidget {
  final Payment payment;
  final VoidCallback? onPay;
  final VoidCallback? onEdit;
  final VoidCallback? onSkip;
  final VoidCallback? onDelete;

  const PaymentCard({
    super.key,
    required this.payment,
    this.onPay,
    this.onEdit,
    this.onSkip,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final days = payment.daysUntilDue;
    final dueColor = AppColors.forDays(days);
    final dueLabel = AppColors.labelForDays(days);
    final catColor =
        AppColors.categoryColors[payment.category.index % AppColors.categoryColors.length];
    final fmt = NumberFormat('#,###');

    return Card(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: catColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      payment.category.icon,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: dueColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        payment.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${payment.frequency.label} · ${payment.category.label}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Rs ${fmt.format(payment.amount)}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: dueColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        dueLabel,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: dueColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: (1 - (days.clamp(0, 30) / 30)).clamp(0.05, 1.0),
                backgroundColor: AppColors.bg,
                color: dueColor,
                minHeight: 3,
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Divider(height: 1, color: AppColors.divider),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Row(
              children: [
                _Btn(label: 'Pay now', color: AppColors.green, onTap: onPay),
                const SizedBox(width: 6),
                _Btn(label: 'Edit', onTap: onEdit),
                const SizedBox(width: 6),
                _Btn(label: 'Skip', onTap: onSkip),
                const Spacer(),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline, size: 18),
                  color: AppColors.danger,
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Btn extends StatelessWidget {
  final String label;
  final Color? color;
  final VoidCallback? onTap;

  const _Btn({required this.label, this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.textSecondary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: c.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: c,
          ),
        ),
      ),
    );
  }
}
