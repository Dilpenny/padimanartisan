class CustomerRequest {
  String? id, time_ago, artisan_id, user_id, service, statusx_color, artisan, slug, asset_name, asset_slug,
      asset_img, status, status_code, amount, payment_method;
  CustomerRequest({this.artisan, this.artisan_id, this.time_ago, this.statusx_color, this.service, this.asset_name,
    this.user_id, this.id, this.slug, this.asset_img, this.asset_slug, this.status, this.status_code,
    this.amount, this.payment_method});

  factory CustomerRequest.fromJson(Map<String, dynamic> parsedJson) {
    return CustomerRequest(
      time_ago: parsedJson['time_ago'].toString(),
      user_id: parsedJson['user_id'].toString(),
      payment_method: parsedJson['payment_method'].toString(),
      artisan_id: parsedJson['artisan_id'].toString(),
      artisan: parsedJson['artisan']['name'].toString(),
      amount: parsedJson['amount'].toString(),
      id: parsedJson['id'].toString(),
      asset_name: parsedJson['asset']['model'].toString(),
      asset_slug: parsedJson['asset']['slug'].toString(),
      asset_img: parsedJson['asset']['img'].toString(),
      statusx_color: parsedJson['statusx']['color'].toString(),
      status_code: parsedJson['status'].toString(),
      status: parsedJson['statusx']['status'].toString(),
      service: parsedJson['service'].toString(),
      slug: parsedJson['slug'].toString(),
    );
  }
}