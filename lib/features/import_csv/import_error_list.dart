// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 Alain Benard

import 'package:flutter/material.dart';

/// Liste défilante des messages d'erreur d'un import CSV (format "Ligne N — raison : contenu").
/// Utilisé par l'écran d'import manuel (`_ResultCard`) et par le dialogue
/// d'erreurs de l'import des données exemple (`stock_screen.dart`).
class ImportErrorList extends StatelessWidget {
  final List<String> errorDetails;

  const ImportErrorList({super.key, required this.errorDetails});

  @override
  Widget build(BuildContext context) {
    return SelectionArea(
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: errorDetails.length,
        itemBuilder: (context, i) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Text(
            errorDetails[i],
            style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
          ),
        ),
      ),
    );
  }
}
