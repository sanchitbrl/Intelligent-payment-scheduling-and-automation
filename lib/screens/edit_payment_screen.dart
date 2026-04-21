import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/payment.dart';
import '../services/payment_provider.dart';
import '../widgets/app_theme.dart';

class EditPaymentScreen extends StatefulWidget {
  final Payment payment;
  const EditPaymentScreen({super.key, required this.payment});

  @override
  State<EditPaymentScreen> createState() => _EditPaymentScreenState();
}

class _EditPaymentScreenState extends State<EditPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountCtrl;
  late final TextEditingController _recipientCtrl;
  late DateTime _dueDate;
  late int _remindDays;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _amountCtrl = TextEditingController(
        text: widget.payment.amount.toStringAsFixed(0));
    _recipientCtrl =
        TextEditingController(text: widget.payment.recipient);
    _dueDate = widget.payment.nextDueDate;
    _remindDays = widget.payment.remindDaysBefore;
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _recipientCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit payment')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Payment name display
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.categoryColors[
                            widget.payment.category.index %
                                AppColors.categoryColors.length],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          widget.payment.category.icon,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.payment.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                color: AppColors.textPrimary)),
                        Text(widget.payment.frequency.label,
                            style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _label('Amount (Rs)'),
              TextFormField(
                controller: _amountCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(prefixText: 'Rs '),
                validator: (v) =>
                    v == null || double.tryParse(v) == null
                        ? 'Enter valid amount'
                        : null,
              ),
              const SizedBox(height: 14),
              _label('Recipient ID'),
              TextFormField(controller: _recipientCtrl),
              const SizedBox(height: 14),
              _label('Next due date'),
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.bg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined,
                          size: 18, color: AppColors.textSecondary),
                      const SizedBox(width: 10),
                      Text(
                        DateFormat('MMM d, yyyy').format(_dueDate),
                        style: const TextStyle(
                            fontSize: 14, color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              _label('Remind me $_remindDays day(s) before'),
              Slider(
                value: _remindDays.toDouble(),
                min: 1,
                max: 7,
                divisions: 6,
                activeColor: AppColors.green,
                label: '$_remindDays days',
                onChanged: (v) => setState(() => _remindDays = v.round()),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Text('Save changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(text,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary)),
      );

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
            colorScheme:
                const ColorScheme.light(primary: AppColors.green)),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final updated = widget.payment.copyWith(
      amount: double.parse(_amountCtrl.text),
      recipient: _recipientCtrl.text.trim(),
      nextDueDate: _dueDate,
      remindDaysBefore: _remindDays,
    );
    await context.read<PaymentProvider>().updatePayment(updated);
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Payment updated'),
            backgroundColor: AppColors.green),
      );
    }
  }
}
