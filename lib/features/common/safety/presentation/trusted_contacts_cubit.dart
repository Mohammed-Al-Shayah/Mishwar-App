import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/features/common/safety/domain/safety_usecases.dart';
import 'package:mishwar/features/common/safety/domain/trusted_contact.dart';

class TrustedContactsState extends Equatable {
  const TrustedContactsState({
    this.contacts = const [],
    this.loading = true,
    this.saving = false,
    this.failure,
  });
  final List<TrustedContact> contacts;
  final bool loading;
  final bool saving;
  final Failure? failure;
  @override
  List<Object?> get props => [contacts, loading, saving, failure];
}

@injectable
class TrustedContactsCubit extends Cubit<TrustedContactsState> {
  TrustedContactsCubit(
    this._watch,
    this._save,
    this._delete,
  ) : super(const TrustedContactsState());
  final WatchTrustedContacts _watch;
  final SaveTrustedContact _save;
  final DeleteTrustedContact _delete;
  StreamSubscription<Either<Failure, List<TrustedContact>>>? _subscription;
  String? _uid;
  int _generation = 0;
  Future<void> start(String uid) async {
    final generation = ++_generation;
    _uid = uid;
    await _subscription?.cancel();
    if (isClosed || generation != _generation) return;
    emit(const TrustedContactsState());
    _subscription = _watch(uid).listen((result) {
      if (isClosed || generation != _generation) return;
      result.fold(
        (failure) => emit(
          TrustedContactsState(
            contacts: state.contacts,
            loading: false,
            saving: state.saving,
            failure: failure,
          ),
        ),
        (contacts) => emit(
          TrustedContactsState(
            contacts: contacts,
            loading: false,
            saving: state.saving,
          ),
        ),
      );
    });
  }

  Future<bool> save(TrustedContact contact) => _mutate(() {
    if (contact.id.isEmpty && state.contacts.length >= 5) {
      return Future.value(
        const Left(ValidationFailure('trusted-contacts-limit')),
      );
    }
    return _save(_uid!, contact);
  });
  Future<bool> delete(String id) => _mutate(() => _delete(_uid!, id));
  Future<bool> _mutate(Future<Either<Failure, Unit>> Function() action) async {
    if (_uid == null || state.loading || state.saving || isClosed) return false;
    final generation = _generation;
    emit(
      TrustedContactsState(
        contacts: state.contacts,
        loading: false,
        saving: true,
      ),
    );
    final result = await action();
    if (isClosed || generation != _generation) return false;
    final failure = result.getLeft().toNullable();
    emit(
      TrustedContactsState(
        contacts: state.contacts,
        loading: false,
        failure: failure,
      ),
    );
    return failure == null;
  }

  @override
  Future<void> close() async {
    ++_generation;
    await _subscription?.cancel();
    return super.close();
  }
}
