import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FlutterSession{
  Future getInt(String column) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.getInt(column);
  }
  Future get(String column) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(await prefs.getString(column) == null){
      return '';
    }
    return await prefs.getString(column);
  }
  Future set(String column, String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(column, value.toString());
  }

  Future clear(String column) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(column);
  }

  Future setInt(String column, int value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(column, value);
  }
}