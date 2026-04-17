// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 Alain Benard
// Stub — sera étoffé à l'étape 2 (vue stock)

import 'package:flutter/material.dart';

// Seuil de bascule desktop/mobile (convention Flutter Material)
const kDesktopBreakpoint = 600.0;

bool isDesktop(BuildContext context) =>
    MediaQuery.of(context).size.width >= kDesktopBreakpoint;
