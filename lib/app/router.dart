// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 Alain Benard

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/config_service.dart';
import '../features/bottle_detail/bottle_detail_screen.dart';
import '../features/bottle_edit/bottle_edit_screen.dart';
import '../features/bulk_add/bulk_add_screen.dart';
import '../features/import_csv/import_csv_screen.dart';
import '../features/settings/settings_screen.dart';
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
      GoRoute(
        path: '/bottle/:id',
        builder: (context, state) =>
            BottleDetailScreen(id: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/bottle-edit/:id',
        builder: (context, state) =>
            BottleEditScreen(id: state.pathParameters['id']!),
      ),
      ShellRoute(
        builder: (context, state, child) {
          final location = state.matchedLocation;
          final index = location == '/bulk-add'
              ? 1
              : location == '/import-csv'
                  ? 2
                  : location == '/settings'
                      ? 3
                      : 0;
          return AppShell(selectedIndex: index, child: child);
        },
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const StockScreen(),
          ),
          GoRoute(
            path: '/bulk-add',
            builder: (context, state) => const BulkAddScreen(),
          ),
          GoRoute(
            path: '/import-csv',
            builder: (context, state) => const ImportCsvScreen(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
    ],
  );
}
