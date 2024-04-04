class Affiliate {
  String? name, date;
  Affiliate({this.name, this.date});

  factory Affiliate.fromJson(Map<String, dynamic> parsedJson) {
    return Affiliate(
      name: parsedJson['name'].toString(),
      date: parsedJson['date'].toString(),
    );
  }
}