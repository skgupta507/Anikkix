import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:anikki/features/settings/domain/models/models.dart';
import 'package:anikki/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:anikki/core/widgets/anikki_icon.dart';

class NewsLayoutToggle extends StatelessWidget {
  const NewsLayoutToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsBloc = BlocProvider.of<SettingsBloc>(context, listen: true);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ToggleButtons(
        borderRadius: const BorderRadius.all(Radius.circular(50)),
        isSelected: settingsBloc.state.settings.newsLayout == NewsLayouts.grid
            ? [false, true]
            : [true, false],
        onPressed: (int index) {
          settingsBloc.add(
            SettingsUpdated(
              settingsBloc.state.settings.copyWith(
                newsLayout: index == 0 ? NewsLayouts.list : NewsLayouts.grid,
              ),
            ),
          );
        },
        children: const [
          AnikkiIcon(icon: Icons.list),
          AnikkiIcon(icon: Icons.grid_view),
        ],
      ),
    );
  }
}
