import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:system_5210/core/theme/app_theme.dart';
import 'package:system_5210/core/utils/app_images.dart';
import 'package:system_5210/core/widgets/app_back_button.dart';
import 'package:system_5210/core/widgets/app_loading_indicator.dart';
import 'package:system_5210/features/games/food_matching/presentation/cubit/food_matching_cubit.dart';
import 'package:system_5210/features/games/food_matching/presentation/cubit/food_matching_state.dart';
import 'package:system_5210/features/games/food_matching/presentation/widgets/matching_card.dart';
import 'package:system_5210/features/games/food_matching/presentation/widgets/matching_line_painter.dart';
import 'package:system_5210/features/games/food_matching/presentation/widgets/matching_result_overlay.dart';

class FoodMatchingView extends StatefulWidget {
  const FoodMatchingView({super.key});

  @override
  State<FoodMatchingView> createState() => _FoodMatchingViewState();
}

class _FoodMatchingViewState extends State<FoodMatchingView> {
  @override
  void initState() {
    super.initState();
    context.read<FoodMatchingCubit>().startGame();
  }

  final List<GlobalKey> _wordKeys = List.generate(4, (_) => GlobalKey());
  final List<GlobalKey> _imageKeys = List.generate(4, (_) => GlobalKey());

  Offset _getPoint(GlobalKey key, bool isLeft) {
    final RenderBox? box = key.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return Offset.zero;
    final position = box.localToGlobal(Offset.zero);
    final stackBox = _stackKey.currentContext?.findRenderObject() as RenderBox?;
    if (stackBox == null) return position;
    final localPosition = stackBox.globalToLocal(position);
    return Offset(
      localPosition.dx + (isLeft ? box.size.width : 0),
      localPosition.dy + box.size.height / 2,
    );
  }

  final GlobalKey _stackKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const AppBackButton(),
        title: Text(
          'لعبة التوصيل الذكية',
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.w900,
            fontSize: 22,
            color: const Color(0xFF1E293B),
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(AppImages.authBackground, fit: BoxFit.cover),
          ),

          // Hint Text - WITHOUT white overlay as requested
          Positioned(
            top: 110,
            left: 24,
            right: 24,
            child: Center(
              child:
                  Text(
                        'اسحب الكلمة ووصلها بصورتها المناسبة',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          color: const Color(0xFF475569),
                          fontWeight: FontWeight.w900,
                        ),
                      )
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .shimmer(
                        duration: 2.seconds,
                        color: AppTheme.appBlue.withOpacity(0.3),
                      ),
            ),
          ),

          BlocBuilder<FoodMatchingCubit, FoodMatchingState>(
            builder: (context, state) {
              if (state is FoodMatchingLoading) {
                return const Center(child: AppLoadingIndicator());
              }

              if (state is FoodMatchingGameInProgress) {
                return _buildGameBoard(context, state);
              }

              if (state is FoodMatchingSuccess) {
                return MatchingResultOverlay(
                  stars: state.stars,
                  duration: state.duration,
                  wrongAttempts: state.totalWrongAttempts,
                  onRetry: () => context.read<FoodMatchingCubit>().startGame(),
                  onExit: () => Navigator.pop(context),
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGameBoard(
    BuildContext context,
    FoodMatchingGameInProgress state,
  ) {
    return SafeArea(
      child: Stack(
        key: _stackKey,
        children: [
          // The Line Drawing Layer
          Positioned.fill(
            child: RepaintBoundary(
              child: CustomPaint(
                painter: MatchingLinePainter(
                  completedLines: state.matches.entries.map((e) {
                    final wordIndex = state.words.indexWhere(
                      (w) => w.id == e.key,
                    );
                    final imageIndex = state.images.indexWhere(
                      (i) => i.id == e.value,
                    );
                    return MatchingLine(
                      start: _getPoint(_wordKeys[wordIndex], true),
                      end: _getPoint(_imageKeys[imageIndex], false),
                      isCompleted: true,
                    );
                  }).toList(),
                  activeStart: state.dragStart,
                  activeEnd: state.dragCurrent,
                ),
              ),
            ),
          ),

          // Cards Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Words Column
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(state.words.length, (index) {
                      final item = state.words[index];
                      final isMatched = state.matches.containsKey(item.id);
                      final isSelected = state.activeWordIndex == index;

                      return Draggable<String>(
                        key:
                            _wordKeys[index], // Key moved to Draggable for stability
                        data: item.id,
                        feedback: Material(
                          color: Colors.transparent,
                          child: MatchingCard(
                            item: item,
                            isImage: false,
                            isSelected: true,
                            isMatched: false,
                          ),
                        ),
                        childWhenDragging: Opacity(
                          opacity: 0.3,
                          child: MatchingCard(
                            item: item,
                            isImage: false,
                            isSelected: false,
                            isMatched: isMatched,
                          ),
                        ),
                        onDragStarted: () {
                          final startPoint = _getPoint(_wordKeys[index], true);
                          context.read<FoodMatchingCubit>().updateDrag(
                            startPoint,
                            startPoint, // Start at word edge
                            index,
                          );
                        },
                        onDragUpdate: (details) {
                          // Note: We use the word handle center as start point
                          context.read<FoodMatchingCubit>().updateDrag(
                            _getPoint(_wordKeys[index], true),
                            (_stackKey.currentContext!.findRenderObject()!
                                    as RenderBox)
                                .globalToLocal(details.globalPosition),
                            index,
                          );
                        },
                        onDragEnd: (details) {
                          context.read<FoodMatchingCubit>().onDragEnd(
                            item.id,
                            null,
                          );
                        },
                        child: MatchingCard(
                          item: item,
                          isImage: false,
                          isSelected: isSelected,
                          isMatched: isMatched,
                        ),
                      );
                    }),
                  ),
                ),

                const SizedBox(width: 40),

                // Images Column
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(state.images.length, (index) {
                      final item = state.images[index];
                      final isMatched = state.matches.containsValue(item.id);

                      return DragTarget<String>(
                        key: _imageKeys[index], // Key on DragTarget
                        onWillAccept: (data) => !isMatched,
                        onAccept: (data) {
                          context.read<FoodMatchingCubit>().onDragEnd(
                            data,
                            item.id,
                          );
                        },
                        builder: (context, candidateData, rejectedData) {
                          return MatchingCard(
                            item: item,
                            isImage: true,
                            isSelected: candidateData.isNotEmpty,
                            isMatched: isMatched,
                          );
                        },
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
