// By : Maha
// Design in Flutter : Zainab Alaujami
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'theme_provider.dart';
import 'base_layout.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initNotifications();
  }

  Future<void> _initNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await notificationsPlugin.initialize(initSettings);
  }

  Future<void> _showTestNotification() async {
    const androidDetails = AndroidNotificationDetails(
      'test_channel',
      'Test Channel',
      importance: Importance.max,
      priority: Priority.high,
    );
    const notifDetails = NotificationDetails(android: androidDetails);
    await notificationsPlugin.show(
      0,
      'تنبيه حيّك',
      'هذا إشعار تجريبي',
      notifDetails,
    );
  }

  Future<void> _getLocation() async {
    bool enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) return;
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) return;

    final position = await Geolocator.getCurrentPosition();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("الموقع الحالي"),
        content: Text(
            "خط العرض: ${position.latitude}\nخط الطول: ${position.longitude}"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    bool isDark = themeProvider.isDarkMode;

    return BaseLayout(
      activeItem: 'settings',
      currentIndex: 4, 
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildCard(
            title: "الإشعارات المجتمعية",
            subtitle: "استقبال تنبيهات عند وجود فعالية أو تنبيه",
            icon: Icons.notifications_active_outlined,
            onTap: _showTestNotification,
            isDark: isDark,
          ),
          _buildCard(
            title: "الوضع الليلي",
            icon: Icons.dark_mode_outlined,
            isSwitch: true,
            switchValue: isDark,
            onSwitchChanged: (_) => themeProvider.toggleTheme(),
            isDark: isDark,
          ),
          _buildCard(
            title: "موقعي الجغرافي",
            subtitle: "عرض موقعك الحالي",
            icon: Icons.my_location_outlined,
            onTap: _getLocation,
            isDark: isDark,
          ),
          _buildCard(
            title: "سياسة الخصوصية والدعم",
            subtitle: "عرض سياسة الخصوصية",
            icon: Icons.privacy_tip_outlined,
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => const AlertDialog(
                  title: Text("الخصوصية"),
                  content: Text("سيتم إضافة سياسة الخصوصية قريبًا."),
                ),
              );
            },
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required String title,
    String? subtitle,
    required IconData icon,
    void Function()? onTap,
    bool isSwitch = false,
    bool switchValue = false,
    void Function(bool)? onSwitchChanged,
    required bool isDark,
  }) {
    return Card(
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 4,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF338C9A).withOpacity(0.15),
          child: Icon(icon, color: const Color(0xFF338C9A)),
        ),
        title: Text(
          title,
          style:
              TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 16, fontWeight: FontWeight.w600),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: TextStyle(
                    color: isDark ? Colors.grey[400] : Colors.grey[700],
                    fontSize: 14),
              )
            : null,
        trailing: isSwitch
            ? Switch(
                value: switchValue,
                onChanged: onSwitchChanged,
                activeColor: const Color(0xFF338C9A),
              )
            : const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: isSwitch ? null : onTap,
      ),
    );
  }
}
