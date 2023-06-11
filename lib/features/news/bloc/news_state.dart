part of 'news_bloc.dart';

@immutable
abstract class NewsState extends Equatable {
  const NewsState({
    required this.range,
    this.options = const NewsOptions(),
  });

  final DateTimeRange range;
  final NewsOptions options;

  @override
  List<Object> get props => [range, options];
}

class NewsEmpty extends NewsState {
  const NewsEmpty({required super.range});
}

class NewsLoading extends NewsState {
  const NewsLoading({required super.range});
}

class NewsComplete extends NewsState {
  const NewsComplete({
    super.options,
    required super.range,
    required this.entries,
    this.filteredEntries,
  });

  final List<Query$AiringSchedule$Page$airingSchedules> entries;
  final List<Query$AiringSchedule$Page$airingSchedules>? filteredEntries;

  @override
  List<Object> get props => [range, entries, options];

  @override
  String toString() {
    return [range, '${entries.length} entries', options].join(', ');
  }
}

class NewsError extends NewsState {
  const NewsError({required super.range, required this.message});

  final String message;

  @override
  List<Object> get props => [range, message, options];
}
