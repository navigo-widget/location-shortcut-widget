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

/// A search field that uses the Google Places API for autocomplete.
///
/// The API key should be passed via --dart-define=PLACES_API_KEY=xxx at build time.
class PlaceSearchField extends StatefulWidget {
  final void Function(PlaceResult result) onPlaceSelected;

  const PlaceSearchField({super.key, required this.onPlaceSelected});

  @override
  State<PlaceSearchField> createState() => _PlaceSearchFieldState();
}

class _PlaceSearchFieldState extends State<PlaceSearchField> {
  final _controller = TextEditingController();
  List<_Prediction> _predictions = [];
  bool _isLoading = false;

  static const _apiKey = String.fromEnvironment('PLACES_API_KEY');

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onSearchChanged(String query) async {
    if (query.length < 3) {
      setState(() => _predictions = []);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/autocomplete/json'
        '?input=${Uri.encodeComponent(query)}'
        '&key=$_apiKey',
      );
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final predictions = (data['predictions'] as List)
            .map((p) => _Prediction(
                  placeId: p['place_id'] as String,
                  description: p['description'] as String,
                ))
            .toList();
        setState(() => _predictions = predictions);
      }
    } catch (_) {
      // Silently handle network errors — the user can retry
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _onPredictionSelected(_Prediction prediction) async {
    _controller.text = prediction.description;
    setState(() => _predictions = []);

    // Fetch place details to get lat/lng
    try {
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/details/json'
        '?place_id=${prediction.placeId}'
        '&fields=geometry'
        '&key=$_apiKey',
      );
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final location = data['result']['geometry']['location'];
        widget.onPlaceSelected(PlaceResult(
          placeId: prediction.placeId,
          description: prediction.description,
          latitude: (location['lat'] as num).toDouble(),
          longitude: (location['lng'] as num).toDouble(),
        ));
      }
    } catch (_) {
      // Handle error — user can retry
    }
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
                          setState(() => _predictions = []);
                        },
                      )
                    : null,
          ),
        ),
        if (_predictions.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(25),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            constraints: const BoxConstraints(maxHeight: 300),
            child: ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: _predictions.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final prediction = _predictions[index];
                return ListTile(
                  leading: const Icon(Icons.place, size: 28),
                  title: Text(
                    prediction.description,
                    style: const TextStyle(fontSize: 16),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  onTap: () => _onPredictionSelected(prediction),
                );
              },
            ),
          ),
      ],
    );
  }
}

class _Prediction {
  final String placeId;
  final String description;

  const _Prediction({required this.placeId, required this.description});
}
