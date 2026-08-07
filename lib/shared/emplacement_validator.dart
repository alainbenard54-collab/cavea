// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 Alain Benard

class EmplacementValidator {
  static const String separator = ' > ';

  static final RegExp _levelPattern =
      RegExp(r'^[a-zA-ZÀ-ÖØ-öø-ÿ0-9][a-zA-ZÀ-ÖØ-öø-ÿ0-9 _-]*$');

  static bool isValid(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return false;
    final levels = trimmed.split(separator);
    return levels.every((level) => _levelPattern.hasMatch(level));
  }
}
