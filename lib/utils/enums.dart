/// Enumeration of mathematical operations supported in the app
enum Operation {
  add,
  subtract,
  multiply,
  divide,
}

extension OperationExtension on Operation {
  /// Get the symbol representation of the operation
  String get symbol {
    switch (this) {
      case Operation.add:
        return '+';
      case Operation.subtract:
        return '−';
      case Operation.multiply:
        return '×';
      case Operation.divide:
        return '÷';
    }
  }

  /// Get the display name of the operation
  String get displayName {
    switch (this) {
      case Operation.add:
        return 'Addition';
      case Operation.subtract:
        return 'Subtraction';
      case Operation.multiply:
        return 'Multiplication';
      case Operation.divide:
        return 'Division';
    }
  }

  /// Get the operation from a string symbol
  static Operation? fromSymbol(String symbol) {
    switch (symbol) {
      case '+':
        return Operation.add;
      case '−':
      case '-':
        return Operation.subtract;
      case '×':
      case '*':
        return Operation.multiply;
      case '÷':
      case '/':
        return Operation.divide;
      default:
        return null;
    }
  }

  /// Get the operation from a display name
  static Operation? fromName(String name) {
    switch (name.toLowerCase()) {
      case 'addition':
        return Operation.add;
      case 'subtraction':
        return Operation.subtract;
      case 'multiplication':
        return Operation.multiply;
      case 'division':
        return Operation.divide;
      default:
        return null;
    }
  }
}

/// Enumeration of student performance levels
enum PerformanceLevel {
  poor,
  average,
  good,
  excellent,
}

extension PerformanceLevelExtension on PerformanceLevel {
  /// Get the display name
  String get displayName {
    switch (this) {
      case PerformanceLevel.poor:
        return 'Poor';
      case PerformanceLevel.average:
        return 'Average';
      case PerformanceLevel.good:
        return 'Good';
      case PerformanceLevel.excellent:
        return 'Excellent';
    }
  }

  /// Get the accuracy percentage range for this level
  /// Returns [min, max] inclusive
  List<int> get accuracyRange {
    switch (this) {
      case PerformanceLevel.poor:
        return [0, 50];
      case PerformanceLevel.average:
        return [51, 70];
      case PerformanceLevel.good:
        return [71, 84];
      case PerformanceLevel.excellent:
        return [85, 100];
    }
  }
}
