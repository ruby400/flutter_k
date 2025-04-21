class Place {
  final String name;
  final String address;
  final String? link;
  final double? x; // 경도
  final double? y; // 위도

  Place({required this.name, required this.address, this.link, this.x, this.y});
}
