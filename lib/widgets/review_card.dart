import 'package:flutter/material.dart';
import '../models/question.dart';
import '../models/quiz_result.dart';
import '../services/gemini_service.dart';
import '../theme/app_theme.dart';

class ReviewCard extends StatefulWidget {
  final int index;
  final Question question;
  final AnswerRecord record;

  const ReviewCard({
    super.key,
    required this.index,
    required this.question,
    required this.record,
  });

  @override
  State<ReviewCard> createState() => _ReviewCardState();
}

class _ReviewCardState extends State<ReviewCard> with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  bool _aiLoading = false;
  String? _aiExplanation;

  Future<void> _fetchAiExplanation() async {
    setState(() => _aiLoading = true);
    final gemini = GeminiService();
    final explanation = await gemini.explainQuestion(
      widget.question.text,
      widget.question.options.join(', '),
      widget.question.options[widget.question.correctIndex],
    );
    setState(() {
      _aiExplanation = explanation;
      _aiLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isCorrect = widget.record.isCorrect;
    final wasSkipped = widget.record.selectedIndex == null;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Color headerBgColor;
    final Color borderThemeColor;
    final IconData statusIcon;
    final Color statusIconColor;

    if (isCorrect) {
      headerBgColor = const Color(0xFFE8F5E9).withOpacity(isDark ? 0.08 : 0.8);
      borderThemeColor = AppTheme.correctBorder.withOpacity(0.4);
      statusIcon = Icons.check_rounded;
      statusIconColor = AppTheme.correctBorder;
    } else if (wasSkipped) {
      headerBgColor = const Color(0xFFFFF8E1).withOpacity(isDark ? 0.08 : 0.8);
      borderThemeColor = AppTheme.warningAmber.withOpacity(0.4);
      statusIcon = Icons.help_outline_rounded;
      statusIconColor = AppTheme.warningAmber;
    } else {
      headerBgColor = const Color(0xFFFFEBEE).withOpacity(isDark ? 0.08 : 0.8);
      borderThemeColor = AppTheme.wrongBorder.withOpacity(0.4);
      statusIcon = Icons.close_rounded;
      statusIconColor = AppTheme.wrongBorder;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF151F32) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderThemeColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: headerBgColor,
                borderRadius: _isExpanded
                    ? const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16))
                    : BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(color: statusIconColor, borderRadius: BorderRadius.circular(8)),
                    child: Icon(statusIcon, color: Colors.white, size: 16),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Q${widget.index + 1} · ${widget.question.category}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Text(widget.question.text, maxLines: _isExpanded ? 3 : 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  Icon(_isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded),
                ],
              ),
            ),
          ),

          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!wasSkipped && !isCorrect) ...[
                    _AnswerRow(label: 'Your Answer', text: widget.question.options[widget.record.selectedIndex!], isCorrect: false),
                    const SizedBox(height: 8),
                  ],
                  _AnswerRow(label: 'Correct Answer', text: widget.question.options[widget.question.correctIndex], isCorrect: true),
                  
                  const SizedBox(height: 12),
                  // Gemini AI Assistant Explanation Button
                  if (_aiExplanation == null)
                    OutlinedButton.icon(
                      onPressed: _aiLoading ? null : _fetchAiExplanation,
                      icon: _aiLoading
                          ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF7E22CE)))
                          : const Icon(Icons.smart_toy_rounded, color: Color(0xFF7E22CE), size: 18),
                      label: Text(_aiLoading ? 'AI Thinking...' : '🤖 Ask Gemini AI Explanation', style: const TextStyle(color: Color(0xFF7E22CE), fontWeight: FontWeight.bold, fontSize: 12)),
                      style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFFE9D5FF))),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAF5FF),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE9D5FF)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.smart_toy_rounded, size: 16, color: Color(0xFF7E22CE)),
                              SizedBox(width: 6),
                              Text('Gemini AI Tutor Explanation (বাংলা):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF7E22CE))),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(_aiExplanation!, style: const TextStyle(fontSize: 12, height: 1.4)),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            crossFadeState: _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }
}

class _AnswerRow extends StatelessWidget {
  final String label;
  final String text;
  final bool isCorrect;

  const _AnswerRow({required this.label, required this.text, required this.isCorrect});

  @override
  Widget build(BuildContext context) {
    final color = isCorrect ? AppTheme.successGreen : AppTheme.errorRed;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          Text('$label: ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
          Expanded(child: Text(text, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color))),
        ],
      ),
    );
  }
}
