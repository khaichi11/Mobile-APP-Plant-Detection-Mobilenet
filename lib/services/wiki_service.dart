import 'dart:convert';

import 'package:http/http.dart' as http;

class WikiSummary {
  const WikiSummary({required this.title, required this.extract, this.url});
  final String title;
  final String extract;
  final String? url;
}

/// Fetches a short Wikipedia summary for plants that have no hand-written
/// content. It is public and needs no API key. Returns null when offline.
class WikiService {
  WikiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  final _cache = <String, WikiSummary?>{};

  Future<WikiSummary?> summary(String scientificName) async {
    if (_cache.containsKey(scientificName)) return _cache[scientificName];
    final title = Uri.encodeComponent(scientificName.replaceAll(' ', '_'));
    final uri = Uri.parse(
      'https://en.wikipedia.org/api/rest_v1/page/summary/$title',
    );
    try {
      final response = await _client
          .get(uri, headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) return _cache[scientificName] = null;
      final json = jsonDecode(utf8.decode(response.bodyBytes));
      if (json is! Map<String, dynamic>) return null;
      final extract = (json['extract'] as String? ?? '').trim();
      if (extract.isEmpty || json['type'] == 'disambiguation') {
        return _cache[scientificName] = null;
      }
      final urls = json['content_urls'] as Map<String, dynamic>?;
      final mobile = urls?['mobile'] as Map<String, dynamic>?;
      return _cache[scientificName] = WikiSummary(
        title: json['title'] as String? ?? scientificName,
        extract: extract,
        url: mobile?['page'] as String?,
      );
    } catch (_) {
      // Offline, slow network or an unexpected response: the app works
      // without the summary.
      return null;
    }
  }
}
