// By: Zainab 
// Design in Flutter : Zainab Alaujami
import 'dart:convert';
import 'config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'custom_header.dart';
import 'custom_bottom_nav.dart';
import 'custom_drawer.dart'; 

class PostDetailsPage extends StatefulWidget {
  final String neighborhoodId; 
  final String postId;
  final String text;
  final String createdAt;

  const PostDetailsPage({
    super.key,
    required this.neighborhoodId,
    required this.postId,
    required this.text,
    required this.createdAt,
  });

  @override
  State<PostDetailsPage> createState() => _PostDetailsPageState();
}

class _PostDetailsPageState extends State<PostDetailsPage> {
  final TextEditingController _replyController = TextEditingController();
  List<String> replies = [];

  @override
  void initState() {
    super.initState();
    fetchReplies();
  }

  Future<void> fetchReplies() async {
    final url = Uri.parse(
      '$kDatabaseUrl/communitys/${widget.neighborhoodId}/${widget.postId}/replies.json',
    );

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data != null && data is List) {
        setState(() {
          replies = List<String>.from(data);
        });
      }
    }
  }

  Future<void> submitReply() async {
    final reply = _replyController.text.trim();
    if (reply.isEmpty) return;

    replies.add(reply);

    final url = Uri.parse(
      '$kDatabaseUrl/communitys/${widget.neighborhoodId}/${widget.postId}/replies.json',
    );

    final response = await http.put(
      url,
      body: json.encode(replies),
    );

    if (response.statusCode == 200) {
      setState(() => _replyController.clear());
      fetchReplies();
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('فشل في إرسال الرد')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,

        
        endDrawer: const CustomDrawer(),          
        endDrawerEnableOpenDragGesture: false,      
        drawerEnableOpenDragGesture: true,

        body: Column(
          children: [
            const CustomHeaderAppBar(title: 'تفاصيل المشاركة'),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPostCard(),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        const Text(
                          'الردود',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: accent.withOpacity(.10),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${replies.length}',
                            style: TextStyle(
                              color: accent,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    Expanded(
                      child: replies.isEmpty
                          ? const Center(
                              child: Text(
                                'لا توجد ردود بعد.',
                                style: TextStyle(
                                    fontSize: 14, color: Colors.black54),
                              ),
                            )
                          : ListView.separated(
                              padding: EdgeInsets.zero,
                              itemCount: replies.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 10),
                              itemBuilder: (context, index) => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(.06),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(Icons.reply,
                                        color: accent, size: 20),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        replies[index],
                                        style: const TextStyle(fontSize: 15),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _replyController,
                            decoration: InputDecoration(
                              hintText: 'اكتب ردك هنا...',
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.black.withOpacity(.15),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.black.withOpacity(.15),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    BorderSide(color: accent, width: 1.5),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: submitReply,
                          icon: const Icon(Icons.send_outlined,
                              color: Colors.white, size: 18),
                          label: const Text(
                            'إرسال',
                            overflow: TextOverflow.visible,
                            softWrap: false,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accent,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(120, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar:
            const CustomBottomNav(currentIndex: 1, activeItem: 'community'),
      ),
    );
  }

  /// كرت عرض نص المشاركة وتاريخها
  Widget _buildPostCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.text, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 10),
          Text(
            widget.createdAt,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
