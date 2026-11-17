import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/features/common/rating/domain/rate_ride.dart';
import 'package:mishwar/features/common/rating/domain/rating_tag.dart';
import 'package:mishwar/features/common/rating/domain/skip_rating.dart';

enum RatingStatus { editing, submitting, success, failure }

class RatingState extends Equatable {
  const RatingState({
    this.stars = 0,
    this.tags = const [],
    this.comment = '',
    this.status = RatingStatus.editing,
    this.failure,
  });
  final int stars;
  final List<RatingTag> tags;
  final String comment;
  final RatingStatus status;
  final Failure? failure;
  @override
  List<Object?> get props => [stars, tags, comment, status, failure];
}

@injectable
class RatingCubit extends Cubit<RatingState> {
  RatingCubit(
    this._rate,
    this._skip,
    @factoryParam this.rideId,
    @factoryParam this.side,
  ) : super(const RatingState());
  final RateRide _rate;
  final SkipRating _skip;
  final String rideId;
  final RatingSide side;
  List<RatingTag> get availableTags => side == RatingSide.driver
      ? const [
          RatingTag.friendly,
          RatingTag.onTime,
          RatingTag.respectful,
          RatingTag.late,
          RatingTag.rude,
        ]
      : state.stars >= 4
      ? const [
          RatingTag.safeDriving,
          RatingTag.cleanCar,
          RatingTag.friendly,
          RatingTag.knowsRoute,
        ]
      : const [
          RatingTag.late,
          RatingTag.fastDriving,
          RatingTag.dirtyCar,
          RatingTag.longerRoute,
        ];
  bool get _busy =>
      state.status == RatingStatus.submitting ||
      state.status == RatingStatus.success;
  void _edit({int? stars, List<RatingTag>? tags, String? comment}) => emit(
    RatingState(
      stars: stars ?? state.stars,
      tags: List.unmodifiable(tags ?? state.tags),
      comment: comment ?? state.comment,
    ),
  );
  void selectStars(int stars) {
    if (_busy || stars < 1 || stars > 5) return;
    final changedSet = (stars >= 4) != (state.stars >= 4);
    _edit(
      stars: stars,
      tags: side == RatingSide.rider && changedSet ? [] : null,
    );
  }

  void toggleTag(RatingTag tag) {
    if (_busy || state.stars == 0 || !availableTags.contains(tag)) return;
    final tags = [...state.tags];
    if (tags.contains(tag)) {
      tags.remove(tag);
    } else if (tags.length < 5) {
      tags.add(tag);
    }
    _edit(tags: tags);
  }

  void setComment(String comment) {
    if (!_busy && comment.length <= 300) _edit(comment: comment);
  }

  Future<void> submit() => _send(skip: false);
  Future<void> skip() => _send(skip: true);
  Future<void> _send({required bool skip}) async {
    if (_busy || (!skip && state.stars == 0)) return;
    emit(
      RatingState(
        stars: state.stars,
        tags: state.tags,
        comment: state.comment,
        status: RatingStatus.submitting,
      ),
    );
    var result = skip
        ? await _skip(rideId)
        : await _rate(rideId, state.stars, state.tags, state.comment);
    if (isClosed) return;
    // A previous device may have rated while this screen was open. Clear any
    // remaining pointer through the server before letting the router go home.
    if (result.getLeft().toNullable() is RatingFailure) {
      result = await _skip(rideId);
      if (isClosed) return;
    }
    result.fold(
      (failure) => emit(
        RatingState(
          stars: state.stars,
          tags: state.tags,
          comment: state.comment,
          status: RatingStatus.failure,
          failure: failure,
        ),
      ),
      (_) => emit(
        RatingState(
          stars: state.stars,
          tags: state.tags,
          comment: state.comment,
          status: RatingStatus.success,
        ),
      ),
    );
  }
}
