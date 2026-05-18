// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 Alain Benard

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'config_service.dart';

class LocaleNotifier extends Notifier<Locale?> {
  @override
  Locale? build() {
    Future(() => _load());
    return null;
  }

  Future<void> _load() async {
    final code = await configService.getLocalePreference();
    if (code != null) state = Locale(code);
  }

  Future<void> setLocale(String? code) async {
    await configService.saveLocalePreference(code);
    state = code != null ? Locale(code) : null;
  }
}

final localeProvider = NotifierProvider<LocaleNotifier, Locale?>(
  LocaleNotifier.new,
);
