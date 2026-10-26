// By : Lubna + Maha
// Design in Flutter : Zainab Alaujami
import 'package:flutter/material.dart';
import 'config.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'base_layout.dart'; 

class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final Color mainBlue = const Color(0xFF2C8E97);

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final neighborhoodController = TextEditingController();
  final reasonController = TextEditingController();

  String? selectedTitle;

  Future<void> submitComplaint() async {
    if (nameController.text.isEmpty ||
        phoneController.text.isEmpty ||
        emailController.text.isEmpty ||
        neighborhoodController.text.isEmpty ||
        reasonController.text.isEmpty ||
        selectedTitle == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("يرجى تعبئة جميع الحقول")),
      );
      return;
    }

    final complaint = {
      "title": selectedTitle,
      "name": nameController.text,
      "email": emailController.text,
      "phone": phoneController.text,
      "neighborhood": neighborhoodController.text,
      "reason": reasonController.text,
      "isHandled": false,
    };

    final url = Uri.parse(
        "$kDatabaseUrl/contacts.json");

    try {
      final response = await http.post(
        url,
        body: json.encode(complaint),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("تم استلام الشكوى، شكرًا لتواصلك معنا")),
        );
        nameController.clear();
        phoneController.clear();
        emailController.clear();
        neighborhoodController.clear();
        reasonController.clear();
        setState(() {
          selectedTitle = null;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("حدث خطأ أثناء الإرسال")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("خطأ: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseLayout(
      activeItem: 'contact', 
      currentIndex: 0, 
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Icon(Icons.contact_mail,
                            size: 80, color: mainBlue),
                      ),
                      const SizedBox(height: 25),
                      _buildIOSField("الاسم", controller: nameController),
                      const SizedBox(height: 20),
                      _buildIOSField("رقم الجوال",
                          controller: phoneController,
                          keyboardType: TextInputType.phone),
                      const SizedBox(height: 20),
                      _buildIOSField("البريد الإلكتروني",
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress),
                      const SizedBox(height: 20),
                      _buildIOSField("الحي",
                          controller: neighborhoodController),
                      const SizedBox(height: 20),
                      DropdownButtonFormField<String>(
                        value: selectedTitle,
                        decoration: _iosInputDecoration("عنوان الشكوى"),
                        borderRadius: BorderRadius.circular(16),
                        alignment: Alignment.centerRight,
                        style: const TextStyle(
                            fontSize: 18, color: Colors.black),
                        items: [
                          "نظافة",
                          "الإنارة",
                          "الحدائق والتشجير",
                          "الطرق والأرصفة",
                          "الأمن والسلامة",
                          "التشوه البصري",
                          "النفايات والحاويات",
                          "مياه وصرف صحي",
                          "أخرى",
                        ]
                            .map((e) => DropdownMenuItem(
                                  value: e,
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(e),
                                  ),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedTitle = value;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      _buildIOSField("نص الشكوى",
                          controller: reasonController, maxLines: 4),
                      const SizedBox(height: 40),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: mainBlue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 18),
                          ),
                          onPressed: submitComplaint,
                          child: const Text(
                            "إرسال الشكوى",
                            style: TextStyle(
                                fontSize: 18, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIOSField(String label,
      {TextEditingController? controller,
      TextInputType keyboardType = TextInputType.text,
      int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      textAlign: TextAlign.right,
      cursorColor: Colors.black,
      style: const TextStyle(fontSize: 18, color: Colors.black),
      decoration: _iosInputDecoration(label),
    );
  }

  InputDecoration _iosInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontSize: 16, color: Colors.black),
      filled: true,
      fillColor: const Color(0xFFF9F9F9),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF338C9A)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF338C9A)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide:
            const BorderSide(color: Color(0xFF338C9A), width: 2),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    );
  }
}
