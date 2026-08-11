// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 Alain Benard

import 'package:cavea/app/theme.dart';
import 'package:cavea/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';

/// Enveloppe un widget pour un golden test : thème Material 3 de l'app,
/// locale fixe `fr` (reproductibilité), délégués de localisation réels
/// (le texte affiché doit être le vrai texte de l'app, pas un stub vide).
/// [overrides] permet d'injecter des providers Riverpod avec des données
/// statiques déterministes, sans dépendre de la DB drift réelle.
///
/// Chaque `GoldenTestScenario` qui utilise ce wrapper doit fournir un
/// `constraints` explicite avec largeur ET hauteur bornées — Alchemist ne
/// contraint la hauteur par défaut (elle reste infinie), ce qui casse tout
/// widget contenant un `Scaffold`/`MaterialApp` (CustomMultiChildLayout,
/// RenderView) — voir _smoke_check_test.dart pour un exemple minimal.
Widget wrapForGolden(
  Widget child, {
  List<Override> overrides = const [],
}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      locale: const Locale('fr'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child),
    ),
  );
}
