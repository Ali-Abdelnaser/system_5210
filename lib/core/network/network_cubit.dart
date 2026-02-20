import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'network_info.dart';

enum NetworkState { initial, online, offline, backOnline }

class NetworkCubit extends Cubit<NetworkState> {
  final NetworkInfo networkInfo;
  StreamSubscription? _subscription;
  Timer? _offlineDebounceTimer;

  NetworkCubit(this.networkInfo) : super(NetworkState.initial) {
    _init();
  }

  void _init() async {
    final isConnected = await networkInfo.isConnected;
    emit(isConnected ? NetworkState.online : NetworkState.offline);

    _subscription = networkInfo.onStatusChange.listen((status) {
      if (status == InternetStatus.connected) {
        _handleOnline();
      } else {
        _handleOffline();
      }
    });
  }

  void _handleOnline() {
    _offlineDebounceTimer?.cancel();
    if (state == NetworkState.offline) {
      emit(NetworkState.backOnline);
      Future.delayed(const Duration(seconds: 2), () {
        if (state == NetworkState.backOnline) {
          emit(NetworkState.online);
        }
      });
    } else {
      emit(NetworkState.online);
    }
  }

  void _handleOffline() {
    // If already offline or already waiting to be offline, don't do anything
    if (state == NetworkState.offline ||
        _offlineDebounceTimer?.isActive == true) {
      return;
    }

    // Wait for 3 seconds before truly committing to offline state
    // This handles weak/fluctuating signals
    _offlineDebounceTimer = Timer(const Duration(seconds: 3), () async {
      final isStillDisconnected = !await networkInfo.isConnected;
      if (isStillDisconnected) {
        emit(NetworkState.offline);
      }
    });
  }

  void checkConnection() async {
    final isConnected = await networkInfo.isConnected;
    if (isConnected) {
      _handleOnline();
    } else {
      emit(NetworkState.offline);
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    _offlineDebounceTimer?.cancel();
    return super.close();
  }
}
