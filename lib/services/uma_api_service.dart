import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/character.dart';
import '../models/character_detail.dart';

class UmaApiService {
  static const String baseUrl = 'https://umapyoi.net/api/v1';

  Future<List<Character>> fetchCharacterList() async {
    final response = await http.get(Uri.parse('$baseUrl/character/list'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Character.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar personajes: ${response.statusCode}');
    }
  }

  Future<CharacterDetail> fetchCharacterDetail(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/character/$id'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return CharacterDetail.fromJson(data);
    } else {
      throw Exception('Error al cargar detalle: ${response.statusCode}');
    }
  }
}