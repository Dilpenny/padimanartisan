class CallHistory {
  String? caller_id, callee_id, caller_email, callee_email, caller_name, callee_name, caller_img, caller_phone
  , callee_phone, callee_img, callee_device_token, caller_device_token, time_ago;
  // my_organization_id
  CallHistory({this.callee_id, this.caller_id, this.callee_email, this.caller_email, this.callee_name, this.time_ago,
    this.caller_name, this.callee_phone, this.caller_phone, this.callee_img, this.caller_img,
    this.callee_device_token, this.caller_device_token});

  factory CallHistory.fromJson(Map<String, dynamic> parsedJson) {
    return CallHistory(
      caller_id: parsedJson['caller_id'].toString(),
      callee_id: parsedJson['callee_id'].toString(),
      time_ago: parsedJson['time_ago'].toString(),
      callee_email: parsedJson['callee']['email'].toString(),
      callee_img: parsedJson['callee']['img'].toString(),
      caller_img: parsedJson['caller']['img'].toString(),
      caller_email: parsedJson['caller']['email'].toString(),
      callee_name: parsedJson['callee']['name'].toString(),
      caller_name: parsedJson['caller']['name'].toString(),
      caller_phone: parsedJson['caller']['phone'].toString(),
      callee_phone: parsedJson['callee']['phone'].toString(),
      callee_device_token: parsedJson['callee']['device_token'].toString(),
      caller_device_token: parsedJson['caller']['device_token'].toString(),
    );
  }
}