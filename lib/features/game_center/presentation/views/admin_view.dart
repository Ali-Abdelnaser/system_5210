import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:system_5210/core/theme/app_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:system_5210/features/game_center/data/models/user_points_model.dart';
import 'package:system_5210/features/game_center/presentation/manager/user_points_cubit.dart';
import 'package:system_5210/core/widgets/profile_image_loader.dart';

class AdminView extends StatefulWidget {
  const AdminView({super.key});

  @override
  State<AdminView> createState() => _AdminViewState();
}

class _AdminViewState extends State<AdminView> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'لوحة تحكم المشرف',
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppTheme.appBlue,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('user_points')
            .orderBy('totalPoints', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final allPlayers = snapshot.data!.docs.map((doc) {
            final data = doc.data();
            return LeaderboardEntry(
              uid: doc.id,
              name: data['userName'] ?? 'لاعب',
              photoUrl: data['userPhoto'],
              points: data['totalPoints'] ?? 0,
            );
          }).toList();

          final filteredPlayers = allPlayers
              .where(
                (p) =>
                    p.name.toLowerCase().contains(_searchQuery.toLowerCase()),
              )
              .toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'البحث عن مستخدم...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onChanged: (val) => setState(() => _searchQuery = val),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: filteredPlayers.length,
                  itemBuilder: (context, index) {
                    final player = filteredPlayers[index];
                    return ListTile(
                      leading: ProfileImageLoader(
                        photoUrl: player.photoUrl,
                        displayName: player.name,
                        size: 40,
                      ),
                      title: Text(
                        player.name,
                        style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'النقاط: ${player.points}',
                        style: GoogleFonts.poppins(),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.refresh,
                              color: Colors.orange,
                            ),
                            onPressed: () => _showResetDialog(context, player),
                            tooltip: 'تصفير النقاط',
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_forever,
                              color: Colors.red,
                            ),
                            onPressed: () => _showWipeDialog(context, player),
                            tooltip: 'مسح كل التقدم',
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showResetDialog(BuildContext context, LeaderboardEntry player) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأكيد التصفير'),
        content: Text('هل أنت متأكد من تصفير نقاط ${player.name}؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            onPressed: () {
              context.read<UserPointsCubit>().adminResetUser(player.uid);
              Navigator.pop(ctx);
            },
            child: const Text('تصفير'),
          ),
        ],
      ),
    );
  }

  void _showWipeDialog(BuildContext context, LeaderboardEntry player) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('مسح شامل'),
        content: Text(
          'سيتم مسح كل تقدم ${player.name} في جميع الألعاب. لا يمكن التراجع!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              context.read<UserPointsCubit>().adminResetUser(player.uid);
              Navigator.pop(ctx);
            },
            child: const Text('مسح كلي'),
          ),
        ],
      ),
    );
  }
}
