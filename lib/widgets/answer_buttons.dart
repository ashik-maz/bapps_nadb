import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

enum AnswerState { neutral, correct, wrong, revealed }

class AnswerButton extends StatefulWidget {
  final String label;
  final String optionLetter;
  final AnswerState state;
  final VoidCallback? onTap;

  const AnswerButton({
    super.key,
    required this.label,
    required this.optionLetter,
    this.state = AnswerState.neutral,
    this.onTap,
  });

  @override
  State<AnswerButton> createState() => _AnswerButtonState();
}

class _AnswerButtonState extends State<AnswerButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnim = Tween<double>(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color get _bgColor {
    switch (widget.state) {
      case AnswerState.correct:
        return AppTheme.correctBg;
      case AnswerState.wrong:
        return AppTheme.wrongBg;
      case AnswerState.revealed:
        return AppTheme.correctBg;
      case AnswerState.neutral:
        return AppTheme.neutralBg;
    }
  }

  Color get _borderColor {
    switch (widget.state) {
      case AnswerState.correct:
        return AppTheme.correctBorder;
      case AnswerState.wrong:
        return AppTheme.wrongBorder;
      case AnswerState.revealed:
        return AppTheme.correctBorder;
      case AnswerState.neutral:
        return AppTheme.neutralBorder;
    }
  }

  Color get _letterBg {
    switch (widget.state) {
      case AnswerState.correct:
        return AppTheme.correctBorder;
      case AnswerState.wrong:
        return AppTheme.wrongBorder;
      case AnswerState.revealed:
        return AppTheme.correctBorder;
      case AnswerState.neutral:
        return AppTheme.primaryBlue.withAlpha(11);
    }
  }

  Color get _letterColor {
    switch (widget.state) {
      case AnswerState.correct:
      case AnswerState.wrong:
      case AnswerState.revealed:
        return Colors.white;
      case AnswerState.neutral:
        return AppTheme.primaryBlue;
    }
  }

  IconData? get _trailingIcon {
    switch (widget.state) {
      case AnswerState.correct:
        return Icons.check_circle_rounded;
      case AnswerState.wrong:
        return Icons.cancel_rounded;
      case AnswerState.revealed:
        return Icons.check_circle_rounded;
      case AnswerState.neutral:
        return null;
    }
  }

  Color get _trailingColor {
    switch (widget.state) {
      case AnswerState.correct:
      case AnswerState.revealed:
        return AppTheme.correctBorder;
      case AnswerState.wrong:
        return AppTheme.wrongBorder;
      case AnswerState.neutral:
        return Colors.transparent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = widget.state == AnswerState.neutral;

    return GestureDetector(
      onTapDown: isEnabled ? (_) => _controller.forward() : null,
      onTapUp: isEnabled ? (_) => _controller.reverse() : null,
      onTapCancel: isEnabled ? () => _controller.reverse() : null,
      onTap: isEnabled ? widget.onTap : null,
      child: ScaleTransition(
        scale: _scaleAnim,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: _bgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _borderColor, width: 1.5),
          ),
          child: Row(
            children: [
              // Option letter badge
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: _letterBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    widget.optionLetter,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _letterColor,
                      fontFamily: 'Nunito',
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              // Answer text
              Expanded(
                child: Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: widget.state == AnswerState.neutral
                        ? const Color(0xFF1A2340)
                        : widget.state == AnswerState.wrong
                        ? AppTheme.errorRed
                        : AppTheme.successGreen,
                    fontFamily: 'Nunito',
                    height: 1.3,
                  ),
                ),
              ),
              // Trailing icon
              if (_trailingIcon != null) ...[
                const SizedBox(width: 8),
                Icon(_trailingIcon, color: _trailingColor, size: 22),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
