class WalletHistory {
  String? name, status, id, receiver, type, amount, time_ago, topic, user_id, money, statusx_status, statusx_color, description;
  WalletHistory({this.name, this.status, this.id, this.receiver, this.amount, this.user_id, this.type,
    this.topic, this.time_ago, this.money, this.statusx_status, this.statusx_color, this.description});

  factory WalletHistory.fromJson(Map<String, dynamic> parsedJson) {
    return WalletHistory(
      name: parsedJson['sender']['name'].toString(),
      receiver: parsedJson['receiver']['name'].toString(),
      description: parsedJson['description'].toString(),
      type: parsedJson['type'].toString(),
      amount: parsedJson['amount'].toString(),
      id: parsedJson['id'].toString(),
      status: parsedJson['status'].toString(),
      user_id: parsedJson['user_id'].toString(),
      time_ago: parsedJson['time_ago'].toString(),
      money: parsedJson['money'].toString(),
      statusx_status: parsedJson['statusx']['status'].toString(),
      statusx_color: parsedJson['statusx']['color'].toString(),
    );
  }
}