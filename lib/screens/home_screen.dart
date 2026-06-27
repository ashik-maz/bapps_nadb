import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:quiz_master/data/questions_data.dart';
import 'package:quiz_master/models/question.dart';
import 'package:quiz_master/provider/auth_provider.dart';
import 'package:quiz_master/provider/quiz_provider.dart';
import 'package:quiz_master/provider/theme_provider.dart';
import 'package:quiz_master/widgets/home_header.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Config state
  bool _isLocalMode = true;
  String _selectedCategory = 'All';
  Difficulty? _selectedDifficulty;
  int _questionCount = 10;

  // Local categories
  final List<String> _localCategories = ['All', 'Layout', 'Responsive', 'Styling', 'Theming'];

  // Global API categories (mock category IDs for selection)
  final List<Map<String, dynamic>> _globalCategories = [
    {'name': 'All', 'id': null},
    {'name': 'General Knowledge', 'id': 9},
    {'name': 'Science & Nature', 'id': 17},
    {'name': 'Computers', 'id': 18},
    {'name': 'Sports', 'id': 21},
    {'name': 'History', 'id': 23},
  ];

  void _onSignOut() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out', style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to sign out?', style: TextStyle(fontFamily: 'Nunito')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(fontFamily: 'Nunito')),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthProvider>().signOut();
            },
            child: const Text('Sign Out', style: TextStyle(fontFamily: 'Nunito')),
          ),
        ],
      ),
    );
  }

  Future<void> _startQuiz() async {
    final quizProvider = context.read<QuizProvider>();

    if (_isLocalMode) {
      // Filter local questions
      List<Question> questions = QuestionsData.flutterQuestions;
      if (_selectedCategory != 'All') {
        questions = questions.where((q) => q.category == _selectedCategory).toList();
      }
      if (_selectedDifficulty != null) {
        questions = questions.where((q) => q.difficulty == _selectedDifficulty).toList();
      }

      // Slice to selected count
      if (questions.length > _questionCount) {
        questions = questions.sublist(0, _questionCount);
      }

      if (questions.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No local questions match this criteria. Try changing filters!'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      context.push('/quiz/$_selectedCategory Challenge', extra: questions);
    } else {
      // Fetch dynamic questions from OpenTDB
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      final router = GoRouter.of(context);

      // Find API category ID if selected
      int? categoryId;
      if (_selectedCategory != 'All') {
        final cat = _globalCategories.firstWhere((c) => c['name'] == _selectedCategory, orElse: () => _globalCategories.first);
        categoryId = cat['id'];
      }

      // Trigger fetch
      final fetched = await quizProvider.fetchQuestions(
        amount: _questionCount,
        categoryId: categoryId,
        difficulty: _selectedDifficulty,
      );

      if (fetched != null && fetched.isNotEmpty) {
        router.push('/quiz/$_selectedCategory Arena', extra: fetched);
      } else {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(quizProvider.errorMessage ?? 'Failed to fetch trivia. Please check connection.'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = context.watch<ThemeProvider>();
    final quizProvider = context.watch<QuizProvider>();
    final isDark = themeProvider.isDarkMode;

    // Build categories list based on mode
    final categoriesList = _isLocalMode
        ? _localCategories
        : _globalCategories.map((c) => c['name'] as String).toList();

    // Dynamically calculate Header stats based on Local questions
    final localQuestionsCount = QuestionsData.flutterQuestions.length;
    const localCategoriesCount = 4;
    final localMaxScore = QuestionsData.flutterQuestions.fold<int>(0, (sum, q) => sum + q.difficulty.points);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Responsive App Header
            HomeHeader(
              onProfileTap: _onSignOut,
              onThemeToggle: themeProvider.toggleTheme,
              isDarkMode: isDark,
              totalQuestions: _isLocalMode ? localQuestionsCount : 100, // mock size for API pool
              totalCategories: _isLocalMode ? localCategoriesCount : _globalCategories.length - 1,
              maxScore: _isLocalMode ? localMaxScore : 500,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // --- MODE SELECTOR ---
                    Text(
                      'Select Quiz Mode',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF0D1B2A),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _ModeCard(
                            title: 'Local Flutter',
                            subtitle: 'Offline challenge',
                            icon: Icons.flutter_dash_rounded,
                            isSelected: _isLocalMode,
                            isDark: isDark,
                            onTap: () => setState(() {
                              _isLocalMode = true;
                              _selectedCategory = 'All';
                            }),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _ModeCard(
                            title: 'Global Trivia',
                            subtitle: 'Live API arena',
                            icon: Icons.public_rounded,
                            isSelected: !_isLocalMode,
                            isDark: isDark,
                            onTap: () => setState(() {
                              _isLocalMode = false;
                              _selectedCategory = 'All';
                            }),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // --- QUIZ CUSTOMIZER PANEL ---
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF151F32) : Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.tune_rounded, color: isDark ? const Color(0xFF818CF8) : theme.primaryColor),
                              const SizedBox(width: 8),
                              Text(
                                'Customize Challenge',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 28),

                          // CATEGORY SELECTOR
                          Text(
                            'Category',
                            style: theme.textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: categoriesList.map((cat) {
                              final isSelected = _selectedCategory == cat;
                              return ChoiceChip(
                                label: Text(cat),
                                selected: isSelected,
                                onSelected: (_) => setState(() => _selectedCategory = cat),
                                selectedColor: isDark ? const Color(0xFF6366F1) : theme.primaryColor,
                                labelStyle: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF546E7A)),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  fontFamily: 'Nunito',
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 20),

                          // DIFFICULTY SELECTOR
                          Text(
                            'Difficulty',
                            style: theme.textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            spacing: 8,
                            children: [
                              Expanded(
                                child: _DifficultyButton(
                                  label: 'All',
                                  isSelected: _selectedDifficulty == null,
                                  isDark: isDark,
                                  onTap: () => setState(() => _selectedDifficulty = null),
                                ),
                              ),
                              Expanded(
                                child: _DifficultyButton(
                                  label: 'Easy',
                                  isSelected: _selectedDifficulty == Difficulty.easy,
                                  isDark: isDark,
                                  onTap: () => setState(() => _selectedDifficulty = Difficulty.easy),
                                ),
                              ),
                              Expanded(
                                child: _DifficultyButton(
                                  label: 'Medium',
                                  isSelected: _selectedDifficulty == Difficulty.medium,
                                  isDark: isDark,
                                  onTap: () => setState(() => _selectedDifficulty = Difficulty.medium),
                                ),
                              ),
                              Expanded(
                                child: _DifficultyButton(
                                  label: 'Hard',
                                  isSelected: _selectedDifficulty == Difficulty.hard,
                                  isDark: isDark,
                                  onTap: () => setState(() => _selectedDifficulty = Difficulty.hard),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // QUESTION LENGTH SELECTOR
                          Text(
                            'Question Count: $_questionCount',
                            style: theme.textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Slider(
                            value: _questionCount.toDouble(),
                            min: 5,
                            max: 20,
                            divisions: 3,
                            label: '$_questionCount',
                            activeColor: isDark ? const Color(0xFF6366F1) : theme.primaryColor,
                            onChanged: (v) => setState(() => _questionCount = v.round()),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // --- PERFORMANCE METRICS DASHBOARD ---
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B).withOpacity(0.4) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Session Performance',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _MetricTile(
                                label: 'Quizzes Taken',
                                value: '${quizProvider.quizzesTaken}',
                                icon: Icons.history_edu_rounded,
                                iconColor: Colors.blue,
                              ),
                              _MetricTile(
                                label: 'High Score',
                                value: '${quizProvider.highScore} pts',
                                icon: Icons.emoji_events_rounded,
                                iconColor: Colors.amber,
                              ),
                              _MetricTile(
                                label: 'Avg Accuracy',
                                value: '${quizProvider.averageAccuracy.toStringAsFixed(0)}%',
                                icon: Icons.ads_click_rounded,
                                iconColor: Colors.green,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // --- START QUIZ ACTION ---
                    ElevatedButton(
                      onPressed: quizProvider.isLoading ? null : _startQuiz,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? const Color(0xFF6366F1) : theme.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 6,
                        shadowColor: (isDark ? const Color(0xFF6366F1) : theme.primaryColor).withOpacity(0.3),
                      ),
                      child: quizProvider.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Launch Challenge',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(Icons.play_arrow_rounded, size: 22),
                              ],
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _ModeCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeColor = isDark ? const Color(0xFF6366F1) : theme.primaryColor;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withOpacity(0.12)
              : (isDark ? const Color(0xFF151F32) : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? activeColor
                : (isDark ? const Color(0xFF1E293B) : const Color(0xFFCBD5E1)),
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: activeColor.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 28,
              color: isSelected ? activeColor : (isDark ? const Color(0xFF64748B) : Colors.blueGrey),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 14,
                color: isSelected
                    ? (isDark ? Colors.white : activeColor)
                    : (isDark ? const Color(0xFFCBD5E1) : const Color(0xFF1E293B)),
                fontFamily: 'Nunito',
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DifficultyButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _DifficultyButton({
    required this.label,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeColor = isDark ? const Color(0xFF6366F1) : theme.primaryColor;

    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
        backgroundColor: isSelected ? activeColor : Colors.transparent,
        side: BorderSide(
          color: isSelected ? activeColor : (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
          width: 1.5,
        ),
        padding: const EdgeInsets.symmetric(vertical: 12),
        minimumSize: Size.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          fontFamily: 'Nunito',
        ),
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;

  const _MetricTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              fontFamily: 'Nunito',
              color: isDark ? Colors.white : const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              color: isDark ? const Color(0xFF64748B) : const Color(0xFF64748B),
              fontWeight: FontWeight.bold,
              fontFamily: 'Nunito',
            ),
          ),
        ],
      ),
    );
  }
}
