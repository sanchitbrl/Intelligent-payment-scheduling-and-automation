import 'package:flutter/foundation.dart';
import '../models/payment.dart';
import 'api_service.dart';

class PaymentProvider extends ChangeNotifier {
  final _api = ApiService();

  List<Payment> _payments = [];
  Map<String, dynamic> _summary = {};
  bool _isLoading = false;
  String? _error;

  List<Payment> get payments => _payments;
  List<Payment> get activePayments =>
      _payments.where((p) => p.isActive).toList();
  Map<String, dynamic> get summary => _summary;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final paymentData = await _api.getAllPayments();
      _payments = paymentData.map((j) => Payment.fromJson(j)).toList();
      _payments.sort((a, b) => a.nextDueDate.compareTo(b.nextDueDate));

      _summary = await _api.getSummary();
    } catch (e) {
      _error = 'Failed to load data. Check your connection.';
      debugPrint('PaymentProvider.load error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addPayment(Payment p) async {
    try {
      final json = await _api.createPayment(p.toJson());
      final created = Payment.fromJson(json);
      _payments.add(created);
      _payments.sort((a, b) => a.nextDueDate.compareTo(b.nextDueDate));
      _summary = await _api.getSummary();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to create payment.';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updatePayment(Payment p) async {
    try {
      final json = await _api.updatePayment(p.id!, p.toJson());
      final updated = Payment.fromJson(json);
      final i = _payments.indexWhere((x) => x.id == p.id);
      if (i != -1) _payments[i] = updated;
      _summary = await _api.getSummary();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to update payment.';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deletePayment(Payment p) async {
    try {
      await _api.deletePayment(p.id!);
      _payments.removeWhere((x) => x.id == p.id);
      _summary = await _api.getSummary();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to delete payment.';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> payNow(Payment p) async {
    try {
      await _api.markPaid(p.id!);
      await load();
    } catch (e) {
      _error = 'Failed to mark as paid.';
      notifyListeners();
    }
  }

  Future<void> skipPayment(Payment p) async {
    try {
      await _api.skipPayment(p.id!);
      await load();
    } catch (e) {
      _error = 'Failed to skip payment.';
      notifyListeners();
    }
  }
}
