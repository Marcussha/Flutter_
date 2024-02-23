import 'dart:convert';
import 'package:http/http.dart' as http;

Future<List<String>> fetchProvinces() async {
  final overpassUrl = 'http://overpass-api.de/api/interpreter';
  final query = '''
      [out:json];
      area["ISO3166-1"="VN"]->.boundaryarea;
      (
        relation["admin_level"="4"]["boundary"="administrative"]["name"~"^(Tỉnh|Thành phố)"](area.boundaryarea);
      );
      out body;
      >;
      out skel qt;
    ''';

  final response = await http.post(
    Uri.parse(overpassUrl),
    headers: {'Content-Type': 'application/x-www-form-urlencoded'},
    body: {'data': query},
  );

  if (response.statusCode == 200) {
    final jsonResult = json.decode(utf8.decode(response.bodyBytes)); // Convert dữ liệu về chuỗi Unicode UTF-8

    // Kiểm tra xem cấu trúc JSON trả về có phù hợp không
    if (jsonResult.containsKey('elements')) {
      final elements = jsonResult['elements'] as List;
      final provinces = elements.map((element) {
        if (element.containsKey('tags') && element['tags'].containsKey('name')) {
          return element['tags']['name'] as String?;
        } else {
          return null;
        }
      }).whereType<String>().toList();
      return provinces;
    } else {
      throw Exception('Invalid JSON format: elements not found');
    }
  } else {
    throw Exception('Failed to load provinces');
  }
}

Future<List<String>> fetchDistricts(String provinceName) async {
  final overpassUrl = 'http://overpass-api.de/api/interpreter';
  final query = '''
      [out:json];
      area["ISO3166-1"="VN"]->.boundaryarea;
      area["name"="$provinceName"]["boundary"="administrative"]->.provincearea;
      (
        relation["admin_level"="6"]["boundary"="administrative"]["name"](area.provincearea);
      );
      out body;
      >;
      out skel qt;
    ''';

  final response = await http.post(
    Uri.parse(overpassUrl),
    headers: {'Content-Type': 'application/x-www-form-urlencoded'},
    body: {'data': query},
  );

  if (response.statusCode == 200) {
    final jsonResult = json.decode(utf8.decode(response.bodyBytes));

    if (jsonResult.containsKey('elements')) {
      final elements = jsonResult['elements'] as List;
      final districts = elements.map((element) {
        if (element.containsKey('tags') && element['tags'].containsKey('name')) {
          return element['tags']['name'] as String?;
        } else {
          return null;
        }
      }).whereType<String>().toList();
      return districts;
    } else {
      throw Exception('Invalid JSON format: elements not found');
    }
  } else {
    throw Exception('Failed to load districts');
  }
}

Future<List<String>> fetchWards(String districtName, String provinceName) async {
  final overpassUrl = 'http://overpass-api.de/api/interpreter';
  final query = '''
      [out:json];
      area["ISO3166-1"="VN"]->.boundaryarea;
      area["name"="$districtName"]["boundary"="administrative"]["admin_level"="6"]->.districtarea;
      area["name"="$provinceName"]["boundary"="administrative"]->.provincearea;
      (
        relation["admin_level"="8"]["boundary"="administrative"]["name"](area.provincearea);
        relation["admin_level"="8"]["boundary"="administrative"]["name"](area.districtarea);
      );
      out body;
      >;
      out skel qt;
    ''';

  final response = await http.post(
    Uri.parse(overpassUrl),
    headers: {'Content-Type': 'application/x-www-form-urlencoded'},
    body: {'data': query},
  );

  if (response.statusCode == 200) {
    final jsonResult = json.decode(utf8.decode(response.bodyBytes));

    if (jsonResult.containsKey('elements')) {
      final elements = jsonResult['elements'] as List;
      final wards = elements.map((element) {
        if (element.containsKey('tags') && element['tags'].containsKey('name')) {
          return element['tags']['name'] as String?;
        } else {
          return null;
        }
      }).whereType<String>().toList();
      return wards;
    } else {
      throw Exception('Invalid JSON format: elements not found');
    }
  } else {
    throw Exception('Failed to load wards');
  }
}

