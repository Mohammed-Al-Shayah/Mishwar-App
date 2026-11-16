import 'package:equatable/equatable.dart';
import 'package:mishwar/features/common/places/domain/entities/place_suggestion.dart';

sealed class DestinationSearchEvent extends Equatable {
  const DestinationSearchEvent();
  @override
  List<Object> get props => [];
}

final class QueryChanged extends DestinationSearchEvent {
  const QueryChanged(this.text);
  final String text;
  @override
  List<Object> get props => [text];
}

final class SuggestionSelected extends DestinationSearchEvent {
  const SuggestionSelected(this.suggestion);
  final PlaceSuggestion suggestion;
  @override
  List<Object> get props => [suggestion];
}

final class Cleared extends DestinationSearchEvent {
  const Cleared();
}

final class Retry extends DestinationSearchEvent {
  const Retry();
}
