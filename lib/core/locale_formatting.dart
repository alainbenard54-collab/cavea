// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 Alain Benard

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

String formatDate(DateTime d, BuildContext context) {
  final locale = Localizations.localeOf(context).toString();
  return DateFormat.yMd(locale).format(d);
}

String formatDateFromString(String? iso, BuildContext context) {
  if (iso == null || iso.isEmpty) return '';
  final d = DateTime.tryParse(iso);
  if (d == null) return iso;
  return formatDate(d, context);
}

String formatNumber(double n, BuildContext context, {int decimals = 1}) {
  final locale = Localizations.localeOf(context).toString();
  return NumberFormat.decimalPatternDigits(
    locale: locale,
    decimalDigits: decimals,
  ).format(n);
}

String formatCurrency(double? n, BuildContext context) {
  if (n == null) return '—';
  final locale = Localizations.localeOf(context).toString();
  final formatted = NumberFormat.decimalPatternDigits(
    locale: locale,
    decimalDigits: 0,
  ).format(n);
  return '$formatted €';
}

/// Formatage d'un nombre pour un champ éditable : séparateur décimal localisé,
/// pas de séparateur de milliers (évite les problèmes de parsing à la sauvegarde).
String formatNumberForEdit(double n, BuildContext context, {int decimals = 2}) {
  final locale = Localizations.localeOf(context).toString();
  return NumberFormat('0.${'0' * decimals}', locale).format(n);
}
