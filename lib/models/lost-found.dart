class LostItem {
  String? id, identity, name, date, type, description, photo, slug;
  LostItem({this.identity, this.name, this.type, this.description, this.photo,
    this.id, this.date, this.slug});

  factory LostItem.fromJson(Map<String, dynamic> parsedJson) {
    return LostItem(
      identity: parsedJson['identity'].toString(),
      name: parsedJson['name'].toString(),
      type: parsedJson['type'].toString(),
      id: parsedJson['id'].toString(),
      description: parsedJson['description'].toString(),
      photo: parsedJson['img'].toString(),
      date: parsedJson['date'].toString(),
      slug: parsedJson['slug'].toString(),
    );
  }
}