// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 Alain Benard

import 'package:http/http.dart' as http;

import '../import_csv/csv_parser.dart';
import '../import_csv/import_service.dart';

class SampleDataService {
  static const String _urlFr = String.fromEnvironment(
    'SAMPLE_DATA_URL_FR',
    defaultValue: '',
  );
  static const String _urlEn = String.fromEnvironment(
    'SAMPLE_DATA_URL_EN',
    defaultValue: '',
  );

  final ImportService importService;

  SampleDataService(this.importService);

  static bool get isConfigured => _urlFr.isNotEmpty || _urlEn.isNotEmpty;

  Future<ImportResult> importSampleData(String languageCode) async {
    final url = languageCode == 'fr'
        ? (_urlFr.isNotEmpty ? _urlFr : _urlEn)
        : (_urlEn.isNotEmpty ? _urlEn : _urlFr);

    if (url.isEmpty) throw Exception('SAMPLE_DATA_URL not configured');

    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}');
    }

    final content = response.body;
    // Les CSV exemple utilisent les noms de champs internes comme en-têtes —
    // pas besoin de columnMap.
    final parseResult = parseCsv(content);
    return importService.run(parseResult.companions, overwrite: false);
  }
}
