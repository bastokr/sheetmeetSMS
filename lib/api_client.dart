import 'dart:convert';
import 'package:flutter/foundation.dart';

import 'package:http/http.dart' as http;

const String domain = "ok1shop.cafe24.com";
const String server_url = "https://ok1shop.cafe24.com";

class NetworkHelper {
  final String url;

  NetworkHelper({required this.url});

  Future getData() async {
    http.Response response = await http.get(
      Uri.https(domain, url),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      //Resultado da requisição
      return jsonDecode(response.body);
    } else {
      print(response.statusCode);
      return null;
    }
  }

  Future sendPostData(postData, gubun) async {
    try {
      // user_name = utf8.decode(base64Decode(user_name ?? ""));

      var url = Uri.https(
        domain,
        this.url,
      );
      http.Response response = await http
          .post(url,
              headers: <String, String>{
                'Content-Type': 'application/json',
              },
              body: json.encode(postData))
          .timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        String data = response.body;
        //return jsonDecode(data);
      } else {
        //   SharedPreferences.handleException();
        //return response;
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  Future getPostData(postData, gubun) async {
    var url = Uri.https(domain, this.url, gubun);
    http.Response response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body:
          postData/*<String, String>{
        'user_id': 'user_id_value',
        'user_pwd': 'user_pwd_value'
      }*/
      ,
    );
    if (response.statusCode == 200) {
      String data = response.body;
      return jsonDecode(data);
    } else {
      print(response.statusCode);
    }
  }
}
