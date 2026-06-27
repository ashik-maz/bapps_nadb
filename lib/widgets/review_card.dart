import 'package:flutter/material.dart';

import '../models/question.dart';
import '../models/quiz_result.dart';
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

  @override
  Widget build(BuildContext context) {
    final isCorrect = widget.record.isCorrect;
    final wasSkipped = widget.record.selectedIndex == null;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final headerBgColor = isCorrect
        ? const Color(0xFFE8F5E9).withOpacity(isDark ? 0.08 : 0.8)
        : const Color(0xFFFFEBEE).withOpacity(isDark ? 0.08 : 0.8);

    final borderThemeColor = isCorrect
        ? AppTheme.correctBorder.withOpacity(0.4)
        : AppTheme.wrongBorder.withOpacity(0.4);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF151F32) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderThemeColor),
        boxShadow: [
          BoxShadow(
            color: (isCorrect ? AppTheme.successGreen : AppTheme.errorRed)
                .withOpacity(isDark ? 0.03 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- INTERACTIVE HEADER ---
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: headerBgColor,
                borderRadius: _isExpanded
                    ? const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      )
                    : BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: isCorrect ? AppTheme.correctBorder : AppTheme.wrongBorder,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      isCorrect ? Icons.check_rounded : Icons.close_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Q${widget.index + 1}  ·  ${widget.question.category}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isDark ? const Color(0xFF94A3B8) : AppTheme.neutralGrey,
                            fontFamily: 'Nunito',
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.question.text,
                          maxLines: _isExpanded ? 3 : 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : const Color(0xFF0D1B2A),
                            fontFamily: 'Nunito',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    _isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                    color: isDark ? Colors.white54 : Colors.black54,
                    size: 22,
                  ),
                ],
              ),
            ),
          ),

          // --- EXPANDABLE BODY ---
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Option breakdown
                  if (!wasSkipped && !isCorrect) ...[
                    _AnswerRow(
                      label: 'Your Answer',
                      text: widget.question.options[widget.record.selectedIndex!],
                      isCorrect: false,
                    ),
                    const SizedBox(height: 8),
                  ],
                  _AnswerRow(
                    label: 'Correct Answer',
                    text: widget.question.options[widget.record.correctIndex],
                    isCorrect: true,
                  ),
                  if (wasSkipped) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Time Expired / Not Answered',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white30 : AppTheme.neutralGrey,
                        fontStyle: FontStyle.italic,
                        fontFamily: 'Nunito',
                      ),
                    ),
                  ],

                  // Explanation
                  if (widget.question.explanation != null) ...[
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF0F4FF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.lightbulb_outline_rounded,
                            size: 16,
                            color: isDark ? const Color(0xFF818CF8) : AppTheme.primaryBlue,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              widget.question.explanation!,
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? Colors.white : const Color(0xFF1A2340),
                                fontFamily: 'Nunito',
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
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

  const _AnswerRow({
    required this.label,
    required this.text,
    required this.isCorrect,
  });

  @override
  Widget build(BuildContext context) {
    final color = isCorrect ? AppTheme.successGreen : AppTheme.errorRed;
    final bg = isCorrect ? AppTheme.correctBg : AppTheme.wrongBg;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? color.withOpacity(0.1) : bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Text(
            '$label:  ',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
              fontFamily: 'Nunito',
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : color,
                fontFamily: 'Nunito',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
