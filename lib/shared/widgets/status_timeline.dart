import 'package:flutter/material.dart';

class StatusTimeline extends StatelessWidget {
  const StatusTimeline({
    super.key,
    required this.steps,
    required this.currentIndex,
  });

  final List<String> steps;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(steps.length, (index) {
        final isActive = index <= currentIndex;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Icon(
                  isActive ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: isActive ? Colors.green : Colors.grey,
                  size: 20,
                ),
                if (index != steps.length - 1)
                  Container(
                    width: 2,
                    height: 24,
                    color: Colors.grey.shade400,
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  steps[index],
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isActive ? Colors.black : Colors.grey.shade600,
                      ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}




