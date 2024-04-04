class CustomerAsset {
  String? id, chassis_number, plate_number, time, model, color, photo1, year, photo2, photo3, slug, requests;
  CustomerAsset({this.chassis_number, this.plate_number, this.time, this.color, this.photo1, this.model,
    this.year, this.id, this.photo2, this.photo3, this.slug, this.requests});

  factory CustomerAsset.fromJson(Map<String, dynamic> parsedJson) {
    return CustomerAsset(
      chassis_number: parsedJson['chassis_number'].toString(),
      plate_number: parsedJson['plate_number'].toString(),
      model: parsedJson['model'].toString(),
      year: parsedJson['year'].toString(),
      id: parsedJson['id'].toString(),
      requests: parsedJson['requests'].toString(),
      color: parsedJson['color'].toString(),
      photo1: parsedJson['img'].toString(),
      photo2: parsedJson['photo2'].toString(),
      photo3: parsedJson['photo3'].toString(),
      slug: parsedJson['slug'].toString(),
    );
  }
}