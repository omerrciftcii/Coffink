import 'dart:developer' as dev;

enum LogLevel {
  debug(500),
  info(800),
  warning(900),
  error(1000);

  const LogLevel(this.value);
  final int value;
}

enum LogCategory {
  userAction('USER_ACTION'),
  data('DATA'),
  performance('PERFORMANCE'),
  error('ERROR'),
  navigation('NAVIGATION'),
  firebase('FIREBASE'),
  cart('CART'),
  auth('AUTH');

  const LogCategory(this.value);
  final String value;
}

class Logger {
  static const String _defaultName = 'CoffeeApp';

  static void debug(String message, {
    String? name,
    LogCategory? category,
    dynamic error,
    StackTrace? stackTrace,
  }) {
    _log(LogLevel.debug, message, name: name, category: category, error: error, stackTrace: stackTrace);
  }

  static void info(String message, {
    String? name,
    LogCategory? category,
    dynamic error,
    StackTrace? stackTrace,
  }) {
    _log(LogLevel.info, message, name: name, category: category, error: error, stackTrace: stackTrace);
  }

  static void warning(String message, {
    String? name,
    LogCategory? category,
    dynamic error,
    StackTrace? stackTrace,
  }) {
    _log(LogLevel.warning, message, name: name, category: category, error: error, stackTrace: stackTrace);
  }

  static void error(String message, {
    String? name,
    LogCategory? category,
    dynamic error,
    StackTrace? stackTrace,
  }) {
    _log(LogLevel.error, message, name: name, category: category, error: error, stackTrace: stackTrace);
  }

  static void _log(LogLevel level, String message, {
    String? name,
    LogCategory? category,
    dynamic error,
    StackTrace? stackTrace,
  }) {
    final logName = name ?? _defaultName;
    final categoryPrefix = category != null ? '[${category.value}] ' : '';
    final formattedMessage = '$categoryPrefix$message';

    dev.log(
      formattedMessage,
      name: logName,
      level: level.value,
      error: error,
      stackTrace: stackTrace,
      time: DateTime.now(),
    );
  }

  // Convenience methods for specific categories
  static void userAction(String message, {String? name}) {
    info(message, name: name, category: LogCategory.userAction);
  }

  static void navigation(String message, {String? name}) {
    info(message, name: name, category: LogCategory.navigation);
  }

  static void dataOperation(String message, {String? name, dynamic error}) {
    if (error != null) {
      Logger.error(message, name: name, category: LogCategory.data, error: error);
    } else {
      info(message, name: name, category: LogCategory.data);
    }
  }

  static void cartAction(String message, {String? name, dynamic error}) {
    if (error != null) {
      Logger.error(message, name: name, category: LogCategory.cart, error: error);
    } else {
      info(message, name: name, category: LogCategory.cart);
    }
  }

  static void authAction(String message, {String? name, dynamic error}) {
    if (error != null) {
      Logger.error(message, name: name, category: LogCategory.auth, error: error);
    } else {
      info(message, name: name, category: LogCategory.auth);
    }
  }

  static void firebaseOperation(String message, {String? name, dynamic error}) {
    if (error != null) {
      Logger.error(message, name: name, category: LogCategory.firebase, error: error);
    } else {
      info(message, name: name, category: LogCategory.firebase);
    }
  }

  static void performance(String message, {String? name}) {
    info(message, name: name, category: LogCategory.performance);
  }

  // Method to log execution time of operations
  static Future<T> timeOperation<T>(
    String operationName,
    Future<T> Function() operation, {
    String? name,
  }) async {
    final stopwatch = Stopwatch()..start();
    
    try {
      performance('Starting operation: $operationName', name: name);
      final result = await operation();
      stopwatch.stop();
      performance('Completed operation: $operationName in ${stopwatch.elapsedMilliseconds}ms', name: name);
      return result;
    } catch (e, stackTrace) {
      stopwatch.stop();
      error('Failed operation: $operationName after ${stopwatch.elapsedMilliseconds}ms', 
            name: name, error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // Method to log method entry and exit
  static void logMethodCall(String className, String methodName, {Map<String, dynamic>? parameters}) {
    final paramString = parameters != null ? ' with params: $parameters' : '';
    debug('$className.$methodName() called$paramString', name: className);
  }
}