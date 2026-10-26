// By : Maha
// Design in Flutter : Zainab Alaujami
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'base_layout.dart';

class ChatRoomPage extends StatefulWidget {
  final String roomId;
  final bool isGroup;

  final String? otherUserId;
  final String? otherUserFirstName;
  final String? otherUserLastName;
  final String? otherUserImage;
  final String? groupNeighborhood;

  const ChatRoomPage({
    Key? key,
    required this.roomId,
    required this.isGroup,
    this.otherUserId,
    this.otherUserFirstName,
    this.otherUserLastName,
    this.otherUserImage,
    this.groupNeighborhood,
  }) : super(key: key);

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _listCtrl = ScrollController();

  final User? currentUser = FirebaseAuth.instance.currentUser;
  late DatabaseReference messageRef;

  List<Map<String, dynamic>> messages = [];

  @override
  void initState() {
    super.initState();
    messageRef = FirebaseDatabase.instance.ref(
      widget.isGroup
          ? "groups/${widget.groupNeighborhood}/${widget.roomId}/messages"
          : "chats/${widget.roomId}/messages",
    );
    _listenToMessages();
    _markMessagesAsRead();
  }

  @override
  void dispose() {
    _listCtrl.dispose();
    _messageController.dispose();
    super.dispose();
  }

  // ✅ الاستماع للرسائل الحية من قاعدة البيانات
  void _listenToMessages() {
    messageRef.onValue.listen((event) {
      final data = event.snapshot.value as Map?;
      final List<Map<String, dynamic>> loaded = [];

      if (data != null) {
        final sortedKeys = data.keys.toList()..sort();
        for (final key in sortedKeys) {
          final msg = Map<String, dynamic>.from(data[key]);
          loaded.add(msg);
        }
      }

      if (!mounted) return;
      setState(() => messages = loaded);

      // تمرير تلقائي لآخر الرسائل
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_listCtrl.hasClients) {
          _listCtrl.animateTo(
            _listCtrl.position.maxScrollExtent,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
          );
        }
      });
    });
  }

  // ✅ تحديث الرسائل الغير مقروءة إلى مقروءة
  Future<void> _markMessagesAsRead() async {
    if (currentUser == null) return;
    final snapshot = await messageRef.get();
    if (!snapshot.exists) return;

    final data = Map<String, dynamic>.from(snapshot.value as Map);
    for (final entry in data.entries) {
      final msg = Map<String, dynamic>.from(entry.value);
      final isForMe = msg["senderId"] != currentUser!.uid;
      if (isForMe && (msg["isRead"] == false)) {
        await messageRef.child(entry.key).update({"isRead": true});
      }
    }
  }

  // ✅ إرسال رسالة جديدة
  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty || currentUser == null) return;

    // جلب بيانات المستخدم (بحذر إذا كانت null)
    final userSnap =
        await FirebaseDatabase.instance.ref("users/${currentUser!.uid}").get();
    final userData = (userSnap.exists && userSnap.value is Map)
        ? Map<String, dynamic>.from(userSnap.value as Map)
        : <String, dynamic>{};

    // إنشاء مفتاح جديد للرسالة
    final newMessageRef = messageRef.push();

    // إرسال الرسالة مع بيانات المرسل
    await newMessageRef.set({
      "text": text.trim(),
      "senderId": currentUser!.uid,
      "timestamp": DateTime.now().millisecondsSinceEpoch,
      "isRead": false,
      "firstName": userData["firstName"] ?? "",
      "lastName": userData["lastName"] ?? "",
      "profileImage": userData["profileImage"] ?? "",
    });

    _messageController.clear();

    // مرر لآخر الرسائل بعد الإرسال
    if (_listCtrl.hasClients) {
      _listCtrl.animateTo(
        _listCtrl.position.maxScrollExtent + 80,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
  }

  // ====== الهيدر أعلى صفحة الدردشة (تصميمك) ======
  Widget _buildChatHeader(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    if (widget.isGroup) {
      return Container(
        margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 22,
              child: Icon(Icons.groups, size: 22),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: FutureBuilder<DatabaseEvent>(
                future: FirebaseDatabase.instance
                    .ref("groups/${widget.groupNeighborhood}/${widget.roomId}/members")
                    .once(),
                builder: (context, snapshot) {
                  int count = 0;
                  if (snapshot.hasData &&
                      snapshot.data!.snapshot.value != null) {
                    final members = Map<String, dynamic>.from(
                        snapshot.data!.snapshot.value as Map);
                    count = members.length;
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.roomId,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "$count أعضاء",
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            IconButton(
              tooltip: 'الأعضاء',
              icon: Icon(Icons.group, color: primary),
              onPressed: _showGroupMembersDialog,
            ),
            IconButton(
              tooltip: 'إضافة عضو',
              icon: Icon(Icons.person_add_alt_1, color: primary),
              onPressed: _showAddMemberDialog,
            ),
          ],
        ),
      );
    } else {
      final fullName =
          "${widget.otherUserFirstName ?? ''} ${widget.otherUserLastName ?? ''}"
              .trim();

      return Container(
        margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            (widget.otherUserImage != null &&
                    widget.otherUserImage!.isNotEmpty)
                ? CircleAvatar(
                    radius: 22,
                    backgroundImage: FileImage(File(widget.otherUserImage!)),
                  )
                : const CircleAvatar(
                    radius: 22,
                    child: Icon(Icons.person),
                  ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fullName.isEmpty ? "مستخدم" : fullName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    "متصل الآن",
                    style: TextStyle(fontSize: 12.5, color: Colors.black54),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }

  // ====== فقاعة الرسالة (تصميمك) ======
  Widget _buildMessage(Map<String, dynamic> message) {
    final bool isMe =
        (currentUser != null) && (message["senderId"] == currentUser!.uid);
    final primary = Theme.of(context).colorScheme.primary;

    final fullName =
        "${message["firstName"] ?? "مستخدم"} ${message["lastName"] ?? ""}"
            .trim();
    final profileImage = message["profileImage"];
    final timestamp = message["timestamp"];
    String timeText = "";

    if (timestamp != null) {
      final dateTime =
          DateTime.fromMillisecondsSinceEpoch(int.parse(timestamp.toString()));
      final hh = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
      final mm = dateTime.minute.toString().padLeft(2, '0');
      final period = dateTime.hour >= 12 ? "PM" : "AM";
      timeText = "${hh.toString().padLeft(2, '0')}:$mm $period";
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 14,
              backgroundImage:
                  (profileImage != null && profileImage.toString().isNotEmpty)
                      ? FileImage(File(profileImage.toString()))
                      : const AssetImage("assets/default_profile.png")
                          as ImageProvider,
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isMe ? primary.withOpacity(.10) : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isMe ? 16 : 0),
                  bottomRight: Radius.circular(isMe ? 0 : 16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    fullName,
                    style: TextStyle(
                      color: primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 13.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    (message["text"] ?? "").toString(),
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 15,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      timeText,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isMe) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 14,
              backgroundImage:
                  (profileImage != null && profileImage.toString().isNotEmpty)
                      ? FileImage(File(profileImage.toString()))
                      : const AssetImage("assets/default_profile.png")
                          as ImageProvider,
            ),
          ]
        ],
      ),
    );
  }

  // ====== عرض أعضاء القروب (من كود الاخت) ======
  Future<void> _showGroupMembersDialog() async {
    final membersRef = FirebaseDatabase.instance
        .ref("groups/${widget.groupNeighborhood}/${widget.roomId}/members");

    final membersSnapshot = await membersRef.get();
    if (!membersSnapshot.exists || !mounted) return;

    final membersMap = Map<String, dynamic>.from(membersSnapshot.value as Map);
    final List<Map<String, dynamic>> membersList = [];

    for (final uid in membersMap.keys) {
      final userSnapshot =
          await FirebaseDatabase.instance.ref("users/$uid").get();
      if (userSnapshot.exists) {
        final user = Map<String, dynamic>.from(userSnapshot.value as Map);
        membersList.add({
          "firstName": user["firstName"] ?? "",
          "lastName": user["lastName"] ?? "",
          "username": user["username"] ?? "",
        });
      }
    }

    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return SizedBox(
          height: 400,
          child: Column(
            children: [
              const SizedBox(height: 16),
              const Text(
                "👥 أعضاء القروب",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  itemCount: membersList.length,
                  itemBuilder: (context, index) {
                    final member = membersList[index];
                    return ListTile(
                      leading:
                          const CircleAvatar(child: Icon(Icons.person)),
                      title: Text(
                          "${member["firstName"]} ${member["lastName"]}"),
                      subtitle: Text("اسم المستخدم: ${member["username"]}"),
                    );
                  },
                ),
              )
            ],
          ),
        );
      },
    );
  }

  // ====== إضافة عضو بالقروب باسم المستخدم (من كود الاخت) ======
  void _showAddMemberDialog() {
    final TextEditingController usernameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("إضافة عضو إلى القروب"),
        content: TextField(
          controller: usernameController,
          decoration:
              const InputDecoration(hintText: "أدخل اسم المستخدم"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("إلغاء"),
          ),
          ElevatedButton(
            onPressed: () async {
              final username = usernameController.text.trim();
              final usersRef =
                  FirebaseDatabase.instance.ref("users");
              final snapshot = await usersRef.get();

              if (snapshot.exists) {
                final users =
                    Map<String, dynamic>.from(snapshot.value as Map);
                String? targetUid;

                users.forEach((uid, data) {
                  final user = Map<String, dynamic>.from(data);
                  if (user["username"] == username) {
                    targetUid = uid;
                  }
                });

                if (!mounted) return;
                if (targetUid != null) {
                  await FirebaseDatabase.instance
                      .ref(
                          "groups/${widget.groupNeighborhood}/${widget.roomId}/members/$targetUid")
                      .set(true);

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content:
                            Text("تمت إضافة المستخدم '$username'")),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("المستخدم غير موجود")),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(120, 44),
            ),
            child: const Text(
              "إضافة",
              overflow: TextOverflow.visible,
              softWrap: false,
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: BaseLayout(
        activeItem: 'chat',
        currentIndex: 3,
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              // هيدر الدردشة الموحّد (بدل AppBar حتى يبقى تصميمك ثابت)
              _buildChatHeader(context),

              // الرسائل
              Expanded(
                child: ListView.builder(
                  controller: _listCtrl,
                  padding: const EdgeInsets.only(top: 4, bottom: 8),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    return _buildMessage(messages[index]);
                  },
                ),
              ),

              // شريط الإدخال
              Container(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(.05),
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        textDirection: TextDirection.rtl,
                        decoration: InputDecoration(
                          hintText: "اكتب رسالة...",
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                                color:
                                    Colors.black.withOpacity(.12)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                                color:
                                    Colors.black.withOpacity(.12)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () =>
                          _sendMessage(_messageController.text),
                      icon: const Icon(Icons.send,
                          color: Colors.white, size: 18),
                      label: const Text(
                        "إرسال",
                        overflow: TextOverflow.visible,
                        softWrap: false,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15.5,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(110, 46),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
