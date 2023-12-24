import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

import 'package:anikki/core/core.dart';
import 'package:anikki/core/widgets/layout_card.dart';
import 'package:anikki/app/media_dialog/widgets/media_dialog_video_player.dart';

class MediaDialogTrailer extends StatefulWidget {
  const MediaDialogTrailer({
    super.key,
    required this.media,
  });

  final Media media;

  @override
  State<MediaDialogTrailer> createState() => _MediaDialogTrailerState();
}

class _MediaDialogTrailerState extends State<MediaDialogTrailer> {
  String? get thumbnail => widget.media.anilistInfo.trailer?.thumbnail;
  String? get site => widget.media.anilistInfo.trailer?.site;
  String? get id => widget.media.anilistInfo.trailer?.id;

  bool showThumbnail = true;

  Widget get videoThumbnail => Stack(
        children: [
          Positioned.fill(
            child: LayoutCard(
              child: Image.network(
                thumbnail!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 80.0),
                      child: Text('Could not load thumbnail'),
                    ),
                  );
                },
              ),
            ),
          ),
          Positioned.fill(
            child: Center(
              child: IconButton.filledTonal(
                padding: const EdgeInsets.all(12.0),
                onPressed: () => setState(() {
                  showThumbnail = false;
                }),
                icon: const Icon(Ionicons.play),
              ),
            ),
          )
        ],
      );

  @override
  Widget build(BuildContext context) {
    if (thumbnail == null || id == null || site != 'youtube') {
      return const SizedBox();
    }

    return Container(
      constraints: const BoxConstraints(
        maxHeight: 600,
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: showThumbnail
              ? videoThumbnail
              : MediaDialogVideoPlayer(
                  url: 'https://www.${site!}.com/watch?v=${id!}',
                ),
        ),
      ),
    );
  }
}
