import 'package:equatable/equatable.dart';
import 'package:mishwar/core/error/failures.dart';

class SubmissionState extends Equatable {
  const SubmissionState({
    this.isLoading = false,
    this.failure,
    this.succeeded = false,
  });
  final bool isLoading;
  final Failure? failure;
  final bool succeeded;
  @override
  List<Object?> get props => [isLoading, failure, succeeded];
}
