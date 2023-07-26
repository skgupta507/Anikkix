import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:mocktail/mocktail.dart';

import 'package:anikki/app/anilist_watch_list/bloc/watch_list_bloc.dart';
import 'package:anikki/core/core.dart';
import 'package:anikki/data/data.dart';
import 'package:anikki/domain/domain.dart';

import '../fixtures/anilist.dart';

void main() {
  /// Shuts off logging except for errors
  Logger.level = Level.error;

  group('unit test: UserListRepository', () {
    late MockAnilist anilist;
    late UserListRepository repository;

    final watchList = WatchListComplete(
      username: username,
      watchList: watchListMapMock,
    );

    group('watchedEntry method', () {
      group('when API succeeds', () {
        setUp(() {
          anilist = MockAnilist();
          when(
            () => anilist.updateEntry(
              episode: 1,
              mediaId: shortMediaMock.id,
              status: Enum$MediaListStatus.CURRENT,
            ),
          ).thenAnswer((_) async {});

          when(
            () => anilist.updateEntry(
              episode: 2,
              mediaId: shortMediaMock.id,
              status: null,
            ),
          ).thenAnswer((_) async {});

          repository = UserListRepository(anilist);
        });

        test('succeeds when episode is 1', () async {
          await repository.watchedEntry(episode: 1, media: anilistMediaMock);
        });

        test('succeeds when episode is not 1', () async {
          await repository.watchedEntry(episode: 2, media: anilistMediaMock);
        });
      });

      group('when API fails', () {
        final exception = Exception('error');

        setUp(() {
          anilist = MockAnilist();
          when(
            () => anilist.updateEntry(
              episode: 1,
              mediaId: shortMediaMock.id,
              status: Enum$MediaListStatus.CURRENT,
            ),
          ).thenThrow(exception);

          repository = UserListRepository(anilist);
        });

        test('fails with the same exception', () async {
          try {
            await repository.watchedEntry(episode: 1, media: anilistMediaMock);
            fail('Expected exception');
          } on Exception catch (e) {
            expect(e, exception);
          }
        });
      });
    });

    group('getList method', () {
      group('when API succeeds', () {
        setUp(() {
          anilist = MockAnilist();
          when(
            () => anilist.getWatchLists(username, useCache: false),
          ).thenAnswer((_) async => watchListMapMock);

          repository = UserListRepository(anilist);
        });

        test('succeeds', () async {
          final result = await repository.getList(username);

          expect(result, watchListMapMock);
        });
      });

      group('when API fails', () {
        final exception = Exception('error');

        setUp(() {
          anilist = MockAnilist();
          when(
            () => anilist.getWatchLists(username, useCache: false),
          ).thenThrow(exception);

          repository = UserListRepository(anilist);
        });

        test('fails with the same exception', () async {
          try {
            await repository.getList(username);
            fail('Expected exception');
          } on Exception catch (e) {
            expect(e, exception);
          }
        });
      });
    });

    group('isFollowed method', () {
      test('returns true only for planned entry', () {
        expect(
          UserListRepository.isFollowed(
            watchList,
            NewsEntry(
              media: Media(anilistInfo: plannedEntriesMock.first.media),
              airingAt: DateTime.now(),
            ),
          ),
          true,
        );
      });

      test('returns true only for current entry', () {
        expect(
          UserListRepository.isFollowed(
            watchList,
            NewsEntry(
              media: Media(anilistInfo: currentEntriesMock.first.media),
              airingAt: DateTime.now(),
            ),
          ),
          true,
        );
      });

      test('returns false only for dropped entry', () {
        expect(
          UserListRepository.isFollowed(
            watchList,
            NewsEntry(
              media: Media(anilistInfo: droppedEntriesMock.first.media),
              airingAt: DateTime.now(),
            ),
          ),
          false,
        );
      });
      test('returns false only for completed entry', () {
        expect(
          UserListRepository.isFollowed(
            watchList,
            NewsEntry(
              media: Media(anilistInfo: completedEntriesMock.first.media),
              airingAt: DateTime.now(),
            ),
          ),
          false,
        );
      });

      test('returns false only for paused entry', () {
        expect(
          UserListRepository.isFollowed(
            watchList,
            NewsEntry(
              media: Media(anilistInfo: pausedEntriesMock.first.media),
              airingAt: DateTime.now(),
            ),
          ),
          false,
        );
      });
    });

    group('isSeen method', () {
      test('returns true for watched entries', () {
        expect(
          UserListRepository.isSeen(
            watchList,
            NewsEntry(
              media: Media(anilistInfo: currentEntriesMock.first.media),
              airingAt: DateTime.now(),
              episode: currentEntriesMock.first.progress,
            ),
          ),
          true,
        );
      });

      test('returns false for unwatched entries', () {
        expect(
          UserListRepository.isSeen(
            watchList,
            NewsEntry(
              media: Media(anilistInfo: currentEntriesMock.first.media),
              airingAt: DateTime.now(),
              episode: currentEntriesMock.first.progress! + 1,
            ),
          ),
          false,
        );
      });

      test('returns true for completed entries', () {
        expect(
          UserListRepository.isSeen(
            watchList,
            NewsEntry(
              media: Media(anilistInfo: completedEntriesMock.first.media),
              airingAt: DateTime.now(),
              episode: 1,
            ),
          ),
          true,
        );
      });
    });
  });
}
