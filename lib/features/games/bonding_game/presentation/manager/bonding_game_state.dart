import 'package:equatable/equatable.dart';
import '../../data/models/bonding_challenge.dart';
import '../../data/models/bonding_memory.dart';

abstract class BondingGameState extends Equatable {
  const BondingGameState();

  @override
  List<Object?> get props => [];
}

class BondingGameInitial extends BondingGameState {}

class BondingGameLoading extends BondingGameState {}

class BondingGameReady extends BondingGameState {
  final BondingRole currentTurn;
  final bool isTurnRevealed;
  final List<BondingChallenge> options;
  final BondingChallenge? selectedChallenge;
  final bool isContractSigned;
  final String? lastTurnDate;
  final bool isScrollingLocked;
  final List<String> memoryPhotoPaths;
  final List<BondingMemory> wallMemories;
  final int streakCount;
  final bool isMissionAccomplished;

  const BondingGameReady({
    required this.currentTurn,
    required this.isTurnRevealed,
    required this.options,
    this.selectedChallenge,
    this.isContractSigned = false,
    this.lastTurnDate,
    this.isScrollingLocked = false,
    this.memoryPhotoPaths = const [],
    this.wallMemories = const [],
    this.streakCount = 0,
    this.isMissionAccomplished = false,
  });

  BondingGameReady copyWith({
    BondingRole? currentTurn,
    bool? isTurnRevealed,
    List<BondingChallenge>? options,
    BondingChallenge? selectedChallenge,
    bool? isContractSigned,
    String? lastTurnDate,
    bool? isScrollingLocked,
    List<String>? memoryPhotoPaths,
    List<BondingMemory>? wallMemories,
    int? streakCount,
    bool? isMissionAccomplished,
  }) {
    return BondingGameReady(
      currentTurn: currentTurn ?? this.currentTurn,
      isTurnRevealed: isTurnRevealed ?? this.isTurnRevealed,
      options: options ?? this.options,
      selectedChallenge: selectedChallenge ?? this.selectedChallenge,
      isContractSigned: isContractSigned ?? this.isContractSigned,
      lastTurnDate: lastTurnDate ?? this.lastTurnDate,
      isScrollingLocked: isScrollingLocked ?? this.isScrollingLocked,
      memoryPhotoPaths: memoryPhotoPaths ?? this.memoryPhotoPaths,
      wallMemories: wallMemories ?? this.wallMemories,
      streakCount: streakCount ?? this.streakCount,
      isMissionAccomplished:
          isMissionAccomplished ?? this.isMissionAccomplished,
    );
  }

  @override
  List<Object?> get props => [
    currentTurn,
    isTurnRevealed,
    options,
    selectedChallenge,
    isContractSigned,
    lastTurnDate,
    isScrollingLocked,
    memoryPhotoPaths,
    wallMemories,
    streakCount,
    isMissionAccomplished,
  ];
}

class BondingGameError extends BondingGameState {
  final String message;
  const BondingGameError(this.message);

  @override
  List<Object?> get props => [message];
}
