import 'package:http/http.dart' as http;
import 'dart:convert';

Future<Map<String, dynamic>> getWeather(String city) async {
  final apiKey = '7ccf050c4bcbafd738acaf8e740d11b9';

  final url =
      'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric&lang=pt_br';

  try {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      // Requisição bem-sucedida, retorna o corpo da resposta
      return jsonDecode(response.body);
    } else {
      // Se a requisição não for bem-sucedida, lança uma exceção.
      throw Exception(
          'Falha ao carregar os dados do clima. Status: ${response.statusCode}');
    }
  } catch (e) {
    // Captura qualquer erro de rede ou parsing
    throw Exception('Erro: $e');
  }
}
