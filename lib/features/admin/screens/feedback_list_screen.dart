import 'package:flutter/material.dart';
import 'package:dr_shine_app/core/constants/app_colors.dart';
import 'package:dr_shine_app/core/constants/app_sizes.dart';

class FeedbackListScreen extends StatelessWidget {
  const FeedbackListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mockFeedback = [
      {'user': 'Abebe B.', 'rating': 5, 'comment': 'Excellent service, the shine sweep effect is amazing!', 'date': 'Today'},
      {'user': 'Sara T.', 'rating': 4, 'comment': 'Great wash but took a bit longer than expected.', 'date': 'Yesterday'},
      {'user': 'Dawit K.', 'rating': 5, 'comment': 'Best car wash in Addis, hands down.', 'date': '2 days ago'},
      {'user': 'Mina L.', 'rating': 3, 'comment': 'Good wash but the staff were a bit busy.', 'date': 'Jan 25'},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Customer Feedback')),
      body: ListView.separated(
        padding: const EdgeInsets.all(AppSizes.p20),
        itemCount: mockFeedback.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final fb = mockFeedback[index];
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(fb['user'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(fb['date'] as String, style: const TextStyle(fontSize: 12, color: Colors.white24)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: List.generate(5, (i) {
                      return Icon(
                        Icons.star,
                        size: 16,
                        color: i < (fb['rating'] as int) ? Colors.orange : Colors.white12,
                      );
                    }),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    fb['comment'] as String,
                    style: const TextStyle(color: Colors.white70, height: 1.4),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
