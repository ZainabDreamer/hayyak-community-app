// By : Zainab
// Design in Flutter : Zainab Alaujami
import 'package:flutter/material.dart';

class CustomHeaderAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onNotificationsTap;
  final String title; // 

  const CustomHeaderAppBar({
    super.key,
    this.onNotificationsTap,
    this.title = '',
  });

  @override
  Size get preferredSize => const Size.fromHeight(72);

  @override
  Widget build(BuildContext context) {
    const iconColor = Colors.black;

    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      title: SizedBox(
        height: 44,
        child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
      ),
      leading: Builder(
        builder: (ctx) => IconButton(
          icon: const Icon(Icons.menu, size: 26),
          color: iconColor,
          onPressed: () => Scaffold.of(ctx).openDrawer(), //  يفتح drawer
          tooltip: 'القائمة',
        ),
      ),
      actions: [
        IconButton(
          tooltip: 'الإشعارات',
          icon: const Icon(Icons.notifications_none, size: 24),
          color: Colors.black,
          onPressed: onNotificationsTap,
        ),
      ],
      scrolledUnderElevation: 0,
    );
  }
}



