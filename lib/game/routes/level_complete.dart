import 'package:flutter/material.dart';

class LevelComplete extends StatelessWidget {
  const LevelComplete({
    required this.nStars,
    super.key,
    this.onNextPressed,
    this.onRetryPressed,
    this.onExitPressed,
  });

  static const id = 'LevelComplete';

  final int nStars;

  final VoidCallback? onNextPressed;
  final VoidCallback? onRetryPressed;
  final VoidCallback? onExitPressed;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(210, 229, 238, 238),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Level Completed',
              style: TextStyle(fontSize: 30),
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  nStars >= 1 ? Icons.star : Icons.star_border,
                  color: nStars >= 1 ? Colors.amber : Colors.black,
                  size: 50,
                ),
                Icon(
                  nStars >= 2 ? Icons.star : Icons.star_border,
                  color: nStars >= 2 ? Colors.amber : Colors.black,
                  size: 50,
                ),
                Icon(
                  nStars >= 3 ? Icons.star : Icons.star_border,
                  color: nStars >= 3 ? Colors.amber : Colors.black,
                  size: 50,
                ),
              ],
            ),
            const SizedBox(height: 15),
            SizedBox(
              width: 150,
              child: OutlinedButton(
                onPressed: nStars != 0 ? onNextPressed : null,
                child: const Text('Next'),
              ),
            ),
            const SizedBox(height: 5),
            SizedBox(
              width: 150,
              child: OutlinedButton(
                onPressed: onRetryPressed,
                child: const Text('Retry'),
              ),
            ),
            const SizedBox(height: 5),
            SizedBox(
              width: 150,
              child: OutlinedButton(
                onPressed: onExitPressed,
                child: const Text('Exit'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
