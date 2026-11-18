import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/features/common/ride/domain/entities/ride_entity.dart';
import 'package:mishwar/features/common/ride/domain/usecases/watch_ride.dart';
import 'package:mishwar/features/common/support/domain/support_ticket.dart';
import 'package:mishwar/features/common/support/domain/support_usecases.dart';

class SupportListState extends Equatable {
  const SupportListState({
    this.tickets = const [],
    this.loading = true,
    this.failure,
    this.filter,
  });
  final List<SupportTicket> tickets;
  final bool loading;
  final Failure? failure;
  final SupportStatus? filter;
  bool get unread => tickets.any((ticket) => ticket.userUnread);
  @override
  List<Object?> get props => [tickets, loading, failure, filter];
}

@injectable
class SupportListCubit extends Cubit<SupportListState> {
  SupportListCubit(this._watch) : super(const SupportListState());
  final WatchSupportTickets _watch;
  StreamSubscription<dynamic>? _subscription;
  int _generation = 0;
  Future<void> start({String? uid, SupportStatus? status}) async {
    final generation = ++_generation;
    await _subscription?.cancel();
    if (isClosed || generation != _generation) return;
    emit(SupportListState(filter: status));
    _subscription = _watch(uid: uid, status: status).listen((result) {
      if (isClosed || generation != _generation) return;
      result.fold(
        (failure) => emit(
          SupportListState(loading: false, failure: failure, filter: status),
        ),
        (tickets) => emit(
          SupportListState(
            tickets: List.unmodifiable(tickets),
            loading: false,
            filter: status,
          ),
        ),
      );
    });
  }

  @override
  Future<void> close() async {
    ++_generation;
    await _subscription?.cancel();
    return super.close();
  }
}

class NewSupportState extends Equatable {
  const NewSupportState({
    this.category = SupportCategory.other,
    this.saving = false,
    this.failure,
    this.ride,
    this.loadingRide = false,
  });
  final SupportCategory category;
  final bool saving;
  final Failure? failure;
  final RideEntity? ride;
  final bool loadingRide;
  @override
  List<Object?> get props => [category, saving, failure, ride, loadingRide];
}

@injectable
class NewSupportCubit extends Cubit<NewSupportState> {
  NewSupportCubit(this._create, this._ride) : super(const NewSupportState());
  final CreateSupportTicket _create;
  final WatchRide _ride;
  StreamSubscription<dynamic>? _subscription;
  String? _rideId;
  Future<void> retryRide() async {
    await _subscription?.cancel();
    if (!isClosed) start(_rideId);
  }

  void start(String? rideId) {
    _rideId = rideId;
    if (rideId == null) return;
    emit(NewSupportState(category: state.category, loadingRide: true));
    _subscription = _ride(rideId).listen((result) {
      if (isClosed) return;
      result.fold(
        (failure) => emit(
          NewSupportState(
            category: state.category,
            saving: state.saving,
            failure: failure,
          ),
        ),
        (ride) => emit(
          NewSupportState(
            category: state.category,
            saving: state.saving,
            ride: ride,
          ),
        ),
      );
    });
  }

  void select(SupportCategory category) {
    if (!state.saving) {
      emit(
        NewSupportState(
          category: category,
          ride: state.ride,
          loadingRide: state.loadingRide,
        ),
      );
    }
  }

  Future<String?> submit(String message) async {
    if (state.saving ||
        state.loadingRide ||
        (_rideId != null && state.ride == null)) {
      return null;
    }
    emit(
      NewSupportState(category: state.category, ride: state.ride, saving: true),
    );
    final result = await _create(state.category, message, rideId: _rideId);
    if (isClosed) return null;
    emit(
      NewSupportState(
        category: state.category,
        ride: state.ride,
        failure: result.getLeft().toNullable(),
      ),
    );
    return result.getRight().toNullable();
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}

class SupportThreadState extends Equatable {
  const SupportThreadState({
    this.ticket,
    this.messages = const [],
    this.loading = true,
    this.busy = false,
    this.failure,
  });
  final SupportTicket? ticket;
  final List<SupportMessage> messages;
  final bool loading;
  final bool busy;
  final Failure? failure;
  @override
  List<Object?> get props => [ticket, messages, loading, busy, failure];
}

@injectable
class SupportThreadCubit extends Cubit<SupportThreadState> {
  SupportThreadCubit(
    this._ticket,
    this._messages,
    this._send,
    this._read,
    this._status,
  ) : super(const SupportThreadState());
  final WatchSupportTicket _ticket;
  final WatchSupportMessages _messages;
  final SendSupportMessage _send;
  final MarkSupportRead _read;
  final SetSupportStatus _status;
  StreamSubscription<dynamic>? _ticketSubscription;
  StreamSubscription<dynamic>? _messageSubscription;
  String? _id;
  bool _admin = false;
  bool _marking = false;
  int _generation = 0;
  void _set({
    SupportTicket? ticket,
    List<SupportMessage>? messages,
    bool? loading,
    bool? busy,
    Failure? failure,
  }) => emit(
    SupportThreadState(
      ticket: ticket ?? state.ticket,
      messages: messages ?? state.messages,
      loading: loading ?? state.loading,
      busy: busy ?? state.busy,
      failure: failure,
    ),
  );
  Future<void> retry() async {
    final id = _id;
    if (id != null) await start(id, admin: _admin);
  }

  Future<void> start(String id, {bool admin = false}) async {
    final generation = ++_generation;
    await _ticketSubscription?.cancel();
    await _messageSubscription?.cancel();
    if (isClosed || generation != _generation) return;
    _id = id;
    _admin = admin;
    emit(const SupportThreadState());
    _ticketSubscription = _ticket(id).listen((result) {
      if (isClosed || generation != _generation) return;
      result.fold((failure) => _set(loading: false, failure: failure), (
        ticket,
      ) {
        _set(ticket: ticket);
        if (!admin && ticket.userUnread && !_marking) unawaited(markRead());
      });
    });
    _messageSubscription = _messages(id).listen((result) {
      if (isClosed || generation != _generation) return;
      result.fold(
        (failure) => _set(loading: false, failure: failure),
        (messages) =>
            _set(messages: List.unmodifiable(messages), loading: false),
      );
    });
  }

  Future<void> markRead() async {
    final id = _id;
    final generation = _generation;
    if (id == null || _admin || _marking) return;
    _marking = true;
    final result = await _read(id);
    _marking = false;
    if (!isClosed && generation == _generation) {
      result.fold((failure) => _set(failure: failure), (_) {});
    }
  }

  Future<bool> send(String text) async {
    final id = _id;
    final generation = _generation;
    if (id == null ||
        state.busy ||
        state.ticket == null ||
        state.ticket!.status == SupportStatus.closed) {
      return false;
    }
    _set(busy: true);
    final result = await _send(id, text, admin: _admin);
    if (isClosed || generation != _generation) return false;
    final failure = result.getLeft().toNullable();
    _set(busy: false, failure: failure);
    return failure == null;
  }

  Future<void> setStatus(SupportStatus status) async {
    final id = _id;
    final generation = _generation;
    if (!_admin || id == null || state.busy) return;
    _set(busy: true);
    final result = await _status(id, status);
    if (!isClosed && generation == _generation) {
      _set(busy: false, failure: result.getLeft().toNullable());
    }
  }

  @override
  Future<void> close() async {
    ++_generation;
    await _ticketSubscription?.cancel();
    await _messageSubscription?.cancel();
    return super.close();
  }
}
