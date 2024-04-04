class ActivityHistory {
  String? name, seen, id, message, time_ago, topic, user_id;
  ActivityHistory({this.name, this.seen, this.id, this.message, this.user_id, this.time_ago});

  factory ActivityHistory.fromJson(Map<String, dynamic> parsedJson) {
    return ActivityHistory(
      name: parsedJson['title'].toString(),
      message: parsedJson['message'].toString(),
      id: parsedJson['id'].toString(),
      seen: parsedJson['seen'].toString(),
      user_id: parsedJson['user_id'].toString(),
      time_ago: parsedJson['time_ago'].toString(),
    );
  }
}