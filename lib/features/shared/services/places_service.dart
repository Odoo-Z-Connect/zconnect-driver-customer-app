import 'package:dio/dio.dart';
import '../models/shipment.dart';

class PlacesService {
  static const _apiKey = 'AIzaSyCxVvPpOrhUw2O0-PwSfy6BaFIGfiFHBr8';
  final Dio _dio = Dio();

  Future<List<AppLocation>> searchPlaces(String query) async {
    if (query.isEmpty) return [];

    try {
      final res = await _dio.get(
        'https://maps.googleapis.com/maps/api/place/autocomplete/json',
        queryParameters: {
          'input': query,
          'key': _apiKey,
          'components': 'country:zw', // restrict to Zimbabwe or leave empty
        },
      );

      if (res.statusCode == 200 && res.data['status'] == 'OK') {
        final predictions = res.data['predictions'] as List;
        final List<AppLocation> locs = [];
        for (var p in predictions) {
          locs.add(AppLocation(
            id: p['place_id'],
            name: p['structured_formatting']['main_text'] ?? '',
            address: p['structured_formatting']['secondary_text'] ??
                p['description'],
            city: '', // Extract from details if needed
          ));
        }
        return locs;
      }
    } catch (e) {
      print('Places API error: $e');
    }
    return [];
  }

  Future<AppLocation?> getPlaceDetails(AppLocation place) async {
    try {
      final res = await _dio.get(
        'https://maps.googleapis.com/maps/api/place/details/json',
        queryParameters: {
          'place_id': place.id,
          'key': _apiKey,
          'fields': 'geometry,address_components',
        },
      );

      if (res.statusCode == 200 && res.data['status'] == 'OK') {
        final result = res.data['result'];

        String city = '';
        if (result['address_components'] != null) {
          for (var component in result['address_components']) {
            if (component['types'].contains('locality')) {
              city = component['long_name'];
              break;
            }
          }
        }

        return AppLocation(
          id: place.id,
          name: place.name,
          address: place.address,
          city: city,
        );
      }
    } catch (e) {
      print('Places API details error: $e');
    }
    return place;
  }
}
