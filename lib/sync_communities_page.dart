// By: Lubna
import 'package:flutter/material.dart';
import 'config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SyncCommunitiesPage extends StatefulWidget {
  const SyncCommunitiesPage({super.key});

  @override
  State<SyncCommunitiesPage> createState() => _SyncCommunitiesPageState();
}

class _SyncCommunitiesPageState extends State<SyncCommunitiesPage> {
  bool isLoading = false;
  String message = '';

  Future<void> syncAllCommunities() async {
    setState(() {
      isLoading = true;
      message = '';
    });

    final baseUrl = kDatabaseUrl;

    try {
      
      final response = await http.get(Uri.parse('$baseUrl/neighborhood.json'));
      final data = json.decode(response.body);

      if (data is List) {
        for (int i = 0; i < data.length; i++) {
          if (data[i] != null) {
            final communityRef = Uri.parse('$baseUrl/communitys/$i.json');
            final communityExists = await http.get(communityRef);

            if (communityExists.body == 'null') {
              await http.put(communityRef, body: json.encode({
                "createdAt": DateTime.now().toIso8601String(),
                "posts": {},
                "ads": {},
                "needs": {},
                "photos": {},
              }));
            }
          }
        }
        setState(() {
          message = 'تم إنشاء المجتمعات لجميع الأحياء بنجاح 🎉';
        });
      } else {
        setState(() {
          message = 'تعذر قراءة بيانات الأحياء ❌';
        });
      }
    } catch (e) {
      debugPrint('خطأ في المزامنة: $e');
      setState(() {
        message = 'فشل في الاتصال أو المعالجة ❌';
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("مزامنة المجتمعات")),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: syncAllCommunities,
              icon: const Icon(Icons.sync),
              label: const Text("إنشاء مجتمع لكل حي"),
            ),
            const SizedBox(height: 20),
            Text(message, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
