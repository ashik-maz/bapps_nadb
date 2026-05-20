import 'dart:io';

void main() {
  print("===== Personal Finance Tracker (BD) =====");

  // Input monthly income
  stdout.write("Enter your monthly income (৳): ");
  double income = double.parse(stdin.readLineSync()!);

  // Expense categories using Map
  Map<String, double?> expenses = {};

  // Input expenses
  while (true) {
    stdout.write(
        "\nEnter expense category (food/rent/transport) or 'done': ");

    String category = stdin.readLineSync()!.toLowerCase();

    if (category == 'done') {
      break;
    }

    stdout.write("Enter amount for $category (৳): ");
    String? inputAmount = stdin.readLineSync();

    // Null safety handling
    double amount = double.tryParse(inputAmount ?? '') ?? 0.0;

    expenses[category] = amount;
  }

  // Calculate total expenses
  double totalExpenses = 0;

  expenses.forEach((category, amount) {
    totalExpenses += amount ?? 0.0;
  });

  // Remaining balance
  double remainingBalance = income - totalExpenses;

  // Savings percentage
  double savingsPercentage =
      (remainingBalance / income) * 100;

  // Print summary
  print("\n===== Financial Summary =====");

  print("Total Income: ৳ ${income.toStringAsFixed(2)}");

  print("\nExpenses:");

  expenses.forEach((category, amount) {
    print(
        "- $category : ৳ ${amount?.toStringAsFixed(2) ?? '0.00'}");
  });

  print(
      "\nTotal Expenses: ৳ ${totalExpenses.toStringAsFixed(2)}");

  print(
      "Remaining Balance: ৳ ${remainingBalance.toStringAsFixed(2)}");

  print(
      "Savings Percentage: ${savingsPercentage.toStringAsFixed(2)}%");
}