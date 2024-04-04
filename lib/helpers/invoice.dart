class Invoices {
  String? date;
  String? id, money, delivery_id, delivery_code;
  String? status, amount, state;
  // my_organization_id
  Invoices({this.status, this.amount, this.delivery_id, this.delivery_code, this.money, this.state, this.date, this.id});

  factory Invoices.fromJson(Map<String, dynamic> parsedJson) {
    return Invoices(
      status: parsedJson['status'].toString(),
      money: parsedJson['money'].toString(),
      amount: parsedJson['amount'].toString(),
      delivery_id: parsedJson['delivery_id'].toString(),
      delivery_code: parsedJson['delivery_info']['code'].toString(),
      date: parsedJson['date'].toString(),
      state: parsedJson['state'].toString(),
      id: parsedJson['id'].toString(),
    );
  }
}