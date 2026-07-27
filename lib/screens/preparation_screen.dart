import 'package:flutter/material.dart';

class PreparationScreen extends StatelessWidget {
  const PreparationScreen({super.key});

  final List<Map<String, dynamic>> _notes = const [
    {
      'title': '💻 Computer Networking & DBMS Core Notes',
      'category': 'IT / CSE',
      'icon': Icons.dns_rounded,
      'color': Color(0xFF6366F1),
      'content': '1. OSI Model has 7 layers: Physical, Data Link, Network, Transport, Session, Presentation, Application.\n'
          '2. TCP is Connection-Oriented, UDP is Connectionless.\n'
          '3. Primary Key uniquely identifies a record and cannot be NULL.\n'
          '4. SQL Normalization forms: 1NF (Atomic), 2NF (No partial dependency), 3NF (No transitive dependency).'
    },
    {
      'title': '📚 বাংলা সাহিত্য ও ব্যাকরণ গুরুত্বপূর্ণ নোট',
      'category': 'Bangla GK',
      'icon': Icons.menu_book_rounded,
      'color': Color(0xFF059669),
      'content': '১. চর্যাপদ বাংলা সাহিত্যের প্রাচীনতম নিদর্শন (আবিষ্কারক: হরপ্রাদ শাস্ত্রী, ১৯০৭)।\n'
          '২. সমাস ৬ প্রকার: দ্বন্দ্ব, কর্মধারয়, তৎপুরুষ, বহুব্রীহি, দ্বিগু, অব্যয়ীভাব।\n'
          '৩. রবীন্দ্রনাথ ঠাকুর ১৯১৩ সালে ‘গীতাঞ্জলি’ কাব্যের জন্য নোবেল পুরস্কার পান।\n'
          '৪. কাজী নজরুল ইসলামের প্রথম প্রকাশিত কবিতা ‘মুক্তি’ (১৩২৬ বঙ্গাব্দ)।'
    },
    {
      'title': '🇬🇧 English Grammar & Vocabulary Rules',
      'category': 'English',
      'icon': Icons.translate_rounded,
      'color': Color(0xFFD97706),
      'content': '1. Subject-Verb Agreement: Neither/Nor takes the verb agreeing with the closest subject.\n'
          '2. Conditional Sentences: Type 1 (If + Present, Will + V1), Type 2 (If + Past, Would + V1), Type 3 (If + Past Perfect, Would have + V3).\n'
          '3. Synonyms: Reluctant = Unwilling, Ubiquitous = Omnipresent, Mitigate = Lessen.'
    },
    {
      'title': '🏦 Bank Exam Shortcut Math Formulae',
      'category': 'Mathematics',
      'icon': Icons.calculate_rounded,
      'color': Color(0xFFE11D48),
      'content': '1. Compound Interest: A = P(1 + r/100)^n.\n'
          '2. Time & Work: If A does a job in X days and B in Y days, together they take (X*Y)/(X+Y) days.\n'
          '3. Relative Speed: Same direction = (S1 - S2), Opposite direction = (S1 + S2).'
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.library_books_rounded, color: Color(0xFFE11D48)),
            SizedBox(width: 10),
            Text('Preparation Notes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
      ),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _notes.length,
          itemBuilder: (context, index) {
            final note = _notes[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                clipBehavior: Clip.antiAlias,
                child: ExpansionTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: (note['color'] as Color).withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
                    child: Icon(note['icon'] as IconData, color: note['color'] as Color, size: 22),
                  ),
                  title: Text(note['title'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: Text(note['category'] as String, style: TextStyle(fontSize: 12, color: note['color'] as Color, fontWeight: FontWeight.w600)),
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Text(
                        note['content'] as String,
                        style: const TextStyle(fontSize: 13, height: 1.6),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
