class CarHire {
  String? id, chassis_number, plate_number, price_per_hour, model, price_per_day, photo, country, state,
      price_with_driver, slug, area, locality, price_per_month, price_per_week, name;
  CarHire({this.chassis_number, this.plate_number, this.price_per_hour, this.price_per_day, this.photo, this.model,
    this.country, this.id, this.area, this.price_with_driver, this.slug, this.name,
    this.locality, this.price_per_month, this.price_per_week});

  factory CarHire.fromJson(Map<String, dynamic> parsedJson) {
    return CarHire(
      chassis_number: parsedJson['chassis_number'].toString(),
      plate_number: parsedJson['plate_number'].toString(),
      name: parsedJson['car_name'].toString(),
      model: parsedJson['model'].toString(),
      country: parsedJson['country'].toString(),
      id: parsedJson['id'].toString(),
      locality: parsedJson['locality'].toString(),
      price_per_day: parsedJson['price_per_day'].toString(),
      price_per_month: parsedJson['price_per_month'].toString(),
      photo: parsedJson['photo'].toString(),
      price_per_hour: parsedJson['price_per_hour'].toString(),
      area: parsedJson['area'].toString(),
      price_per_week: parsedJson['price_per_week'].toString(),
      price_with_driver: parsedJson['price_with_driver'].toString(),
      slug: parsedJson['slug'].toString(),
    );
  }
}