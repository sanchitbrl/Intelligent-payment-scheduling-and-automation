import 'package:flutter/foundation.dart';
import '../models/payment.dart';
import 'database_service.dart';

class PaymentProvider extends ChangeNotifier {
  final _db = DatabaseService();

  List<Payment> _payments = [];
  Map<String, dynamic> _summary = {};
  bool _isLoading = false;

  List<Payment> get payments => _payments;
  List<Payment> get activePayments =>
      _payments.where((p) => p.isActive).toList();
  Map<String, dynamic> get summary => _summary;
  bool get isLoading => _isLoading;

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();
    _payments = await _db.getAllPayments();
    _summary = await _db.getSummary();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addPayment(Payment p) async {
    final id = await _db.insertPayment(p);
    _payments.add(p.copyWith(id: id));
    _payments.sort((a, b) => a.nextDueDate.compareTo(b.nextDueDate));
    _summary = await _db.getSummary();
    notifyListeners();
  }

  Future<void> updatePayment(Payment p) async {
    await _db.updatePayment(p);
    final i = _payments.indexWhere((x) => x.id == p.id);
    if (i != -1) _payments[i] = p;
    _summary = await _db.getSummary();
    notifyListeners();
  }

  Future<void> deletePayment(Payment p) async {
    await _db.deletePayment(p.id!);
    _payments.removeWhere((x) => x.id == p.id);
    _summary = await _db.getSummary();
    notifyListeners();
  }

  Future<void> payNow(Payment p) async {
    await _db.markPaid(p);
    await load();
  }

  Future<void> skipPayment(Payment p) async {
    await _db.skipPayment(p);
    await load();
  }
}
