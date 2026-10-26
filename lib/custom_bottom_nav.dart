// By : Zainab
// Design in Flutter : Zainab Alaujami
import 'package:flutter/material.dart';

class CustomBottomNav extends StatelessWidget {
  final String activeItem;
  final int currentIndex;

  const CustomBottomNav({
    super.key,
    required this.activeItem,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
       
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        height: 64, 
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _item(Icons.route, 'routes', context),
            _item(Icons.groups_2_outlined, 'community', context),
            _item(Icons.home, 'home', context),
          ],
        ),
      ),
    );
  }

  Widget _item(IconData icon, String itemKey, BuildContext context) {
    final isActive = activeItem == itemKey;

    return IconButton(
      iconSize: 26,
      onPressed: () {
        if (!isActive) {
          switch (itemKey) {
            case 'home':
              Navigator.pushReplacementNamed(context, '/home');
              break;
            case 'community':
              Navigator.pushReplacementNamed(context, '/community');
              break;
            case 'routes':
              Navigator.pushReplacementNamed(context, '/routes');
              break;
          }
        }
      },
      // 
      icon: Icon(icon, color: const Color(0xFF2C8E97)),
      splashRadius: 24,
    );
  }
}

