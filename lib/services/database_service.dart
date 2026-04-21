import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/payment.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _db;

  Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'esewa_scheduler.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE payments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        amount REAL NOT NULL,
        recipient TEXT NOT NULL,
        category INTEGER NOT NULL,
        frequency INTEGER NOT NULL,
        next_due_date TEXT NOT NULL,
        remind_days_before INTEGER NOT NULL DEFAULT 3,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE payment_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        payment_id INTEGER NOT NULL,
        amount REAL NOT NULL,
        paid_at TEXT NOT NULL,
        status TEXT NOT NULL
      )
    ''');

    final now = DateTime.now();
    final samples = [
      {
        'name': 'Nepal Electricity Authority',
        'amount': 1850.0,
        'recipient': 'NEA-001',
        'category': PaymentCategory.utility.index,
        'frequency': PaymentFrequency.monthly.index,
        'next_due_date': now.add(const Duration(days: 3)).toIso8601String(),
        'remind_days_before': 3,
        'is_active': 1,
        'created_at': now.toIso8601String(),
      },
      {
        'name': 'School Fees',
        'amount': 4500.0,
        'recipient': 'SCHOOL-001',
        'category': PaymentCategory.education.index,
        'frequency': PaymentFrequency.monthly.index,
        'next_due_date': now.add(const Duration(days: 1)).toIso8601String(),
        'remind_days_before': 7,
        'is_active': 1,
        'created_at': now.toIso8601String(),
      },
      {
        'name': 'Home Loan EMI',
        'amount': 12000.0,
        'recipient': 'NIC-BANK',
        'category': PaymentCategory.loan.index,
        'frequency': PaymentFrequency.monthly.index,
        'next_due_date': now.add(const Duration(days: 5)).toIso8601String(),
        'remind_days_before': 7,
        'is_active': 1,
        'created_at': now.toIso8601String(),
      },
      {
        'name': 'Vianet WiFi',
        'amount': 1200.0,
        'recipient': 'VNT-001',
        'category': PaymentCategory.utility.index,
        'frequency': PaymentFrequency.monthly.index,
        'next_due_date': now.add(const Duration(days: 15)).toIso8601String(),
        'remind_days_before': 3,
        'is_active': 1,
        'created_at': now.toIso8601String(),
      },
    ];

    for (final s in samples) {
      await db.insert('payments', s);
    }
  }

  Future<List<Payment>> getAllPayments() async {
    final db = await database;
    final maps = await db.query('payments', orderBy: 'next_due_date ASC');
    return maps.map(Payment.fromMap).toList();
  }

  Future<List<Payment>> getActivePayments() async {
    final db = await database;
    final maps = await db.query(
      'payments',
      where: 'is_active = 1',
      orderBy: 'next_due_date ASC',
    );
    return maps.map(Payment.fromMap).toList();
  }

  Future<int> insertPayment(Payment payment) async {
    final db = await database;
    return await db.insert('payments', payment.toMap());
  }

  Future<void> updatePayment(Payment payment) async {
    final db = await database;
    await db.update('payments', payment.toMap(),
        where: 'id = ?', whereArgs: [payment.id]);
  }

  Future<void> deletePayment(int id) async {
    final db = await database;
    await db.delete('payments', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> markPaid(Payment payment) async {
    final db = await database;
    await db.insert('payment_history', {
      'payment_id': payment.id,
      'amount': payment.amount,
      'paid_at': DateTime.now().toIso8601String(),
      'status': 'paid',
    });
    final nextDue =
        payment.nextDueDate.add(Duration(days: payment.frequency.days));
    await updatePayment(payment.copyWith(nextDueDate: nextDue));
  }

  Future<void> skipPayment(Payment payment) async {
    final db = await database;
    await db.insert('payment_history', {
      'payment_id': payment.id,
      'amount': payment.amount,
      'paid_at': DateTime.now().toIso8601String(),
      'status': 'skipped',
    });
    final nextDue =
        payment.nextDueDate.add(Duration(days: payment.frequency.days));
    await updatePayment(payment.copyWith(nextDueDate: nextDue));
  }

  Future<Map<String, dynamic>> getSummary() async {
    final payments = await getActivePayments();
    final dueSoon = payments.where((p) => p.daysUntilDue <= 7).length;
    final overdue = payments.where((p) => p.isOverdue).length;
    final total = payments.fold(0.0, (s, p) => s + p.amount);
    return {
      'count': payments.length,
      'due_soon': dueSoon,
      'overdue': overdue,
      'monthly_total': total,
    };
  }
}
