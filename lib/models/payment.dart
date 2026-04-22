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

  String get value => name; // e.g. 'daily', 'monthly'
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

  String get value => name; // e.g. 'utility', 'loan'
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

  /// Convert to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'amount': amount,
      'recipient': recipient,
      'category': category.value,
      'frequency': frequency.value,
      'nextDueDate': nextDueDate.toIso8601String(),
      'remindDaysBefore': remindDaysBefore,
      'isActive': isActive,
    };
  }

  /// Parse from API JSON response
  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'],
      name: json['name'],
      amount: (json['amount'] as num).toDouble(),
      recipient: json['recipient'],
      category: PaymentCategory.values.firstWhere(
        (c) => c.name == json['category'],
        orElse: () => PaymentCategory.other,
      ),
      frequency: PaymentFrequency.values.firstWhere(
        (f) => f.name == json['frequency'],
        orElse: () => PaymentFrequency.monthly,
      ),
      nextDueDate: DateTime.parse(json['nextDueDate']),
      remindDaysBefore: json['remindDaysBefore'] as int? ?? 3,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }
}
