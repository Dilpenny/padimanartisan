class Banners {
  String? file_url, description;
  // my_organization_id
  Banners({this.description, this.file_url});

  factory Banners.fromJson(Map<String, dynamic> parsedJson) {
    return Banners(
      description: parsedJson['description'].toString(),
      file_url: parsedJson['file_url'].toString(),
    );
  }
}