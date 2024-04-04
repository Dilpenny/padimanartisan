class Review {
  String? name, user_id, rater_id, star, img, review, time;
  Review({this.name, this.rater_id, this.user_id, this.star, this.img, this.review, this.time});

  factory Review.fromJson(Map<String, dynamic> parsedJson) {
    return Review(
      name: parsedJson['rater']['name'].toString(),
      img: parsedJson['rater']['img'].toString(),
      user_id: parsedJson['user_id'].toString(),
      review: parsedJson['review'].toString(),
      time: parsedJson['time_ago'].toString(),
      star: parsedJson['star'].toString(),
      rater_id: parsedJson['rater_id'].toString(),
    );
  }
}