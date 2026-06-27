import '../models/question.dart';

class QuestionsData {
  static const List<Question> flutterQuestions = [
    Question(
      id: 'q1',
      text: 'Which widget lays its children out horizontally?',
      options: ['Column', 'Row', 'Stack', 'Wrap'],
      correctIndex: 1,
      category: 'Layout',
      difficulty: Difficulty.easy,
      explanation:
          'Row arranges its children in a horizontal array. '
          'Column does the same but vertically.',
    ),
    Question(
      id: 'q2',
      text: 'What widget overlaps children on top of each other?',
      options: ['Column', 'Row', 'Stack', 'Container'],
      correctIndex: 2,
      category: 'Layout',
      difficulty: Difficulty.easy,
      explanation:
          'Stack places its children relative to its edges, '
          'allowing them to overlap.',
    ),
    Question(
      id: 'q3',
      text: 'Which widget is used to give a child a fixed size?',
      options: ['Expanded', 'Flexible', 'SizedBox', 'Spacer'],
      correctIndex: 2,
      category: 'Layout',
      difficulty: Difficulty.easy,
      explanation:
          'SizedBox gives its child a fixed width and/or height. '
          'Use SizedBox(height: 16) for spacing in Column.',
    ),
    Question(
      id: 'q4',
      text: 'How do you access screen width in Flutter?',
      options: [
        'Screen.of(context).width',
        'MediaQuery.of(context).size.width',
        'context.screenWidth',
        'ScreenInfo.width',
      ],
      correctIndex: 1,
      category: 'Responsive',
      difficulty: Difficulty.medium,
      explanation:
          'MediaQuery.of(context) returns MediaQueryData which '
          'contains the size, orientation, padding, and more.',
    ),
    Question(
      id: 'q5',
      text: 'What does Expanded do inside a Row or Column?',
      options: [
        'Adds padding around the child',
        'Forces the child to take all remaining space',
        'Centers the child widget',
        'Adds a fixed margin',
      ],
      correctIndex: 1,
      category: 'Layout',
      difficulty: Difficulty.medium,
      explanation:
          'Expanded fills the available remaining space in the '
          'main axis direction of its parent Row or Column.',
    ),
    Question(
      id: 'q6',
      text: 'Which property of Container holds BoxDecoration?',
      options: ['style', 'decoration', 'appearance', 'theme'],
      correctIndex: 1,
      category: 'Styling',
      difficulty: Difficulty.easy,
      explanation:
          'The decoration property of Container accepts a '
          'BoxDecoration for colors, borders, gradients, and shadows.',
    ),
    Question(
      id: 'q7',
      text:
          'In ThemeData, which property defines the primary app color in Material 3?',
      options: ['primaryColor', 'colorScheme', 'accentColor', 'primarySwatch'],
      correctIndex: 1,
      category: 'Theming',
      difficulty: Difficulty.medium,
      explanation:
          'In Flutter 3+ with Material 3, colorScheme replaces '
          'primaryColor and accentColor for a more cohesive color system.',
    ),
    Question(
      id: 'q8',
      text:
          'What widget positions a child at specific coordinates inside a Stack?',
      options: ['Align', 'Offset', 'Positioned', 'Place'],
      correctIndex: 2,
      category: 'Layout',
      difficulty: Difficulty.easy,
      explanation:
          'Positioned must be a descendant of a Stack and allows '
          'placement using top, left, right, bottom, width, and height.',
    ),
    Question(
      id: 'q9',
      text: 'Which widget fills remaining space without a child?',
      options: ['Expanded', 'SizedBox', 'Spacer', 'Flexible'],
      correctIndex: 2,
      category: 'Layout',
      difficulty: Difficulty.medium,
      explanation:
          'Spacer creates empty space that expands to fill '
          'available space in a Row or Column — like Expanded with no child.',
    ),
    Question(
      id: 'q10',
      text: 'How do you access ThemeData inside a widget?',
      options: [
        'ThemeData.of(context)',
        'Theme.of(context)',
        'context.theme',
        'Theme.current',
      ],
      correctIndex: 1,
      category: 'Theming',
      difficulty: Difficulty.medium,
      explanation:
          'Theme.of(context) returns the nearest ThemeData up '
          'the widget tree, letting you read colors, text styles, and more.',
    ),
    Question(
      id: 'q11',
      text: 'What does CrossAxisAlignment.stretch do in a Column?',
      options: [
        'Stretches children vertically',
        'Centers children horizontally',
        'Stretches children to fill full horizontal width',
        'Adds space between children',
      ],
      correctIndex: 2,
      category: 'Layout',
      difficulty: Difficulty.hard,
      explanation:
          'In a Column, the cross axis is horizontal. '
          'CrossAxisAlignment.stretch forces each child to fill the full width.',
    ),
    Question(
      id: 'q12',
      text: 'Which widget avoids system UI overlaps like the notch?',
      options: ['Scaffold', 'SafeArea', 'Padding', 'Material'],
      correctIndex: 1,
      category: 'Responsive',
      difficulty: Difficulty.medium,
      explanation:
          'SafeArea adds padding equal to system intrusions '
          '(status bar, notch, home indicator) so content is never hidden.',
    ),
  ];

  static List<Question> getByCategory(String category) =>
      flutterQuestions.where((q) => q.category == category).toList();

  static List<Question> getByDifficulty(Difficulty d) =>
      flutterQuestions.where((q) => q.difficulty == d).toList();
}
