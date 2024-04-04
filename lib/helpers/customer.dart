class Customer {
  String? id, name, img, phone, device_token, state, country, slug, email, area, latitude, longitude, img_sm, art_scope,
      rating;
  // my_organization_id
  Customer({this.name, this.img, this.phone, this.state, this.country, this.device_token, this.id,
    this.slug, this.email, this.area, this.latitude, this.longitude, this.img_sm, this.art_scope, this.rating});

  factory Customer.fromJson(Map<String, dynamic> parsedJson) {
    return Customer(
      img_sm: parsedJson['img_sm'].toString(),
      name: parsedJson['name'].toString(),
      rating: parsedJson['rating'].toString(),
      email: parsedJson['email'].toString(),
      img: parsedJson['img'].toString(),
      phone: parsedJson['phone'].toString(),
      device_token: parsedJson['device_token'].toString(),
      country: parsedJson['country'].toString(),
      state: parsedJson['state'].toString(),
      id: parsedJson['id'].toString(),
      area: parsedJson['area'].toString(),
      latitude: parsedJson['latitude'].toString(),
      longitude: parsedJson['longitude'].toString(),
      slug: parsedJson['slug'].toString(),
      art_scope: parsedJson['art_scope'].toString(),
    );
  }
}