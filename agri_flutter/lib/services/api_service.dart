import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Simple API Service
class ApiService {
  // Optional override: flutter run --dart-define=AGRINOVA_API_BASE_URL=http://192.168.1.10:8000/api/
  static const String _baseUrlOverride = String.fromEnvironment(
    'AGRINOVA_API_BASE_URL',
    defaultValue: '',
  );
  static const String _cachedBaseUrlKey = 'api_base_url';

  static String? _resolvedBaseUrl;
  static Future<String>? _resolvingBaseUrl;

  static List<String> _candidateBaseUrls() {
    final candidates = <String>[];

    if (_baseUrlOverride.isNotEmpty) {
      candidates.add(_normalizeBaseUrl(_baseUrlOverride));
    }

    if (!kIsWeb) {
      // Android emulator host alias
      candidates.add('http://10.0.2.2:8000/api/');
      // Useful when using adb reverse: adb reverse tcp:8000 tcp:8000
      candidates.add('http://127.0.0.1:8000/api/');
      candidates.add('http://localhost:8000/api/');
    }

    // Web/dev fallback
    candidates.add('http://127.0.0.1:8000/api/');
    candidates.add('http://localhost:8000/api/');

    return candidates;
  }

  static String _normalizeBaseUrl(String value) {
    var base = value.trim();
    if (base.isEmpty) return base;
    if (!base.startsWith('http://') && !base.startsWith('https://')) {
      base = 'http://$base';
    }
    if (!base.endsWith('/')) base = '$base/';
    if (!base.endsWith('api/')) {
      base = '${base}api/';
    }
    return base;
  }

  static Future<String?> _getCachedBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(_cachedBaseUrlKey);
    if (cached == null || cached.trim().isEmpty) return null;
    return _normalizeBaseUrl(cached);
  }

  static Future<void> _cacheBaseUrl(String baseUrl) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cachedBaseUrlKey, baseUrl);
  }

  static Future<bool> _canReachBaseUrl(String baseUrl) async {
    final uri = Uri.parse('${baseUrl}auth/login/');
    final client = http.Client();
    try {
      // Validate this is the expected DRF login endpoint, not just any web server.
      final optionsRequest = http.Request('OPTIONS', uri);
      final optionsStream = await client
          .send(optionsRequest)
          .timeout(const Duration(milliseconds: 1800));
      final optionsResponse = await http.Response.fromStream(optionsStream);

      final allowHeader = (optionsResponse.headers['allow'] ?? '').toUpperCase();
      final contentType =
          (optionsResponse.headers['content-type'] ?? '').toLowerCase();

      if (optionsResponse.statusCode == 200 && allowHeader.contains('POST')) {
        return true;
      }

      if (contentType.contains('application/json')) {
        try {
          final decoded = jsonDecode(optionsResponse.body);
          if (decoded is Map<String, dynamic> && decoded.containsKey('actions')) {
            return true;
          }
        } catch (_) {
          // Continue to POST-based validation.
        }
      }

      // Fallback: invalid credentials against login should return JSON from DRF.
      final postResponse = await client
          .post(
            uri,
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode({'username': '', 'password': ''}),
          )
          .timeout(const Duration(milliseconds: 1800));

      final postContentType =
          (postResponse.headers['content-type'] ?? '').toLowerCase();
      if (!postContentType.contains('application/json')) {
        return false;
      }

      final decoded = jsonDecode(postResponse.body);
      if (decoded is! Map<String, dynamic>) {
        return false;
      }

      return decoded.containsKey('username') ||
          decoded.containsKey('password') ||
          decoded.containsKey('non_field_errors') ||
          decoded.containsKey('detail');
    } catch (_) {
      return false;
    } finally {
      client.close();
    }
  }

  static bool _isPrivateIpv4(String ip) {
    final parts = ip.split('.');
    if (parts.length != 4) return false;
    final a = int.tryParse(parts[0]);
    final b = int.tryParse(parts[1]);
    if (a == null || b == null) return false;
    if (a == 10) return true;
    if (a == 192 && b == 168) return true;
    if (a == 172 && b >= 16 && b <= 31) return true;
    return false;
  }

  static Future<String?> _discoverLanBaseUrl() async {
    if (kIsWeb) return null;

    try {
      final interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4,
        includeLinkLocal: false,
      );

      for (final iface in interfaces) {
        for (final addr in iface.addresses) {
          final ip = addr.address;
          if (!_isPrivateIpv4(ip)) continue;

          final parts = ip.split('.');
          final prefix = '${parts[0]}.${parts[1]}.${parts[2]}';

          // Fast first-pass guesses for common host/router IP patterns.
          final quickHosts = <int>[1, 2, 10, 20, 50, 100, 101, 110, 150, 200, 254];
          for (final host in quickHosts) {
            final candidate = 'http://$prefix.$host:8000/api/';
            if (await _canReachBaseUrl(candidate)) {
              return candidate;
            }
          }

          // Full /24 scan fallback in parallel batches.
          final allHosts = List<int>.generate(254, (i) => i + 1)
              .where((h) => !quickHosts.contains(h) && h != int.tryParse(parts[3]))
              .toList();

          const batchSize = 24;
          for (var i = 0; i < allHosts.length; i += batchSize) {
            final batch = allHosts.sublist(
              i,
              i + batchSize > allHosts.length ? allHosts.length : i + batchSize,
            );

            final checks = batch.map((host) async {
              final candidate = 'http://$prefix.$host:8000/api/';
              final ok = await _canReachBaseUrl(candidate);
              return ok ? candidate : null;
            }).toList();

            final results = await Future.wait(checks);
            final found = results.firstWhere(
              (v) => v != null,
              orElse: () => null,
            );
            if (found != null) {
              return found;
            }
          }
        }
      }
    } catch (_) {
      // Best-effort discovery; ignore and let caller throw user-facing error.
    }

    return null;
  }

  static Future<String> _resolveBaseUrl() async {
    if (_resolvedBaseUrl != null) return _resolvedBaseUrl!;
    if (_resolvingBaseUrl != null) return _resolvingBaseUrl!;

    _resolvingBaseUrl = () async {
      final checked = <String>{};

      Future<bool> check(String baseUrl) async {
        final normalized = _normalizeBaseUrl(baseUrl);
        if (!checked.add(normalized)) return false;
        return _canReachBaseUrl(normalized);
      }

      final cached = await _getCachedBaseUrl();
      if (cached != null && await check(cached)) {
        _resolvedBaseUrl = cached;
        return cached;
      }

      for (final candidate in _candidateBaseUrls()) {
        final normalized = _normalizeBaseUrl(candidate);
        if (await check(normalized)) {
          _resolvedBaseUrl = normalized;
          await _cacheBaseUrl(normalized);
          return normalized;
        }
      }

      final lan = await _discoverLanBaseUrl();
      if (lan != null && await check(lan)) {
        _resolvedBaseUrl = lan;
        await _cacheBaseUrl(lan);
        return lan;
      }

      throw Exception(
        'Cannot connect to backend automatically. Start Django with "python manage.py runserver 0.0.0.0:8000" and keep device/emulator on same network.',
      );
    }();

    try {
      return await _resolvingBaseUrl!;
    } finally {
      _resolvingBaseUrl = null;
    }
  }

  static void _logRequest(
    String method,
    Uri url,
    Map<String, String> headers,
    dynamic body,
  ) {
    if (!kDebugMode) return;
    debugPrint('[API] Request: $method $url');
    debugPrint('[API] Headers: $headers');
    if (body != null) {
      try {
        debugPrint('[API] Body: ${const JsonEncoder.withIndent('  ').convert(body)}');
      } catch (_) {
        debugPrint('[API] Body: $body');
      }
    }
  }

  static void _logResponse(
    String method,
    Uri url,
    http.Response response,
    int elapsedMs,
    bool isSuccess,
  ) {
    if (!kDebugMode) return;
    final statusLabel = isSuccess ? 'OK' : 'FAIL';
    debugPrint(
      '[API] Response[$statusLabel]: $method $url | Status: ${response.statusCode} | Time: ${elapsedMs}ms',
    );
    try {
      final decoded = jsonDecode(response.body);
      debugPrint(
        '[API] Response Body: ${const JsonEncoder.withIndent('  ').convert(decoded)}',
      );
    } catch (_) {
      debugPrint('[API] Response Body: ${response.body}');
    }
  }

  static void _logError(String method, Uri url, Object error, int elapsedMs) {
    if (!kDebugMode) return;
    debugPrint('[API] Error: $method $url | Time: ${elapsedMs}ms | $error');
  }

  // Get saved token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Save token
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  // Remove token
  static Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  // POST request
  static Future<dynamic> post(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    final stopwatch = Stopwatch()..start();
    Uri? url;
    try {
      final token = await getToken();
      final baseUrl = await _resolveBaseUrl();
      url = Uri.parse(baseUrl + endpoint);
      final headers = {
        "Content-Type": "application/json",
        if (token != null) "Authorization": "Token $token",
      };

      _logRequest('POST', url, headers, data);

      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(data),
      );
      stopwatch.stop();
      final isSuccess = response.statusCode == 200 || response.statusCode == 201;

      _logResponse(
        'POST',
        url,
        response,
        stopwatch.elapsedMilliseconds,
        isSuccess,
      );

      if (isSuccess) {
        return jsonDecode(response.body);
      } else {
        // Try to parse error response as JSON
        try {
          final errorData = jsonDecode(response.body);
          throw Exception(jsonEncode(errorData));
        } catch (_) {
          throw Exception(response.body);
        }
      }
    } catch (e) {
      if (stopwatch.isRunning) stopwatch.stop();
      _logError(
        'POST',
        url ?? Uri.parse(endpoint),
        e,
        stopwatch.elapsedMilliseconds,
      );
      throw Exception("Error: $e");
    }
  }

  // GET request
  static Future<dynamic> get(String endpoint) async {
    final stopwatch = Stopwatch()..start();
    Uri? url;
    try {
      final token = await getToken();
      final baseUrl = await _resolveBaseUrl();
      url = Uri.parse(baseUrl + endpoint);
      final headers = {
        "Content-Type": "application/json",
        if (token != null) "Authorization": "Token $token",
      };

      _logRequest('GET', url, headers, null);

      final response = await http
          .get(url, headers: headers)
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception(
                'Connection timeout. Please check if the backend server is running.',
              );
            },
          );
      stopwatch.stop();
      final isSuccess = response.statusCode == 200;

      _logResponse(
        'GET',
        url,
        response,
        stopwatch.elapsedMilliseconds,
        isSuccess,
      );

      if (isSuccess) {
        return jsonDecode(response.body);
      } else {
        throw Exception(response.body);
      }
    } catch (e) {
      if (stopwatch.isRunning) stopwatch.stop();
      _logError(
        'GET',
        url ?? Uri.parse(endpoint),
        e,
        stopwatch.elapsedMilliseconds,
      );
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Connection')) {
        throw Exception(
          "Cannot connect to server. Please ensure Django backend is running.",
        );
      }
      throw Exception("Error: $e");
    }
  } // PUT request

  static Future<dynamic> put(String endpoint, Map<String, dynamic> data) async {
    final stopwatch = Stopwatch()..start();
    Uri? url;
    try {
      final token = await getToken();
      final baseUrl = await _resolveBaseUrl();
      url = Uri.parse(baseUrl + endpoint);
      final headers = {
        "Content-Type": "application/json",
        if (token != null) "Authorization": "Token $token",
      };

      _logRequest('PUT', url, headers, data);

      final response = await http.put(
        url,
        headers: headers,
        body: jsonEncode(data),
      );
      stopwatch.stop();
      final isSuccess = response.statusCode == 200;

      _logResponse(
        'PUT',
        url,
        response,
        stopwatch.elapsedMilliseconds,
        isSuccess,
      );

      if (isSuccess) {
        return jsonDecode(response.body);
      } else {
        throw Exception(response.body);
      }
    } catch (e) {
      if (stopwatch.isRunning) stopwatch.stop();
      _logError(
        'PUT',
        url ?? Uri.parse(endpoint),
        e,
        stopwatch.elapsedMilliseconds,
      );
      throw Exception("Error: $e");
    }
  }

  // DELETE request
  static Future<dynamic> delete(String endpoint) async {
    final stopwatch = Stopwatch()..start();
    Uri? url;
    try {
      final token = await getToken();
      final baseUrl = await _resolveBaseUrl();
      url = Uri.parse(baseUrl + endpoint);
      final headers = {
        "Content-Type": "application/json",
        if (token != null) "Authorization": "Token $token",
      };

      _logRequest('DELETE', url, headers, null);

      final response = await http.delete(
        url,
        headers: headers,
      );
      stopwatch.stop();
      final isSuccess = response.statusCode == 200 || response.statusCode == 204;

      _logResponse(
        'DELETE',
        url,
        response,
        stopwatch.elapsedMilliseconds,
        isSuccess,
      );

      if (isSuccess) {
        return true;
      } else {
        throw Exception(response.body);
      }
    } catch (e) {
      if (stopwatch.isRunning) stopwatch.stop();
      _logError(
        'DELETE',
        url ?? Uri.parse(endpoint),
        e,
        stopwatch.elapsedMilliseconds,
      );
      throw Exception("Error: $e");
    }
  }
}
