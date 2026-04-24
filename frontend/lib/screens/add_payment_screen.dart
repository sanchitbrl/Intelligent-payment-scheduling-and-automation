import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/payment.dart';
import '../services/payment_provider.dart';
import '../widgets/app_theme.dart';

class AddPaymentScreen extends StatefulWidget {
  const AddPaymentScreen({super.key});

  @override
  State<AddPaymentScreen> createState() => _AddPaymentScreenState();
}

class _AddPaymentScreenState extends State<AddPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _recipientCtrl = TextEditingController();

  PaymentCategory _category = PaymentCategory.utility;
  PaymentFrequency _frequency = PaymentFrequency.monthly;
  DateTime _dueDate = DateTime.now().add(const Duration(days: 30));
  int _remindDays = 3;
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _amountCtrl.dispose();
    _recipientCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule payment'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _label('Payment name'),
              TextFormField(
                controller: _nameCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                    hintText: 'e.g. Nepal Electricity Authority'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('Amount (Rs)'),
                        TextFormField(
                          controller: _amountCtrl,
                          keyboardType: TextInputType.number,
                          decoration:
                              const InputDecoration(prefixText: 'Rs '),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Required';
                            if (double.tryParse(v) == null) return 'Invalid';
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('Recipient ID'),
                        TextFormField(
                          controller: _recipientCtrl,
                          decoration:
                              const InputDecoration(hintText: 'Account/ID'),
                          validator: (v) =>
                              v == null || v.trim().isEmpty ? 'Required' : null,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _label('Category'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: PaymentCategory.values.map((c) {
                  final sel = c == _category;
                  return GestureDetector(
                    onTap: () => setState(() => _category = c),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: sel ? AppColors.green : AppColors.bg,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color:
                              sel ? AppColors.green : AppColors.divider,
                        ),
                      ),
                      child: Text(
                        c.label,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: sel
                              ? Colors.white
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),
              _label('Frequency'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: PaymentFrequency.values.map((f) {
                  final sel = f == _frequency;
                  return GestureDetector(
                    onTap: () => setState(() => _frequency = f),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: sel ? AppColors.green : AppColors.bg,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: sel ? AppColors.green : AppColors.divider),
                      ),
                      child: Text(
                        f.label,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: sel ? Colors.white : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),
              _label('First due date'),
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.bg,
                    borderRadius: BorderRadius.circular(10),
                    border:
                        Border.all(color: AppColors.divider),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined,
                          size: 18, color: AppColors.textSecondary),
                      const SizedBox(width: 10),
                      Text(
                        DateFormat('MMM d, yyyy').format(_dueDate),
                        style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              _label('Remind me $_remindDays day(s) before due'),
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
                onPressed: _saving ? null : _submit,
                child: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Text('Schedule payment'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
      );

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.green),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final payment = Payment(
      name: _nameCtrl.text.trim(),
      amount: double.parse(_amountCtrl.text),
      recipient: _recipientCtrl.text.trim(),
      category: _category,
      frequency: _frequency,
      nextDueDate: _dueDate,
      remindDaysBefore: _remindDays,
    );
    await context.read<PaymentProvider>().addPayment(payment);
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment scheduled successfully'),
          backgroundColor: AppColors.green,
        ),
      );
    }
  }
}
