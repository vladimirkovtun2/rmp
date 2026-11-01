import 'package:flutter_test/flutter_test.dart';

import 'package:rmp_9plus/labs/lab_11/maps_urls.dart';

void main() {
  group('MapsUrls', () {
    test('поиск по адресу кодирует адрес', () {
      expect(
        MapsUrls.searchByAddress('Москва, Красная площадь'),
        'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent('Москва, Красная площадь')}',
      );
    });

    test('поиск по координатам подставляет lat,lng', () {
      expect(
        MapsUrls.searchByCoordinates(55.7558, 37.6173),
        'https://www.google.com/maps/search/?api=1&query=55.7558,37.6173',
      );
      expect(
        MapsUrls.searchByCoordinates(-33.8568, 151.2153),
        'https://www.google.com/maps/search/?api=1&query=-33.8568,151.2153',
      );
    });

    test('street view использует map_action=pano и viewpoint', () {
      expect(
        MapsUrls.streetView(55.7558, 37.6173),
        'https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=55.7558,37.6173',
      );
    });
  });
}
