import 'package:carecar_mobile/l10n/idiomas.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:carecar_mobile/tema/tema_carecar.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// Como `MaterialApp(home: ...)`, pero con el ancestro `ShadApp` que exigen los
/// botones, dialogos y avisos de shadcn_ui.
class MaterialAppConShad extends StatelessWidget {
  const MaterialAppConShad({required this.home, this.theme, super.key});

  final Widget home;
  final ThemeData? theme;

  @override
  Widget build(BuildContext context) => ProviderScope(
    child: ShadApp.custom(
      theme: TemaCareCar.shad,
      appBuilder: (context) => MaterialApp(
        theme: theme ?? TemaCareCar.claro,
        locale: idiomaBase,
        localizationsDelegates: delegadasDeIdioma,
        supportedLocales: idiomasSoportados,
        builder: (context, child) => ShadAppBuilder(child: child!),
        home: home,
      ),
    ),
  );
}
