import 'package:flutter/material.dart';
import 'package:ski_master/game/game.dart';

class LevelSelection extends StatelessWidget {
  const LevelSelection({
    super.key,
    this.onLevelSelected,
    this.onBackPressed,
  });

  static const id = 'LevelSelection';

  final ValueChanged<int>? onLevelSelected;
  final VoidCallback? onBackPressed;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Level Selection',
              style: TextStyle(fontSize: 30),
            ),
            const SizedBox(height: 15),
            Flexible(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: SkiMasterGame.isMobile ? 2 : 3,
                  mainAxisExtent: 50,
                  crossAxisSpacing: 5,
                  mainAxisSpacing: 5,
                ),
                itemBuilder: (context, index) {
                  return OutlinedButton(
                    onPressed: () => onLevelSelected?.call(index + 1),
                    child: Text('Level ${index + 1}'),
                  );
                },
                itemCount: 6,
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 100),
              ),
            ),
            const SizedBox(height: 5),
            IconButton(
              onPressed: onBackPressed,
              icon: const Icon(Icons.arrow_back_rounded),
            )
          ],
        ),
      ),
    );
  }
}
