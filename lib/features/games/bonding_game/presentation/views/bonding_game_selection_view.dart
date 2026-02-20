import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:system_5210/core/theme/app_theme.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:system_5210/core/utils/app_images.dart';
import 'package:system_5210/core/widgets/app_back_button.dart';
import 'package:system_5210/features/games/bonding_game/data/models/bonding_challenge.dart';
import 'package:system_5210/features/nutrition_scan/presentation/widgets/glass_container.dart';
import 'package:system_5210/features/games/bonding_game/presentation/manager/bonding_game_cubit.dart';
import 'package:system_5210/features/games/bonding_game/presentation/manager/bonding_game_state.dart';
import 'package:system_5210/features/games/bonding_game/presentation/views/bonding_game_contract_view.dart';
import 'package:system_5210/features/games/bonding_game/presentation/views/bonding_image_viewer.dart';
import 'package:system_5210/features/games/bonding_game/presentation/views/bonding_wall_view.dart';
import 'package:system_5210/l10n/app_localizations.dart';

class BondingGameSelectionView extends StatefulWidget {
  const BondingGameSelectionView({super.key});

  @override
  State<BondingGameSelectionView> createState() =>
      _BondingGameSelectionViewState();
}

class _BondingGameSelectionViewState extends State<BondingGameSelectionView>
    with TickerProviderStateMixin {
  int? selectedIndex;
  int? draggingIndex;
  double dragOffset = 0.0;
  bool isRevealed = false;

  late AnimationController _flipController;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  void _onPanUpdate(DragUpdateDetails details, int index) {
    if (selectedIndex != null) return;
    setState(() {
      draggingIndex = index;
      dragOffset -= details.delta.dy;
      if (dragOffset < 0) dragOffset = 0;
    });
  }

  void _onPanEnd(DragEndDetails details, BondingChallenge challenge) {
    if (selectedIndex != null || draggingIndex == null) return;

    final velocity = details.velocity.pixelsPerSecond.dy;

    if (dragOffset > 120 || velocity < -400) {
      _selectCard(draggingIndex!, challenge);
    } else {
      setState(() {
        dragOffset = 0;
        draggingIndex = null;
      });
    }
  }

  void _selectCard(int index, BondingChallenge challenge) {
    setState(() {
      selectedIndex = index;
      draggingIndex = null;
      dragOffset = 0;
    });
  }

  Future<void> _pickMemoryImage(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (bottomSheetContext) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.bondingCaptureMoment,
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.appBlue,
              ),
            ),
            const SizedBox(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildPickOption(
                  context,
                  icon: Icons.camera_alt_rounded,
                  label: l10n.bondingCamera,
                  color: AppTheme.appBlue,
                  onTap: () {
                    Navigator.pop(bottomSheetContext);
                    _handleImagePick(ImageSource.camera);
                  },
                ),
                _buildPickOption(
                  context,
                  icon: Icons.photo_library_rounded,
                  label: l10n.bondingGallery,
                  color: AppTheme.appGreen,
                  onTap: () {
                    Navigator.pop(bottomSheetContext);
                    _handleImagePick(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPickOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppTheme.appBlue,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleImagePick(ImageSource source) async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: source,
        imageQuality: 80,
      );

      if (photo != null) {
        final directory = await getApplicationDocumentsDirectory();
        final fileName =
            '${DateTime.now().millisecondsSinceEpoch}${path.extension(photo.path)}';
        final savedFile = await File(
          photo.path,
        ).copy('${directory.path}/$fileName');

        if (mounted) {
          context.read<BondingGameCubit>().addMemoryPhoto(savedFile.path);
        }
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final cardWidth = size.width * 0.60;
    final cardHeight = size.height * 0.42;

    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: const AppBackButton(),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(AppImages.authBackground, fit: BoxFit.cover),
          ),
          BlocBuilder<BondingGameCubit, BondingGameState>(
            builder: (context, state) {
              if (state is BondingGameReady) {
                if (state.isContractSigned) {
                  return _buildActiveChallengeView(state);
                }

                final bool isParent = state.currentTurn == BondingRole.parent;
                final Color roleColor = isParent
                    ? AppTheme.appBlue
                    : AppTheme.appGreen;

                return SafeArea(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        _buildHeader(state, selectedIndex != null),
                        SizedBox(
                          height: size.height * 0.60,
                          width: double.infinity,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              ...List.generate(state.options.length, (index) {
                                final isThisSelected = selectedIndex == index;
                                final isOtherSelected =
                                    selectedIndex != null && !isThisSelected;
                                final isDragging = draggingIndex == index;

                                double spreadX = (index - 1) * 65.0;
                                double rotation = (index - 1) * 0.15;
                                double stackY = index * 8.0;

                                double bottom = 20.0 + stackY;
                                double left =
                                    (size.width - cardWidth) / 2 +
                                    (isThisSelected ? 0 : spreadX);
                                double scale = 0.9 + (index * 0.03);
                                double opacity = 1.0;

                                if (isThisSelected) {
                                  bottom = 30.0;
                                  rotation = 0;
                                  scale = 1.1;
                                } else if (isOtherSelected) {
                                  bottom = -900;
                                  opacity = 0.0;
                                } else if (isDragging) {
                                  bottom += dragOffset;
                                  scale = 1.02;
                                  rotation = rotation * 0.5;
                                }

                                return AnimatedPositioned(
                                  duration: Duration(
                                    milliseconds: isDragging ? 0 : 700,
                                  ),
                                  curve: Curves.fastOutSlowIn,
                                  bottom: bottom,
                                  left: left,
                                  child: AnimatedOpacity(
                                    duration: const Duration(milliseconds: 300),
                                    opacity: opacity,
                                    child: Transform.rotate(
                                      angle: rotation,
                                      child: AnimatedScale(
                                        duration: const Duration(
                                          milliseconds: 500,
                                        ),
                                        scale: scale,
                                        child: GestureDetector(
                                          onPanUpdate: (d) =>
                                              _onPanUpdate(d, index),
                                          onPanEnd: (d) => _onPanEnd(
                                            d,
                                            state.options[index],
                                          ),
                                          onTap: () {
                                            if (isThisSelected && !isRevealed) {
                                              _flipController.forward();
                                              setState(() => isRevealed = true);
                                              context
                                                  .read<BondingGameCubit>()
                                                  .selectChallenge(
                                                    state.options[index],
                                                  );
                                            }
                                          },
                                          child: _ModernGlassCard(
                                            challenge: state.options[index],
                                            isRevealed: isRevealed,
                                            roleColor: roleColor,
                                            width: cardWidth,
                                            height: cardHeight,
                                            animation: _flipController,
                                            isParent: isParent,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                        _buildFooter(
                          isRevealed,
                          selectedIndex != null,
                          roleColor,
                        ),
                        const SizedBox(height: 103.3),
                      ],
                    ),
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

  Widget _buildHeader(BondingGameReady state, bool hasSelected) {
    final l10n = AppLocalizations.of(context)!;
    final bool isAr = Localizations.localeOf(context).languageCode == 'ar';
    final roleName = state.currentTurn == BondingRole.parent
        ? l10n.roleParent
        : l10n.roleChild;

    final roleColor = state.currentTurn == BondingRole.parent
        ? AppTheme.appBlue
        : AppTheme.appGreen;

    return Column(
      children: [
        Text(
          hasSelected
              ? l10n.bondingSelectedChallenge
              : l10n.bondingChooseDailyChallenge,
          textAlign: TextAlign.center,
          style: (isAr ? GoogleFonts.cairo : GoogleFonts.poppins)(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: roleColor,
          ),
        ).animate().fadeIn(),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: roleColor.withOpacity(hasSelected ? 0.1 : 0.05),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: roleColor.withOpacity(hasSelected ? 0.2 : 0.1),
            ),
          ),
          child: Text(
            hasSelected
                ? l10n.bondingChallengeFixed
                : l10n.bondingRoleTurn(roleName),
            style: (isAr ? GoogleFonts.cairo : GoogleFonts.poppins)(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: roleColor.withOpacity(0.8),
            ),
          ),
        ).animate().fadeIn(delay: 400.ms),
      ],
    );
  }

  Widget _buildFooter(bool isRevealed, bool hasSelected, Color color) {
    final l10n = AppLocalizations.of(context)!;
    final bool isAr = Localizations.localeOf(context).languageCode == 'ar';
    if (isRevealed) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: context.read<BondingGameCubit>(),
                    child: const BondingGameContractView(),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 60),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 0,
            ),
            child: Text(
              l10n.bondingConfirmChallenge,
              style: (isAr ? GoogleFonts.cairo : GoogleFonts.poppins)(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ).animate().fadeIn().scale(),
      );
    }

    return Column(
      children: [
        Icon(
              hasSelected
                  ? Icons.touch_app_rounded
                  : Icons.swipe_vertical_rounded,
              color: color.withOpacity(0.6),
              size: 24,
            )
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .moveY(begin: 0, end: -8),
        const SizedBox(height: 8),
        Text(
          hasSelected ? l10n.bondingTapToFlip : l10n.bondingSwipeUp,
          style: (isAr ? GoogleFonts.cairo : GoogleFonts.poppins)(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  Widget _buildActiveChallengeView(BondingGameReady state) {
    final l10n = AppLocalizations.of(context)!;
    final bool isAr = Localizations.localeOf(context).languageCode == 'ar';
    final challenge = state.selectedChallenge;
    if (challenge == null) return const SizedBox.shrink();

    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Column(
                children: [
                  // Superior Status Bar
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: AppTheme.appGreen,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          l10n.bondingActiveMission,
                          style:
                              (isAr ? GoogleFonts.cairo : GoogleFonts.poppins)(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: AppTheme.appBlue,
                              ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: AppTheme.appGreen,
                                shape: BoxShape.circle,
                              ),
                            )
                            .animate(onPlay: (c) => c.repeat())
                            .scale(
                              begin: const Offset(1, 1),
                              end: const Offset(2, 2),
                              duration: 1.seconds,
                            )
                            .fadeOut(),
                      ],
                    ),
                  ).animate().fadeIn().slideY(begin: -0.2),

                  const SizedBox(height: 25),

                  // The Mission Briefing Card
                  GlassContainer(
                        borderRadius: BorderRadius.circular(30),
                        blur: 25,
                        opacity: 0.1,
                        color: Colors.white,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.appBlue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                challenge.role == BondingRole.parent
                                    ? l10n.bondingMissionRoleParent
                                    : l10n.bondingMissionRoleChild,
                                style:
                                    (isAr
                                    ? GoogleFonts.cairo
                                    : GoogleFonts.poppins)(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.appBlue,
                                      letterSpacing: 0.5,
                                    ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              challenge.title,
                              textAlign: TextAlign.center,
                              style:
                                  (isAr
                                  ? GoogleFonts.cairo
                                  : GoogleFonts.poppins)(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w900,
                                    color: AppTheme.appBlue,
                                    height: 1.2,
                                  ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              width: 40,
                              height: 3,
                              decoration: BoxDecoration(
                                color: AppTheme.appBlue.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              challenge.description,
                              textAlign: TextAlign.center,
                              style:
                                  (isAr
                                  ? GoogleFonts.cairo
                                  : GoogleFonts.poppins)(
                                    fontSize: 14,
                                    color: AppTheme.appBlue.withOpacity(0.7),
                                    fontWeight: FontWeight.w600,
                                    height: 1.6,
                                  ),
                            ),
                            const SizedBox(height: 30),

                            // Photos Section (Mission Proofs)
                            if (state.memoryPhotoPaths.isNotEmpty)
                              _buildPhotosList(
                                state.memoryPhotoPaths,
                                challenge.title,
                              )
                            else
                              _buildPhotoPlaceholder(l10n),

                            if (state.memoryPhotoPaths.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 20),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () => _pickMemoryImage(context),
                                    borderRadius: BorderRadius.circular(12),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.add_a_photo_rounded,
                                            size: 18,
                                            color: AppTheme.appBlue,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            l10n.bondingAddAnotherPhoto,
                                            style:
                                                (isAr
                                                ? GoogleFonts.cairo
                                                : GoogleFonts.poppins)(
                                                  fontWeight: FontWeight.w900,
                                                  fontSize: 13,
                                                  color: AppTheme.appBlue,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      )
                      .animate()
                      .fadeIn(delay: 200.ms)
                      .scale(begin: const Offset(0.95, 0.95)),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
          _buildActiveViewFooter(l10n),
        ],
      ),
    );
  }

  Widget _buildPhotosList(List<String> photoPaths, String title) {
    final screenWidth = MediaQuery.of(context).size.width;
    final itemWidth = screenWidth * 0.65;

    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: photoPaths.length,
        padding: const EdgeInsets.symmetric(horizontal: 5),
        itemBuilder: (context, index) {
          return Container(
            width: itemWidth,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            child: Stack(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BondingImageViewer(
                          photoPaths: photoPaths,
                          initialIndex: index,
                          title: title,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.white, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(26),
                      child: Image.file(
                        File(photoPaths[index]),
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 15,
                  right: 15,
                  child: Row(
                    children: [
                      _buildCircularAction(
                        icon: Icons.delete_outline_rounded,
                        color: Colors.redAccent,
                        onTap: () => context
                            .read<BondingGameCubit>()
                            .deleteMemoryPhoto(index),
                      ),
                    ],
                  ),
                ),
              ],
            ).animate().scale(delay: (index * 100).ms),
          );
        },
      ),
    );
  }

  Widget _buildCircularAction({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: GlassContainer(
        blur: 10,
        opacity: 0.8,
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        padding: const EdgeInsets.all(8),
        child: Icon(icon, size: 20, color: color),
      ),
    );
  }

  Widget _buildPhotoPlaceholder(AppLocalizations l10n) {
    return InkWell(
          onTap: () => _pickMemoryImage(context),
          child: Container(
            height: 140,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppTheme.appBlue.withOpacity(0.05),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: AppTheme.appBlue.withOpacity(0.15),
                style: BorderStyle.solid,
                width: 2,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.add_a_photo_rounded,
                  color: AppTheme.appBlue,
                  size: 40,
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.bondingCaptureMoment,
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.appBlue.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .shimmer(duration: 3.seconds);
  }

  Widget _buildActiveViewFooter(AppLocalizations l10n) {
    final bool isAr = Localizations.localeOf(context).languageCode == 'ar';
    return BlocBuilder<BondingGameCubit, BondingGameState>(
      builder: (context, state) {
        if (state is! BondingGameReady) return const SizedBox.shrink();
        final canComplete = state.memoryPhotoPaths.isNotEmpty;

        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: ElevatedButton(
            onPressed: canComplete
                ? () async {
                    await context.read<BondingGameCubit>().completeMission();
                    if (mounted) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BlocProvider.value(
                            value: context.read<BondingGameCubit>(),
                            child: const BondingWallView(),
                          ),
                        ),
                      );
                    }
                  }
                : () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: canComplete
                  ? AppTheme.appGreen
                  : AppTheme.appBlue,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 60),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 10,
              shadowColor: (canComplete ? AppTheme.appGreen : AppTheme.appBlue)
                  .withOpacity(0.5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  canComplete ? Icons.task_alt_rounded : Icons.home_rounded,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  canComplete ? l10n.bondingMissionSuccess : l10n.bondingGoHome,
                  style: (isAr ? GoogleFonts.cairo : GoogleFonts.poppins)(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ModernGlassCard extends StatelessWidget {
  final BondingChallenge challenge;
  final bool isRevealed;
  final Color roleColor;
  final double width;
  final double height;
  final Animation<double> animation;

  final bool isParent;

  const _ModernGlassCard({
    required this.challenge,
    required this.isRevealed,
    required this.roleColor,
    required this.width,
    required this.height,
    required this.animation,
    required this.isParent,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final value = animation.value;
        final rotation = value * math.pi;
        final scale = 1.0 + (math.sin(value * math.pi) * 0.08);

        return Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(rotation)
            ..scale(scale),
          alignment: Alignment.center,
          child: rotation <= math.pi / 2
              ? _buildBack()
              : Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.rotationY(math.pi),
                  child: _buildFront(),
                ),
        );
      },
    );
  }

  Widget _buildBack() {
    return SizedBox(
      width: width,
      height: height,
      child: GlassContainer(
        borderRadius: BorderRadius.circular(24),
        blur: 15,
        opacity: 0.2,
        color: roleColor.withOpacity(0.1),
        border: Border.all(color: roleColor.withOpacity(0.5), width: 3),
        padding: const EdgeInsets.all(8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.asset(
            isParent ? AppImages.challengeParent : AppImages.challengeChild,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _buildFront() {
    return SizedBox(
      width: width,
      height: height,
      child: GlassContainer(
        borderRadius: BorderRadius.circular(24),
        blur: 20,
        opacity: 0.2,
        color: roleColor.withOpacity(0.1),
        border: Border.all(color: roleColor.withOpacity(0.5), width: 3),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.stars_rounded,
                size: 40,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 15),
            Text(
              challenge.title,
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 8),
            Container(height: 2, width: 50, color: roleColor.withOpacity(0.3)),
            const SizedBox(height: 15),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Text(
                  challenge.description,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    color: const Color(0xFF374151),
                    height: 1.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
