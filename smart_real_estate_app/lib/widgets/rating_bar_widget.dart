import 'package:flutter/material.dart';

class RatingBarWidget extends StatelessWidget {
  final double rating;
  final int reviewCount;
  final bool showCount;
  final double size;

  const RatingBarWidget({
    Key? key,
    required this.rating,
    this.reviewCount = 0,
    this.showCount = true,
    this.size = 18,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(5, (index) {
          IconData icon;
          if (rating >= index + 1) {
            icon = Icons.star;
          } else if (rating >= index + 0.5) {
            icon = Icons.star_half;
          } else {
            icon = Icons.star_border;
          }
          return Icon(
            icon,
            color: Colors.amber,
            size: size,
          );
        }),
        if (showCount) ...[
          const SizedBox(width: 4),
          Text(
            '($reviewCount)',
            style: TextStyle(
              fontSize: size * 0.8,
              color: Colors.grey[600],
            ),
          ),
        ],
      ],
    );
  }
}
