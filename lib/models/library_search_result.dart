class LibrarySearchResult {
  final String libCode;
  final String libName;
  final String address;
  final String tel;
  final double? lat;
  final double? lng;
  final String homepage;
  double? distanceKm;

  LibrarySearchResult({
    required this.libCode,
    required this.libName,
    required this.address,
    required this.tel,
    this.lat,
    this.lng,
    required this.homepage,
    this.distanceKm,
  });

  factory LibrarySearchResult.fromJson(Map<String, dynamic> json) {
    return LibrarySearchResult(
      libCode:  json['libCode']  as String? ?? '',
      libName:  json['libName']  as String? ?? '',
      address:  json['address']  as String? ?? '',
      tel:      json['tel']      as String? ?? '',
      lat:      double.tryParse((json['latitude']  ?? '').toString()),
      lng:      double.tryParse((json['longitude'] ?? '').toString()),
      homepage: json['homepage'] as String? ?? '',
    );
  }
}
