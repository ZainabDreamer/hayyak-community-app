// By : Maha + Lubna
// Design in Flutter : Zainab Alaujami
import 'dart:convert';
import 'config.dart';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'custom_drawer.dart' show CustomDrawer;

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  File? _imageFile;
  Map<String, dynamic>? userData;
  User? currentUser;
  bool isLoading = true;

  final List<String> _genders = ['أنثى', 'ذكر'];
  String? selectedGender = 'أنثى';

  final TextEditingController phoneController = TextEditingController();
  final TextEditingController birthdateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final uid = currentUser!.uid;
        final url = Uri.parse(
            '$kDatabaseUrl/users/$uid.json');
        final response = await http.get(url);

        if (!mounted) return;
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          setState(() {
            userData = data;
            phoneController.text = data['phone'] ?? '';
            birthdateController.text = data['birthdate'] ?? '';
            selectedGender = data['gender'] ?? 'أنثى';
            isLoading = false;
          });
        } else {
          setState(() => isLoading = false);
        }
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _imageFile = File(pickedFile.path));

      if (currentUser != null) {
        final uid = currentUser!.uid;
        final url = Uri.parse(
            '$kDatabaseUrl/users/$uid.json');
        final res = await http.patch(url,
            body: json.encode({'profileImage': pickedFile.path}));
        if (res.statusCode != 200 && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('فشل في حفظ صورة الملف الشخصي')),
          );
        }
      }
    }
  }

  Future<void> _selectDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      locale: const Locale('ar'),
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        birthdateController.text =
            "${pickedDate.day}-${pickedDate.month}-${pickedDate.year}";
      });
    }
  }

  Future<void> _saveUserData() async {
    if (currentUser != null) {
      final uid = currentUser!.uid;
      final url = Uri.parse(
          '$kDatabaseUrl/users/$uid.json');

      final updatedData = {
        'phone': phoneController.text,
        'birthdate': birthdateController.text,
        'gender': selectedGender,
      };

      final response = await http.patch(url, body: json.encode(updatedData));
      if (!mounted) return;
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم تحديث البيانات بنجاح')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('حدث خطأ أثناء الحفظ')),
        );
      }
    }
  }

  InputDecoration _inputDecoration({
    String? hint,
    IconData? icon,
  }) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: Colors.grey.withOpacity(0.35), width: 1),
    );
    final focusBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(
          color: const Color(0xFF2C8E97).withOpacity(0.6), width: 1.5),
    );
    return InputDecoration(
      prefixIcon: icon != null ? Icon(icon, color: Colors.grey[700]) : null,
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      border: border,
      enabledBorder: border,
      focusedBorder: focusBorder,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF2C8E97);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
       
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [Color(0xFFE8F7F7), Color(0xFFDFF5F4)],
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          extendBody: true,
          drawer: const CustomDrawer(),

         
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            leading: Builder(
              builder: (ctx) => IconButton(
                icon: const Icon(Icons.menu, color: Colors.black),
                onPressed: () {
                  final s = Scaffold.maybeOf(ctx);
                  if (s?.hasDrawer ?? false) {
                    s!.openDrawer();
                  } else {
                    Navigator.maybePop(context);
                  }
                },
                tooltip: 'القائمة',
              ),
            ),
            title: SizedBox(
              height: 36,
              child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
            ),
            actions: const [
              Padding(
                padding: EdgeInsetsDirectional.only(end: 8),
                child: Icon(Icons.notifications_none, color: Colors.black),
              ),
            ],
          ),

          body: SafeArea(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32),
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.75),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.35),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          padding:
                              const EdgeInsets.fromLTRB(20, 24, 20, 24),
                          child: Column(
                            children: [
                              // الصورة + زر تعديل
                              Center(
                                child: Stack(
                                  alignment: Alignment.bottomLeft,
                                  children: [
                                    Container(
                                      width: 110,
                                      height: 110,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color: Colors.white, width: 4),
                                        image: DecorationImage(
                                          fit: BoxFit.cover,
                                          image: _imageFile != null
                                              ? FileImage(_imageFile!)
                                              : (userData?['profileImage'] !=
                                                      null
                                                  ? FileImage(File(userData![
                                                      'profileImage']))
                                                  : const AssetImage(
                                                          'assets/images/default_profile.png')
                                                      as ImageProvider),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      left: 0,
                                      child: Material(
                                        color: Colors.white,
                                        shape: const CircleBorder(),
                                        elevation: 2,
                                        child: InkWell(
                                          customBorder: const CircleBorder(),
                                          onTap: _pickImage,
                                          child: const Padding(
                                            padding: EdgeInsets.all(6.0),
                                            child: Icon(Icons.edit, size: 18),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),

                              // الاسم/البريد عرض فقط أعلى النموذج
                              Text(
                                '${userData?['firstName'] ?? ''} ${userData?['lastName'] ?? ''}',
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                userData?['email'] ?? '',
                                style: const TextStyle(color: Colors.grey),
                              ),
                              const SizedBox(height: 24),

                              // الحقول (نفس ستايل الصفحات السابقة)
                              _label('الاسم', color: primary),
                              TextField(
                                readOnly: true,
                                decoration: _inputDecoration(
                                  hint:
                                      '${userData?['firstName'] ?? ''} ${userData?['lastName'] ?? ''}',
                                ),
                              ),
                              const SizedBox(height: 12),

                              _label('الجنس', color: primary),
                              DropdownButtonFormField<String>(
                                value: selectedGender,
                                decoration: _inputDecoration(),
                                items: _genders
                                    .map((g) =>
                                        DropdownMenuItem(value: g, child: Text(g)))
                                    .toList(),
                                onChanged: (v) =>
                                    setState(() => selectedGender = v),
                              ),
                              const SizedBox(height: 12),

                              _label('رقم الجوال', color: primary),
                              TextField(
                                controller: phoneController,
                                keyboardType: TextInputType.phone,
                                decoration: _inputDecoration(
                                  icon: Icons.phone_iphone,
                                  hint: '05xxxxxxxx',
                                ),
                              ),
                              const SizedBox(height: 12),

                              _label('تاريخ الميلاد', color: primary),
                              TextField(
                                controller: birthdateController,
                                readOnly: true,
                                onTap: _selectDate,
                                decoration: _inputDecoration(
                                  icon: Icons.calendar_today,
                                  hint: 'اختر التاريخ',
                                ),
                              ),
                              const SizedBox(height: 12),

                              _label('البريد الإلكتروني', color: primary),
                              TextField(
                                readOnly: true,
                                decoration: _inputDecoration(
                                  hint: userData?['email'] ?? '',
                                ),
                              ),
                              const SizedBox(height: 20),

                              SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primary,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 1,
                                  ),
                                  onPressed: _saveUserData,
                                  child: const Text('حفظ'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text, {required Color color}) {
    return Align(
      alignment: Alignment.centerRight,
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
