// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 Alain Benard

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

const kDesktopBreakpoint = 600.0;

bool isDesktop(BuildContext context) =>
    MediaQuery.of(context).size.width >= kDesktopBreakpoint;

class _AppDestination {
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final String route;

  const _AppDestination({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.route,
  });
}

const _destinations = [
  _AppDestination(
    label: 'Stock',
    icon: Icons.wine_bar_outlined,
    selectedIcon: Icons.wine_bar,
    route: '/',
  ),
  _AppDestination(
    label: 'Import CSV',
    icon: Icons.upload_file_outlined,
    selectedIcon: Icons.upload_file,
    route: '/import-csv',
  ),
];

class AppShell extends StatelessWidget {
  final int selectedIndex;
  final Widget child;

  const AppShell({super.key, required this.selectedIndex, required this.child});

  void _onDestinationSelected(BuildContext context, int index) {
    context.go(_destinations[index].route);
  }

  @override
  Widget build(BuildContext context) {
    final desktop = isDesktop(context);

    if (desktop) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: selectedIndex,
              labelType: NavigationRailLabelType.all,
              onDestinationSelected: (i) => _onDestinationSelected(context, i),
              destinations: _destinations
                  .map(
                    (d) => NavigationRailDestination(
                      icon: Icon(d.icon),
                      selectedIcon: Icon(d.selectedIcon),
                      label: Text(d.label),
                    ),
                  )
                  .toList(),
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(child: child),
          ],
        ),
      );
    }

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (i) => _onDestinationSelected(context, i),
        destinations: _destinations
            .map(
              (d) => NavigationDestination(
                icon: Icon(d.icon),
                selectedIcon: Icon(d.selectedIcon),
                label: d.label,
              ),
            )
            .toList(),
      ),
    );
  }
}
