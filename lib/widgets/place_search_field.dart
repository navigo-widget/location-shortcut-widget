import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/// Data returned when a place is selected from autocomplete.
class PlaceResult {
  final String placeId;
  final String description;
  final double latitude;
  final double longitude;

  const PlaceResult({
    required this.placeId,
    required this.description,
    required this.latitude,
    required this.longitude,
  });
}

/// A search field that uses the OpenStreetMap Nominatim API for autocomplete.
///
/// Nominatim is completely free — no API key required.
/// Usage policy: max 1 request/second; must show OSM attribution in the app.
/// See: https://nominatim.org/release-docs/latest/api/Search/
class PlaceSearchField extends StatefulWidget {
  final void Function(PlaceResult result) onPlaceSelected;

  const PlaceSearchField({super.key, required this.onPlaceSelected});

  @override
  State<PlaceSearchField> createState() => _PlaceSearchFieldState();
}

class _PlaceSearchFieldState extends State<PlaceSearchField> {
  final _controller = TextEditingController();
  List<_NominatimResult> _results = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Debounce: only fire a request after the user pauses typing
  DateTime _lastQuery = DateTime.fromMillisecondsSinceEpoch(0);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onSearchChanged(String query) async {
    if (query.length < 3) {
      setState(() {
        _results = [];
        _errorMessage = null;
      });
      return;
    }

    // Debounce to ~400 ms so we don't exceed the 1 req/sec Nominatim limit
    final queryTime = DateTime.now();
    _lastQuery = queryTime;
    await Future.delayed(const Duration(milliseconds: 400));
    if (_lastQuery != queryTime) return; // a newer query superseded this one

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search'
        '?q=${Uri.encodeComponent(query)}'
        '&format=json'
        '&limit=5'
        '&addressdetails=0',
      );
      final response = await http.get(url, headers: {
        // Nominatim requires a descriptive User-Agent
        'User-Agent': 'NaviGo/1.0 (flutter; contact@navigo.app)',
      });
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final results = data
            .map((item) => _NominatimResult(
                  osmId: item['osm_id']?.toString() ?? item['place_id']?.toString() ?? '',
                  displayName: item['display_name'] as String,
                  latitude: double.parse(item['lat'] as String),
                  longitude: double.parse(item['lon'] as String),
                ))
            .toList();
        if (mounted) setState(() => _results = results);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _errorMessage =
            'Could not search. Check your internet connection and try again.');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onResultSelected(_NominatimResult result) {
    // Guard against bad Nominatim results with no real coordinates
    if (result.latitude == 0 && result.longitude == 0) {
      setState(() {
        _results = [];
        _errorMessage =
            'Could not get coordinates for this place. Try a different result.';
      });
      return;
    }

    _controller.text = result.displayName;
    setState(() {
      _results = [];
      _errorMessage = null;
    });

    widget.onPlaceSelected(PlaceResult(
      placeId: result.osmId,
      description: result.displayName,
      latitude: result.latitude,
      longitude: result.longitude,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _controller,
          onChanged: _onSearchChanged,
          style: const TextStyle(fontSize: 18),
          decoration: InputDecoration(
            hintText: 'Search for a place...',
            prefixIcon: const Icon(Icons.search, size: 28),
            suffixIcon: _isLoading
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : _controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 24),
                        onPressed: () {
                          _controller.clear();
                          setState(() {
                            _results = [];
                            _errorMessage = null;
                          });
                        },
                      )
                    : null,
          ),
        ),
        // Offline / bad-coordinate error message
        if (_errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                const Icon(Icons.wifi_off_rounded, size: 18, color: Colors.red),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(fontSize: 14, color: Colors.red),
                  ),
                ),
              ],
            ),
          ),

        if (_results.isNotEmpty)
          Builder(builder: (context) {
            final scheme = Theme.of(context).colorScheme;
            return Container(
              margin: const EdgeInsets.only(top: 4),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(40),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              constraints: const BoxConstraints(maxHeight: 300),
              child: ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: _results.length,
                separatorBuilder: (_, __) =>
                    Divider(height: 1, color: scheme.outlineVariant),
                itemBuilder: (context, index) {
                  final result = _results[index];
                  return ListTile(
                    leading: Icon(Icons.place,
                        size: 28, color: scheme.primary),
                    title: Text(
                      result.displayName,
                      style: TextStyle(
                          fontSize: 16, color: scheme.onSurface),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    onTap: () => _onResultSelected(result),
                  );
                },
              ),
            );
          }),
        // OSM attribution — required by Nominatim usage policy.
        // Only shown while the dropdown is open (results visible).
        if (_results.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 2, right: 4),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                '© OpenStreetMap contributors',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
              ),
            ),
          ),
      ],
    );
  }
}

class _NominatimResult {
  final String osmId;
  final String displayName;
  final double latitude;
  final double longitude;

  const _NominatimResult({
    required this.osmId,
    required this.displayName,
    required this.latitude,
    required this.longitude,
  });
}
