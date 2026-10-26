//By : Maha + Lubna
// Design in Flutter : Zainab Alaujami
import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'base_layout.dart';
import 'chat_room_page.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late DatabaseReference groupRef;
  List<Map<String, dynamic>> searchResults = [];
  List<Map<String, dynamic>> directChats = [];
  final TextEditingController searchController = TextEditingController();
  User? currentUser;

  @override
  void initState() {
    super.initState();
    currentUser = FirebaseAuth.instance.currentUser;
    groupRef = FirebaseDatabase.instance.ref("groups");
    _tabController = TabController(length: 3, vsync: this);
    _loadDirectChats();
  }

  // ===== تحميل المحادثات المباشرة (آخر رسالة = أحدث وقت) =====
  Future<void> _loadDirectChats() async {
    final ref = FirebaseDatabase.instance.ref("chats");
    final snapshot = await ref.get();

    if (!snapshot.exists || currentUser == null) return;

    final data = Map<String, dynamic>.from(snapshot.value as Map);
    final List<Map<String, dynamic>> chats = [];

    for (final roomId in data.keys) {
      if (!roomId.toString().contains(currentUser!.uid)) continue;

      final room = Map<String, dynamic>.from(data[roomId]);
      final messages = Map<String, dynamic>.from(room["messages"] ?? {});
      final sortedKeys = messages.keys.toList()..sort();
      final lastMsgKey = sortedKeys.isNotEmpty ? sortedKeys.last : null;
      final lastMsgData = lastMsgKey != null
          ? Map<String, dynamic>.from(messages[lastMsgKey])
          : null;

      final uids = roomId.split("_");
      final otherUids = uids.where((uid) => uid != currentUser!.uid).toList();
      if (otherUids.isEmpty) continue;

      final otherUid = otherUids.first;
      final userSnapshot = await FirebaseDatabase.instance.ref("users/$otherUid").get();
      if (!userSnapshot.exists) continue;

      final user = Map<String, dynamic>.from(userSnapshot.value as Map);

      chats.add({
        "uid": otherUid,
        "roomId": roomId,
        "firstName": user["firstName"],
        "lastName": user["lastName"],
        "profileImage": user["profileImage"],
        "lastMessage": lastMsgData?["text"] ?? "لا توجد رسائل",
        "timestamp": lastMsgData?["timestamp"],
      });
    }

    chats.sort((a, b) => (b["timestamp"] ?? 0).compareTo(a["timestamp"] ?? 0));
    if (!mounted) return;
    setState(() => directChats = chats);
  }

  // ===== البحث عن مستخدمين =====
  Future<void> _searchUsers(String query) async {
    final ref = FirebaseDatabase.instance.ref("users");
    final snapshot = await ref.get();

    if (!snapshot.exists) {
      setState(() => searchResults = []);
      return;
    }

    final data = snapshot.value as Map;
    final results = <Map<String, dynamic>>[];

    data.forEach((key, value) {
      final user = Map<String, dynamic>.from(value);
      if (user["username"] != null &&
          user["username"].toString().toLowerCase().contains(query.toLowerCase()) &&
          key != currentUser?.uid) {
        results.add({"uid": key, ...user});
      }
    });

    if (!mounted) return;
    setState(() => searchResults = results);
  }

  // ===== إنشاء مجموعة =====
  void _showCreateGroupDialog() {
    final groupNameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("إنشاء مجموعة جديدة"),
        content: TextField(
          controller: groupNameController,
          decoration: const InputDecoration(hintText: "أدخل اسم المجموعة"),
        ),
        actions: [
          TextButton(
            child: const Text("إلغاء"),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text("إنشاء"),
            onPressed: () async {
              final name = groupNameController.text.trim();
              if (name.isNotEmpty && currentUser != null) {
                await FirebaseDatabase.instance.ref("groups/$name").set({
                  "createdBy": currentUser!.uid,
                  "members": { currentUser!.uid: true },
                });
                if (mounted) Navigator.pop(context);
                setState(() {}); // يحدث تبويب المجموعات
              }
            },
          ),
        ],
      ),
    );
  }

  String _generateChatRoomId(String uid1, String uid2) {
    return uid1.compareTo(uid2) < 0 ? "${uid1}_$uid2" : "${uid2}_$uid1";
  }

  // ===== تبويب البحث =====
  Widget buildSearchTab(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
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
            child: TextField(
              controller: searchController,
              textDirection: TextDirection.rtl,
              decoration: InputDecoration(
                hintText: "ابحث باسم المستخدم...",
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: () => _searchUsers(searchController.text.trim()),
                ),
                contentPadding: const EdgeInsets.all(12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (v) => _searchUsers(v.trim()),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: searchResults.isEmpty
                ? const Center(child: Text("لا يوجد نتائج"))
                : ListView.separated(
                    itemCount: searchResults.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final user = searchResults[index];
                      return Container(
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
                        child: ListTile(
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          leading: CircleAvatar(
                            backgroundImage: user["profileImage"] != null
                                ? FileImage(File(user["profileImage"]))
                                : null,
                            child: user["profileImage"] == null
                                ? const Icon(Icons.person)
                                : null,
                          ),
                          title: Text(
                            "${user["firstName"] ?? ''} ${user["lastName"] ?? ''}",
                            textDirection: TextDirection.rtl,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            user["username"] ?? '',
                            textDirection: TextDirection.rtl,
                          ),
                          onTap: () {
                            final roomId =
                                _generateChatRoomId(currentUser!.uid, user["uid"]);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatRoomPage(
                                  roomId: roomId,
                                  isGroup: false,
                                  otherUserId: user["uid"],
                                  otherUserFirstName: user["firstName"],
                                  otherUserLastName: user["lastName"],
                                  otherUserImage: user["profileImage"],
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // ===== تبويب المحادثات =====
  Widget buildChatsTab(BuildContext context) {
    if (directChats.isEmpty) {
      return const Center(child: Text("لا توجد محادثات"));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemCount: directChats.length,
      itemBuilder: (context, index) {
        final chat = directChats[index];
        final profileImage = chat["profileImage"];
        final fullName = "${chat["firstName"] ?? ''} ${chat["lastName"] ?? ''}";
        final lastMessage = chat["lastMessage"];
        final timestamp = chat["timestamp"];

        String formattedTime = "";
        if (timestamp != null) {
          final dateTime = DateTime.fromMillisecondsSinceEpoch(
              int.parse(timestamp.toString()));
          formattedTime =
              "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
        }

        return Container(
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
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            leading: CircleAvatar(
              radius: 26,
              backgroundImage: profileImage != null
                  ? FileImage(File(profileImage))
                  : const AssetImage("assets/default_profile.png")
                      as ImageProvider,
            ),
            title: Text(
              fullName,
              textDirection: TextDirection.rtl,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              lastMessage ?? "",
              textDirection: TextDirection.rtl,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Text(
              formattedTime,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatRoomPage(
                    roomId: chat["roomId"],
                    isGroup: false,
                    otherUserId: chat["uid"],
                    otherUserFirstName: chat["firstName"],
                    otherUserLastName: chat["lastName"],
                    otherUserImage: chat["profileImage"],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  // ===== تبويب المجموعات (تصميمك القديم + زر إنشاء مجموعة دائم) =====
  Widget buildGroupsTab(BuildContext context) {
    if (currentUser == null) {
      return Center(
        child: CircularProgressIndicator(
          color: Theme.of(context).colorScheme.primary,
        ),
      );
    }

    return FutureBuilder<DatabaseEvent>(
      future: FirebaseDatabase.instance.ref("groups").once(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
          return Stack(
            children: [
              const Center(child: Text("لا توجد مجموعات")),
              Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20, right: 20),
                  child: FloatingActionButton(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    onPressed: _showCreateGroupDialog,
                    child: const Icon(Icons.add),
                  ),
                ),
              ),
            ],
          );
        }

        final groupsData = snapshot.data!.snapshot.value as Map;
        final List<Map<String, dynamic>> userGroups = [];

        groupsData.forEach((groupName, groupInfo) {
          final group = Map<String, dynamic>.from(groupInfo);
          final members = Map<String, dynamic>.from(group["members"] ?? {});
          if (group["createdBy"] == currentUser!.uid ||
              members.containsKey(currentUser!.uid)) {
            userGroups.add({
              "name": groupName,
              "members": members,
              "createdBy": group["createdBy"],
            });
          }
        });

        return Stack(
          children: [
            ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemCount: userGroups.length,
              itemBuilder: (context, index) {
                final group = userGroups[index];
                final groupName = group["name"];
                final memberCount = group["members"]?.length ?? 0;
                final isCreator = group["createdBy"] == currentUser!.uid;

                return Container(
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
                  child: ListTile(
                    leading: const Icon(Icons.groups, color: Color(0xFF338C9A)),
                    title: Text(
                      groupName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text("عدد الأعضاء: $memberCount"),
                    trailing: IconButton(
                      icon: const Icon(Icons.more_vert),
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (context) => SafeArea(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ListTile(
                                  leading: Icon(
                                    isCreator ? Icons.delete : Icons.exit_to_app,
                                    color: isCreator
                                        ? Colors.redAccent
                                        : Colors.black87,
                                  ),
                                  title: Text(isCreator
                                      ? "حذف القروب"
                                      : "الخروج من القروب"),
                                  onTap: () async {
                                    Navigator.pop(context);
                                    if (isCreator) {
                                      await groupRef.child(groupName).remove();
                                    } else {
                                      await groupRef
                                          .child("$groupName/members/${currentUser!.uid}")
                                          .remove();
                                    }
                                    setState(() {});
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatRoomPage(
                            roomId: groupName,
                            isGroup: true,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20, right: 20),
                child: FloatingActionButton(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  onPressed: _showCreateGroupDialog,
                  child: const Icon(Icons.add),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: BaseLayout(
        activeItem: 'chat', // يرجّع الفوتر/الهيدر من الـ BaseLayout
        currentIndex: 3,
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              const SizedBox(height: 8),

              // تبويبات داخل Container أبيض بظل خفيف — (تصميمك القديم)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Container(
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
                  child: TabBar(
                    controller: _tabController,
                    labelColor: Theme.of(context).colorScheme.primary,
                    unselectedLabelColor: Colors.black54,
                    indicatorColor: Theme.of(context).colorScheme.primary,
                    tabs: const [
                      Tab(text: "بحث"),
                      Tab(text: "المجموعات"),
                      Tab(text: "المحادثات"),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // المحتوى
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    buildSearchTab(context),
                    buildGroupsTab(context),
                    buildChatsTab(context),
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
