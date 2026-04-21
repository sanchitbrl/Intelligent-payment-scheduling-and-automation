enum PaymentFrequency { daily, weekly, monthly, quarterly }

enum PaymentCategory { utility, subscription, education, loan, insurance, other }

extension PaymentFrequencyExt on PaymentFrequency {
  String get label {
    switch (this) {
      case PaymentFrequency.daily:
        return 'Daily';
      case PaymentFrequency.weekly:
        return 'Weekly';
      case PaymentFrequency.monthly:
        return 'Monthly';
      case PaymentFrequency.quarterly:
        return 'Quarterly';
    }
  }

  int get days {
    switch (this) {
      case PaymentFrequency.daily:
        return 1;
      case PaymentFrequency.weekly:
        return 7;
      case PaymentFrequency.monthly:
        return 30;
      case PaymentFrequency.quarterly:
        return 90;
    }
  }
}

extension PaymentCategoryExt on PaymentCategory {
  String get label {
    switch (this) {
      case PaymentCategory.utility:
        return 'Utility';
      case PaymentCategory.subscription:
        return 'Subscription';
      case PaymentCategory.education:
        return 'Education';
      case PaymentCategory.loan:
        return 'Loan';
      case PaymentCategory.insurance:
        return 'Insurance';
      case PaymentCategory.other:
        return 'Other';
    }
  }

  String get icon {
    switch (this) {
      case PaymentCategory.utility:
        return 'U';
      case PaymentCategory.subscription:
        return 'S';
      case PaymentCategory.education:
        return 'E';
      case PaymentCategory.loan:
        return 'L';
      case PaymentCategory.insurance:
        return 'I';
      case PaymentCategory.other:
        return 'O';
    }
  }
}

class Payment {
  final int? id;
  final String name;
  final double amount;
  final String recipient;
  final PaymentCategory category;
  final PaymentFrequency frequency;
  final DateTime nextDueDate;
  final int remindDaysBefore;
  final bool isActive;
  final DateTime createdAt;

  Payment({
    this.id,
    required this.name,
    required this.amount,
    required this.recipient,
    required this.category,
    required this.frequency,
    required this.nextDueDate,
    this.remindDaysBefore = 3,
    this.isActive = true,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  int get daysUntilDue {
    final now = DateTime.now();
    final due = DateTime(nextDueDate.year, nextDueDate.month, nextDueDate.day);
    final today = DateTime(now.year, now.month, now.day);
    return due.difference(today).inDays;
  }

  bool get isDueSoon => daysUntilDue <= 3;
  bool get isOverdue => daysUntilDue < 0;

  Payment copyWith({
    int? id,
    String? name,
    double? amount,
    String? recipient,
    PaymentCategory? category,
    PaymentFrequency? frequency,
    DateTime? nextDueDate,
    int? remindDaysBefore,
    bool? isActive,
  }) {
    return Payment(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      recipient: recipient ?? this.recipient,
      category: category ?? this.category,
      frequency: frequency ?? this.frequency,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      remindDaysBefore: remindDaysBefore ?? this.remindDaysBefore,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'amount': amount,
      'recipient': recipient,
      'category': category.index,
      'frequency': frequency.index,
      'next_due_date': nextDueDate.toIso8601String(),
      'remind_days_before': remindDaysBefore,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Payment.fromMap(Map<String, dynamic> map) {
    return Payment(
      id: map['id'],
      name: map['name'],
      amount: (map['amount'] as num).toDouble(),
      recipient: map['recipient'],
      category: PaymentCategory.values[map['category'] as int],
      frequency: PaymentFrequency.values[map['frequency'] as int],
      nextDueDate: DateTime.parse(map['next_due_date']),
      remindDaysBefore: map['remind_days_before'] as int,
      isActive: (map['is_active'] as int) == 1,
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}
