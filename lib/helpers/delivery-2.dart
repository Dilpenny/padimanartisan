class Delivery2 {
  String? date, booking_type, dispatch_mode, item_type, receiver_landmark, landmark;
  String? id, money, delivery_id, delivery_type, receiver_state, code, booking_date, statusx;
  String? status, amount, state, email, name, phone, address, slug, country, receiver_country;
  // my_organization_id
  Delivery2({this.status, this.amount, this.delivery_id, this.money, this.state, this.date,
    this.id, this.email, this.name, this.phone, this.address, this.slug, this.country, this.receiver_country,
    this.delivery_type, this.receiver_state, this.booking_type, this.item_type, this.dispatch_mode,
    this.receiver_landmark, this.landmark, this.code, this.booking_date, this.statusx});

  factory Delivery2.fromJson(Map<String, dynamic> parsedJson) {
    return Delivery2(
      code: parsedJson['deliveries']['code'].toString(),
      statusx: parsedJson['deliveries']['statusx'].toString(),
      booking_date: parsedJson['deliveries']['booking_date'].toString(),
      receiver_landmark: parsedJson['deliveries']['receiver_landmark'].toString(),
      landmark: parsedJson['deliveries']['landmark'].toString(),
      dispatch_mode: parsedJson['deliveries']['dispatch_mode'].toString(),
      item_type: parsedJson['deliveries']['item_type'].toString(),
      booking_type: parsedJson['deliveries']['booking_type'].toString(),
      delivery_type: parsedJson['deliveries']['delivery_type'].toString(),
      receiver_state: parsedJson['deliveries']['receiver_state'].toString(),
      address: parsedJson['deliveries']['address'].toString(),
      country: parsedJson['deliveries']['country'].toString(),
      receiver_country: parsedJson['deliveries']['receiver_country'].toString(),
      slug: parsedJson['deliveries']['slug'].toString(),
      name: parsedJson['deliveries']['name'].toString(),
      phone: parsedJson['deliveries']['phone'].toString(),
      email: parsedJson['deliveries']['email'].toString(),
      status: parsedJson['deliveries']['status'].toString(),
      money: parsedJson['deliveries']['money'].toString(),
      amount: parsedJson['deliveries']['amount'].toString(),
      delivery_id: parsedJson['deliveries']['delivery_id'].toString(),
      date: parsedJson['deliveries']['date'].toString(),
      state: parsedJson['deliveries']['state'].toString(),
      id: parsedJson['deliveries']['id'].toString(),
    );
  }
}