// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 Alain Benard

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cavea'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'À propos',
            onPressed: () => showAboutDialog(
              context: context,
              applicationName: 'Cavea',
              applicationVersion: '1.0.0',
              applicationLegalese: '© 2026 Alain Benard\nLicence Apache 2.0',
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wine_bar, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Vue stock disponible prochainement',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              icon: const Icon(Icons.upload_file),
              label: const Text('Importer un CSV'),
              onPressed: () => context.push('/import-csv'),
            ),
          ],
        ),
      ),
    );
  }
}
