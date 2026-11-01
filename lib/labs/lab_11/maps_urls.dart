/// Универсальные URL Google Maps (открываются в приложении Google Maps,
/// если оно установлено, иначе — в браузере).
class MapsUrls {
  MapsUrls._();

  static const _base = 'https://www.google.com/maps';

  /// Поиск места по адресу.
  static String searchByAddress(String address) =>
      '$_base/search/?api=1&query=${Uri.encodeComponent(address)}';

  /// Поиск места по координатам.
  static String searchByCoordinates(double latitude, double longitude) =>
      '$_base/search/?api=1&query=$latitude,$longitude';

  /// Google Street View по координатам.
  static String streetView(double latitude, double longitude) =>
      '$_base/@?api=1&map_action=pano&viewpoint=$latitude,$longitude';
}
