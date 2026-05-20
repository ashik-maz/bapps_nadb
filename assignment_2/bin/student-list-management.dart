import 'dart:io';

void main() {
  // Student list using Map
  List<Map<String, dynamic>> students = [];

  while (true) {
    print("\n===== Student List Manager =====");
    print("1. Add Student");
    print("2. View All Students");
    print("3. Search Student");
    print("4. Filter Students (Marks >= 80)");
    print("5. Show Average Marks");
    print("6. Exit");

    stdout.write("Choose an option: ");
    String? choice = stdin.readLineSync();

    switch (choice) {
      case '1':
        addStudent(students);
        break;

      case '2':
        viewStudents(students);
        break;

      case '3':
        searchStudent(students);
        break;

      case '4':
        filterStudents(students);
        break;

      case '5':
        showAverageMarks(students);
        break;

      case '6':
        print("Program exited.");
        return;

      default:
        print("Invalid option!");
    }
  }
}

// Add Student
void addStudent(List<Map<String, dynamic>> students) {
  stdout.write("Enter student name: ");
  String name = stdin.readLineSync()!;

  stdout.write("Enter student age: ");
  int age = int.parse(stdin.readLineSync()!);

  stdout.write("Enter student marks: ");
  double marks = double.parse(stdin.readLineSync()!);

  students.add({
    "name": name,
    "age": age,
    "marks": marks,
  });

  print("Student added successfully.");
}

// View Students
void viewStudents(List<Map<String, dynamic>> students) {
  if (students.isEmpty) {
    print("No students found.");
    return;
  }

  print("\n===== Student List =====");

  for (int i = 0; i < students.length; i++) {
    print(
        "${i + 1}. Name: ${students[i]['name']}, Age: ${students[i]['age']}, Marks: ${students[i]['marks']}");
  }
}

// Search Student
void searchStudent(List<Map<String, dynamic>> students) {
  stdout.write("Enter student name to search: ");
  String keyword = stdin.readLineSync()!.toLowerCase();

  var result = students.where((student) =>
      student['name'].toLowerCase().contains(keyword));

  if (result.isEmpty) {
    print("Student not found.");
  } else {
    print("\nSearch Result:");
    for (var student in result) {
      print(
          "Name: ${student['name']}, Age: ${student['age']}, Marks: ${student['marks']}");
    }
  }
}

// Filter Students
void filterStudents(List<Map<String, dynamic>> students) {
  var topStudents =
      students.where((student) => student['marks'] >= 80);

  if (topStudents.isEmpty) {
    print("No students with marks >= 80.");
  } else {
    print("\nStudents with marks >= 80:");

    for (var student in topStudents) {
      print(
          "${student['name']} - ${student['marks']}");
    }
  }
}

// Average Marks using reduce()
void showAverageMarks(List<Map<String, dynamic>> students) {
  if (students.isEmpty) {
    print("No student data available.");
    return;
  }

  double totalMarks = students
      .map((student) => student['marks'] as double)
      .reduce((a, b) => a + b);

  double average = totalMarks / students.length;

  print(
      "\nAverage Marks: ${average.toStringAsFixed(2)}");
}