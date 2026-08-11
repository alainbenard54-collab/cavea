// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 Alain Benard

import 'dart:async';

import 'package:alchemist/alchemist.dart';

/// Configuration Alchemist pour ce projet : une seule référence par golden,
/// générée et comparée sous Windows uniquement (voir design.md du change
/// `golden-tests-alchemist`) — pas de goldens CI (police Ahem), le câblage
/// dans ci.yml est un change séparé. Tolérance de diff : 0% (exact).
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  return AlchemistConfig.runWithConfig(
    config: AlchemistConfig(
      platformGoldensConfig: PlatformGoldensConfig(
        enabled: true,
        platforms: {HostPlatform.windows},
        diffThreshold: 0.0,
        filePathResolver: (fileName, environmentName) => '$fileName.png',
      ),
      ciGoldensConfig: const CiGoldensConfig(enabled: false),
    ),
    run: testMain,
  );
}
