import 'package:nyaa/nyaa.dart';
import 'package:anilist/anilist.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:anikki/features/torrent/bloc/torrent_bloc.dart';
import 'package:anikki/features/downloader/bloc/downloader_bloc.dart';
import 'package:anikki/features/entry_card_overlay/bloc/entry_card_overlay_bloc.dart';
import 'package:anikki/helpers/anilist/anilist_client.dart';
import 'package:anikki/helpers/connectivity_bloc/connectivity_bloc.dart';
import 'package:anikki/features/news/bloc/news_bloc.dart';
import 'package:anikki/features/anilist_auth/bloc/anilist_auth_bloc.dart';
import 'package:anikki/features/library/bloc/library_bloc.dart';
import 'package:anikki/features/settings/bloc/settings_bloc.dart';
import 'package:anikki/features/watch_list/bloc/watch_list_bloc.dart';

class AnikkiBlocProvider extends StatelessWidget {
  const AnikkiBlocProvider({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final anilist = Anilist(client: getAnilistClient());
    final nyaa = Nyaa();

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              AnilistAuthBloc(anilist)..add(AnilistAuthLoginRequested()),
        ),
        BlocProvider(
          create: (context) => SettingsBloc(),
        ),
        BlocProvider(
          create: (context) => ConnectivityBloc(),
        ),
        BlocProvider(
          create: (context) => EntryCardOverlayBloc(),
        ),
        BlocProvider(
          create: (context) => DownloaderBloc(nyaa),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) {
              final authBloc = BlocProvider.of<AnilistAuthBloc>(context);
              return WatchListBloc(
                authBloc: authBloc,
                repository: anilist,
              );
            },
          ),
          BlocProvider(
            create: (context) {
              final settingsBloc = BlocProvider.of<SettingsBloc>(context);
              return LibraryBloc(settingsBloc: settingsBloc)
                ..add(
                  LibraryUpdateRequested(
                    path: settingsBloc.state.settings.localDirectory,
                  ),
                );
            },
          ),
          BlocProvider(
            create: (context) {
              final settingsBloc = BlocProvider.of<SettingsBloc>(context);
              return TorrentBloc(settingsBloc: settingsBloc)
                ..add(TorrentClientRequested(
                    settingsBloc.state.settings.torrentType));
            },
          ),
        ],
        child: MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) {
                final settingsBloc = BlocProvider.of<SettingsBloc>(context);
                final watchListBloc = BlocProvider.of<WatchListBloc>(context);

                return NewsBloc(
                  repository: anilist,
                  settingsBloc: settingsBloc,
                  watchListBloc: watchListBloc,
                )..add(
                    NewsRequested(range: NewsBloc.initalDateRange),
                  );
              },
            ),
          ],
          child: child,
        ),
      ),
    );
  }
}
