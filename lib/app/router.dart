// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 Alain Benard

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/config_service.dart';
import '../features/import_csv/import_csv_screen.dart';
import '../features/setup/setup_screen.dart';
import '../features/stock/stock_screen.dart';
import '../shared/adaptive_layout.dart';

GoRouter buildRouter(VoidCallback onSetupComplete) {
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final configured = configService.isConfigured;
      final onSetup = state.matchedLocation == '/setup';
      if (!configured && !onSetup) return '/setup';
      if (configured && onSetup) return '/';
      return null;
    },
    routes: [
      GoRoute(
        path: '/setup',
        builder: (context, state) => SetupScreen(
          onComplete: (_) => onSetupComplete(),
        ),
      ),
      ShellRoute(
        builder: (context, state, child) {
          final location = state.matchedLocation;
          final index = location == '/import-csv' ? 1 : 0;
          return AppShell(selectedIndex: index, child: child);
        },
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const StockScreen(),
          ),
          GoRoute(
            path: '/import-csv',
            builder: (context, state) => const ImportCsvScreen(),
          ),
        ],
      ),
    ],
  );
}
