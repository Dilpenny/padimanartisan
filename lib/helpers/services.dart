class PadimanServices {
  String? name, total, slug, avatar;
  PadimanServices({this.name, this.total, this.slug, this.avatar});

  factory PadimanServices.fromJson(Map<String, dynamic> parsedJson) {
    return PadimanServices(
      name: parsedJson['name'].toString(),
      total: parsedJson['total'].toString(),
      slug: parsedJson['slug'].toString(),
      avatar: parsedJson['avatar'].toString(),
    );
  }
}