// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 Alain Benard

import 'package:flutter/material.dart';
import '../../../core/maturity/maturity_service.dart';

class MaturityBadge extends StatelessWidget {
  final MaturityLevel level;

  const MaturityBadge({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    final (label, color, textColor) = switch (level) {
      MaturityLevel.tropJeune => (
          'Trop jeune',
          Colors.blue.shade100,
          Colors.blue.shade800
        ),
      MaturityLevel.optimal => (
          'À boire',
          Colors.green.shade100,
          Colors.green.shade800
        ),
      MaturityLevel.aBoireUrgent => (
          'À boire !',
          Colors.red.shade100,
          Colors.red.shade800
        ),
      MaturityLevel.sansDonnee => ('?', Colors.grey.shade200, Colors.grey.shade600),
    };

    return Chip(
      label: Text(label, style: TextStyle(fontSize: 11, color: textColor)),
      backgroundColor: color,
      side: BorderSide.none,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }
}
