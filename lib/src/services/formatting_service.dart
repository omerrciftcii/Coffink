import 'package:intl/intl.dart';

/// Service for formatting dates, times, and currency according to Turkish locale
class FormattingService {
  static FormattingService? _instance;
  static FormattingService get instance => _instance ??= FormattingService._();
  
  FormattingService._();
  
  // Turkish locale formatters
  static const String _turkishLocale = 'tr_TR';
  
  // Date formatters
  late final DateFormat _turkishDateFormat = DateFormat('dd.MM.yyyy', _turkishLocale);
  late final DateFormat _turkishTimeFormat = DateFormat('HH:mm', _turkishLocale);
  late final DateFormat _turkishDateTimeFormat = DateFormat('dd.MM.yyyy HH:mm', _turkishLocale);

  // Number formatter
  late final NumberFormat _turkishNumberFormat = NumberFormat('#,##0.00', _turkishLocale);
  
  /// Format date to Turkish format (dd.MM.yyyy)
  String formatDate(DateTime date) {
    return _turkishDateFormat.format(date);
  }
  
  /// Format time to Turkish format (HH:mm)
  String formatTime(DateTime dateTime) {
    return _turkishTimeFormat.format(dateTime);
  }
  
  /// Format date and time to Turkish format (dd.MM.yyyy HH:mm)
  String formatDateTime(DateTime dateTime) {
    return _turkishDateTimeFormat.format(dateTime);
  }
  
  /// Format currency to Turkish format (XX,XX ₺)
  String formatCurrency(double amount) {
    // Custom formatting to match Turkish currency format
    final formatted = _turkishNumberFormat.format(amount);
    return '$formatted ₺';
  }
  
  /// Format currency with custom symbol
  String formatCurrencyWithSymbol(double amount, String symbol) {
    final formatted = _turkishNumberFormat.format(amount);
    return '$formatted $symbol';
  }
  
  /// Format number with Turkish locale
  String formatNumber(double number) {
    return _turkishNumberFormat.format(number);
  }
  
  /// Parse Turkish date string to DateTime
  DateTime? parseDate(String dateString) {
    try {
      return _turkishDateFormat.parse(dateString);
    } catch (e) {
      return null;
    }
  }
  
  /// Parse Turkish time string to DateTime (uses today's date)
  DateTime? parseTime(String timeString) {
    try {
      final now = DateTime.now();
      final time = _turkishTimeFormat.parse(timeString);
      return DateTime(now.year, now.month, now.day, time.hour, time.minute);
    } catch (e) {
      return null;
    }
  }
  
  /// Parse Turkish datetime string to DateTime
  DateTime? parseDateTime(String dateTimeString) {
    try {
      return _turkishDateTimeFormat.parse(dateTimeString);
    } catch (e) {
      return null;
    }
  }
  
  /// Format relative time (e.g., "2 saat önce", "3 gün önce")
  String formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} gün önce';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} saat önce';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} dakika önce';
    } else {
      return 'Şimdi';
    }
  }
  
  /// Format duration in Turkish
  String formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays} gün';
    } else if (duration.inHours > 0) {
      return '${duration.inHours} saat';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes} dakika';
    } else {
      return '${duration.inSeconds} saniye';
    }
  }
  
  /// Format file size in Turkish
  String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }
  
  /// Format percentage
  String formatPercentage(double value) {
    return '${(value * 100).toStringAsFixed(1)}%';
  }
  
  /// Format phone number for Turkish format
  String formatPhoneNumber(String phoneNumber) {
    // Remove all non-digit characters
    final digits = phoneNumber.replaceAll(RegExp(r'\D'), '');
    
    if (digits.length == 10) {
      // Format as (5XX) XXX XX XX
      return '(${digits.substring(0, 3)}) ${digits.substring(3, 6)} ${digits.substring(6, 8)} ${digits.substring(8)}';
    } else if (digits.length == 11 && digits.startsWith('0')) {
      // Format as 0(5XX) XXX XX XX
      return '0(${digits.substring(1, 4)}) ${digits.substring(4, 7)} ${digits.substring(7, 9)} ${digits.substring(9)}';
    } else if (digits.length == 13 && digits.startsWith('90')) {
      // Format as +90 (5XX) XXX XX XX
      return '+90 (${digits.substring(2, 5)}) ${digits.substring(5, 8)} ${digits.substring(8, 10)} ${digits.substring(10)}';
    }
    
    return phoneNumber; // Return original if format doesn't match
  }
}