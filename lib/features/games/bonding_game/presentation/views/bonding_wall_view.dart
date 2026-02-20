import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:system_5210/core/theme/app_theme.dart';
import 'package:system_5210/core/utils/app_images.dart';
import 'package:system_5210/core/widgets/app_back_button.dart';
import 'package:system_5210/features/games/bonding_game/presentation/manager/bonding_game_cubit.dart';
import 'package:system_5210/features/games/bonding_game/presentation/manager/bonding_game_state.dart';
import 'package:system_5210/features/games/bonding_game/presentation/views/bonding_image_viewer.dart';
import 'package:system_5210/features/nutrition_scan/presentation/widgets/glass_container.dart';
import 'package:system_5210/l10n/app_localizations.dart';

class BondingWallView extends StatelessWidget {
  const BondingWallView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bool isAr = Localizations.localeOf(context).languageCode == 'ar';
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: const AppBackButton(),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Opacity(
              opacity: 1,
              child: Image.asset(AppImages.authBackground, fit: BoxFit.cover),
            ),
          ),

          BlocBuilder<BondingGameCubit, BondingGameState>(
            builder: (context, state) {
              if (state is BondingGameReady) {
                final memories = state.wallMemories;

                return SafeArea(
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.bondingWallSubtitle,
                                style:
                                    (isAr
                                    ? GoogleFonts.cairo
                                    : GoogleFonts.poppins)(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.appBlue.withOpacity(0.7),
                                    ),
                              ),
                              Text(
                                l10n.bondingWallTitle,
                                style:
                                    (isAr
                                    ? GoogleFonts.cairo
                                    : GoogleFonts.poppins)(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w900,
                                      color: AppTheme.appBlue,
                                    ),
                              ),
                              const SizedBox(height: 10),
                              Container(
                                width: 60,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: AppTheme.appBlue,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      if (memories.isEmpty)
                        SliverFillRemaining(
                          child: _buildEmptyState(context, l10n),
                        )
                      else
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          sliver: SliverGrid(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                  childAspectRatio: 0.75,
                                ),
                            delegate: SliverChildBuilderDelegate((
                              context,
                              index,
                            ) {
                              final memory = memories[index];
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => BondingImageViewer(
                                        photoPaths: memory.photoPaths,
                                        title: memory.title,
                                      ),
                                    ),
                                  );
                                },
                                child: _buildScrapbookCard(context, memory)
                                    .animate()
                                    .fadeIn(delay: (index * 80).ms)
                                    .scale(
                                      delay: (index * 80).ms,
                                      curve: Curves.fastOutSlowIn,
                                    ),
                              );
                            }, childCount: memories.length),
                          ),
                        ),
                      const SliverToBoxAdapter(child: SizedBox(height: 50)),
                    ],
                  ),
                );
              }
              return const Center(child: CircularProgressIndicator());
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    final bool isAr = Localizations.localeOf(context).languageCode == 'ar';
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.appBlue.withOpacity(0.1),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                        Icons.auto_awesome_rounded,
                        size: 100,
                        color: AppTheme.appBlue.withOpacity(0.1),
                      )
                      .animate(onPlay: (c) => c.repeat())
                      .rotate(duration: 10.seconds),
                  Icon(
                    Icons.photo_library_rounded,
                    size: 60,
                    color: AppTheme.appBlue.withOpacity(0.6),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text(
              l10n.bondingWallWaiting,
              textAlign: TextAlign.center,
              style: (isAr ? GoogleFonts.cairo : GoogleFonts.poppins)(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: AppTheme.appBlue,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.bondingNoMemories,
              textAlign: TextAlign.center,
              style: (isAr ? GoogleFonts.cairo : GoogleFonts.poppins)(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.appBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 8,
                shadowColor: AppTheme.appBlue.withOpacity(0.4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.flash_on_rounded),
                  const SizedBox(width: 12),
                  Text(
                    l10n.bondingStartFirstChallengeNow,
                    style: (isAr ? GoogleFonts.cairo : GoogleFonts.poppins)(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScrapbookCard(BuildContext context, dynamic memory) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.file(
                      File(memory.photoPaths.first),
                      fit: BoxFit.cover,
                    ),
                  ),
                  // Delete Button
                  Positioned(
                    top: 10,
                    left: 10,
                    child: GestureDetector(
                      onTap: () {
                        // Show confirm dialog
                        showDialog(
                          context: context,
                          builder: (dialogCtx) => AlertDialog(
                            title: const Text("حذف الذكرى"),
                            content: const Text(
                              "هل أنت متأكد من حذف هذه الذكرى من الحائط؟",
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(dialogCtx),
                                child: const Text("إلغاء"),
                              ),
                              TextButton(
                                onPressed: () {
                                  context.read<BondingGameCubit>().deleteMemory(
                                    memory.id,
                                  );
                                  Navigator.pop(dialogCtx);
                                },
                                child: const Text(
                                  "حذف",
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      child: GlassContainer(
                        blur: 10,
                        opacity: 0.4,
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                        padding: const EdgeInsets.all(6),
                        child: const Icon(
                          Icons.delete_forever_rounded,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  memory.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.appBlue,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 14,
                      color: AppTheme.appBlue.withOpacity(0.6),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      memory.date,
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.appBlue.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
