class Delivery {
  String? date, booking_type, dispatch_mode, item_type, receiver_landmark, landmark;
  String? id, money, delivery_id, delivery_type, receiver_state, code, booking_date, statusx;
  String? status, amount, state, email, name, phone, address, slug, country, receiver_country;
  // my_organization_id
  Delivery({this.status, this.amount, this.delivery_id, this.money, this.state, this.date,
    this.id, this.email, this.name, this.phone, this.address, this.slug, this.country, this.receiver_country,
    this.delivery_type, this.receiver_state, this.booking_type, this.item_type, this.dispatch_mode,
  this.receiver_landmark, this.landmark, this.code, this.booking_date, this.statusx});

  factory Delivery.fromJson(Map<String, dynamic> parsedJson) {
    return Delivery(
      code: parsedJson['code'].toString(),
      statusx: parsedJson['statusx'].toString(),
      booking_date: parsedJson['booking_date'].toString(),
      receiver_landmark: parsedJson['receiver_landmark'].toString(),
      landmark: parsedJson['landmark'].toString(),
      dispatch_mode: parsedJson['dispatch_mode'].toString(),
      item_type: parsedJson['item_type'].toString(),
      booking_type: parsedJson['booking_type'].toString(),
      delivery_type: parsedJson['delivery_type'].toString(),
      receiver_state: parsedJson['receiver_state'].toString(),
      address: parsedJson['address'].toString(),
      country: parsedJson['country'].toString(),
      receiver_country: parsedJson['receiver_country'].toString(),
      slug: parsedJson['slug'].toString(),
      name: parsedJson['name'].toString(),
      phone: parsedJson['phone'].toString(),
      email: parsedJson['email'].toString(),
      status: parsedJson['status'].toString(),
      money: parsedJson['money'].toString(),
      amount: parsedJson['amount'].toString(),
      delivery_id: parsedJson['delivery_id'].toString(),
      date: parsedJson['date'].toString(),
      state: parsedJson['state'].toString(),
      id: parsedJson['id'].toString(),
    );
  }
}