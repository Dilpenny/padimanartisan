class Clients {
  String? id, email, name, count;
  // my_organization_id
  Clients({this.email, this.name, this.count});

  factory Clients.fromJson(Map<String, dynamic> parsedJson) {
    return Clients(
      name: parsedJson['name'].toString(),
      email: parsedJson['email'].toString(),
      count: parsedJson['count'].toString(),
    );
  }
}