//By : Lubna + Zainab 
import 'package:flutter/material.dart';
import 'custom_header.dart';
import 'custom_bottom_nav.dart';
import 'custom_drawer.dart';

class BaseLayout extends StatelessWidget {
  final Widget child;
  final String activeItem;
  final int currentIndex;

  const BaseLayout({
    super.key,
    required this.child,
    required this.activeItem,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality( // لضمان RTL
      textDirection: TextDirection.rtl,
      child: Scaffold(
        drawer: const CustomDrawer(),
       
        appBar: const CustomHeaderAppBar(title: ''),
        body: child,

        bottomNavigationBar: CustomBottomNav(
          activeItem: activeItem,
          currentIndex: currentIndex,
        ),
      ),
    );
  }
}

