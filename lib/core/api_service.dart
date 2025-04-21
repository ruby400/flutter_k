import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/place_model.dart';

class ApiService {
  late final String _clientId;
  late final String _clientSecret;
  late final String _vworldKey;
  ApiService() {
    _clientId = dotenv.env['NAVER_CLIENT_ID'] ?? '';
    _clientSecret = dotenv.env['NAVER_CLIENT_SECRET'] ?? '';
    _vworldKey = dotenv.env['VWORLD_API_KEY'] ?? '';
    if (_clientId.isEmpty || _clientSecret.isEmpty || _vworldKey.isEmpty) {
      throw Exception('API 키 누락 오류');
    }
  }
  Future<List<Place>> searchPlaces(String keyword) async {
    final url =
        'https://openapi.naver.com/v1/search/local.json?query=${Uri.encodeQueryComponent(keyword)}&display=10&start=1&sort=random';
    try {
      final response = await http
          .get(
            Uri.parse(url),
            headers: {
              'X-Naver-Client-Id': _clientId,
              'X-Naver-Client-Secret': _clientSecret,
            },
          )
          .timeout(const Duration(seconds: 10)); // 타임아웃 10초 설정
      if (response.statusCode == 200) {
        final jsonBody = json.decode(response.body);
        final items = jsonBody['items'] as List;
        List<Place> results = [];
        for (var item in items) {
          final name = _stripHtml(item['title']);
          final roadAddress = item['roadAddress'] ?? item['address'] ?? '';
          final link = item['link'] ?? '';
          final coordPlace = await _getCoordFromVWorld(roadAddress);
          results.add(
            Place(
              name: name,
              address: roadAddress,
              link: link,
              x: coordPlace?.x,
              y: coordPlace?.y,
            ),
          );
        }
        return results;
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  Future<Place?> _getCoordFromVWorld(String address) async {
    final url =
        'https://api.vworld.kr/req/address?service=address&request=getcoord&type=ROAD&address=${Uri.encodeQueryComponent(address)}&key=$_vworldKey';
    try {
      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 10)); // 타임아웃 10초 설정
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final responseBody = data['response'];
        if (responseBody == null ||
            responseBody['status'] != 'OK' ||
            responseBody['result'] == null ||
            !(responseBody['result'] is List) ||
            (responseBody['result'] as List).isEmpty) {
          return null;
        }
        final firstResult = responseBody['result'][0];
        final point = firstResult['point'];
        if (point == null || point['x'] == null || point['y'] == null) {
          return null;
        }
        final x = double.tryParse(point['x']);
        final y = double.tryParse(point['y']);
        return Place(name: address, address: address, x: x, y: y);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  String _stripHtml(String htmlText) {
    return htmlText.replaceAll(RegExp(r'<[^>]*>'), '');
  }
}
