import 'package:equatable/equatable.dart';
import 'package:mishwar/core/error/failures.dart';
import 'package:mishwar/features/common/places/domain/entities/place_details.dart';
import 'package:mishwar/features/common/places/domain/entities/place_suggestion.dart';

sealed class DestinationSearchState extends Equatable {
  const DestinationSearchState();
  List<PlaceSuggestion> get suggestions => const [];
  @override
  List<Object> get props => [];
}

final class DestinationIdle extends DestinationSearchState {
  const DestinationIdle();
}

final class DestinationLoading extends DestinationSearchState {
  DestinationLoading(List<PlaceSuggestion> previous)
    : suggestions = List.unmodifiable(previous);
  @override
  final List<PlaceSuggestion> suggestions;
  @override
  List<Object> get props => [suggestions];
}

final class DestinationResults extends DestinationSearchState {
  DestinationResults(List<PlaceSuggestion> results)
    : suggestions = List.unmodifiable(results);
  @override
  final List<PlaceSuggestion> suggestions;
  @override
  List<Object> get props => [suggestions];
}

final class DestinationEmpty extends DestinationSearchState {
  const DestinationEmpty(this.query);
  final String query;
  @override
  List<Object> get props => [query];
}

final class DestinationFailure extends DestinationSearchState {
  const DestinationFailure(this.failure, this.query);
  final Failure failure;
  final String query;
  @override
  List<Object> get props => [failure, query];
}

final class DestinationResolving extends DestinationSearchState {
  DestinationResolving(this.selected, List<PlaceSuggestion> previous)
    : suggestions = List.unmodifiable(previous);
  final PlaceSuggestion selected;
  @override
  final List<PlaceSuggestion> suggestions;
  @override
  List<Object> get props => [selected, suggestions];
}

final class DestinationChosen extends DestinationSearchState {
  const DestinationChosen(this.details);
  final PlaceDetails details;
  @override
  List<Object> get props => [details];
}
