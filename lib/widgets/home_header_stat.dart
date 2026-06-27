import 'package:flutter/material.dart';

class HomeHeaderStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  const HomeHeaderStat({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 15),
        const SizedBox(width: 5),
        Text(
          '$value ',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            fontFamily: 'Nunito',
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withAlpha(178),
            fontFamily: 'Nunito',
          ),
        ),
      ],
    );
  }
}
