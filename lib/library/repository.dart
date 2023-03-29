import 'dart:io';

import 'package:anilist/anilist.dart';
import 'package:anitomy/anitomy.dart';
import 'package:path/path.dart';

import 'package:anikki/helpers/errors/library_directory_does_not_exist_exception.dart';
import 'package:anikki/models/local_file.dart';

Future<List<LocalFile>> retrieveFilesFromPath({required String path}) async {
  List<LocalFile> results = [];

  final directory = Directory(path);
  final exists = await directory.exists();

  if (!exists) throw LibraryDoesNotExistException();

  final fileStream = directory.list(recursive: false, followLinks: false);
  final files = await fileStream.toList();

  for (final file in files) {
    final path = file.path;
    final isAllowed = ['.mkv', '.mp4'].contains(extension(path));

    if (!isAllowed) continue;

    final parser = Anitomy(inputString: basename(path));
    final entry = LocalFile(
      path: path,
      file: File(path),
      episode: parser.episode,
      releaseGroup: parser.releaseGroup,
      title: parser.title,
    );

    parser.dispose();

    results.add(entry);
  }

  final List<String> entryNames = [];

  try {
    final Anilist anilist = Anilist();

    for (final entry in results) {
      final title = entry.title;

      if (title != null && !entryNames.contains(title)) {
        entryNames.add(title);
      }
    }

    final info = await anilist.infoFromMultiple(entryNames);

    // Feeding medias to entries
    results = results
        .map(
          (e) => e.copyWith(
            media: anilist.getInfoFromInfo(e.title!, info) ?? noMedia,
          ),
        )
        .toList();
  } on AnilistGetInfoException {
    /// TODO: Handle if not information on not connected
  }

  // Ordering files using name and episode
  _sortEntries(results);
  return results;
}

void _sortEntries(List<LocalFile> files) {
  files.sort((a, b) {
    final aTitle = a.title ?? '';
    final bTitle = b.title ?? '';
    final aEp = int.tryParse(a.episode ?? '0') ?? 0;
    final bEp = int.tryParse(b.episode ?? '0') ?? 0;

    final comparisonResult = aTitle.compareTo(bTitle);

    if (comparisonResult != 0) {
      return comparisonResult;
    }

    return bEp.compareTo(aEp);
  });
}
