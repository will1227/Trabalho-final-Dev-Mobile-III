import 'package:http/http.dart' as http;
import 'dart:convert';

// Substitua esta chave pela sua chave do RapidAPI para a GeoDB Cities
const String geodbApiKey = '83e9781f57msh1fa9c243dfc93fcp1db8b9jsn1cf84c34cd8d';

Future<List<String>> searchCities(String query) async {
  if (query.isEmpty) {
    return [];
  }

  final url = Uri.https(
    'wft-geo-db.p.rapidapi.com',
    '/v1/geo/cities',
    {
      'namePrefix': query,
      'limit': '5', // Limita a 5 resultados para não sobrecarregar
      'sort': '-population', // Ordena por população
      'languageCode': 'pt'
    },
  );

  try {
    final response = await http.get(
      url,
      headers: {
        'x-rapidapi-key': geodbApiKey,
        'x-rapidapi-host': 'wft-geo-db.p.rapidapi.com',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final cities = data['data'] as List;

      if (cities.isEmpty) {
        return ['Nenhuma cidade encontrada'];
      }

      return cities.map<String>((city) {
        return '${city['name']}, ${city['country']}';
      }).toList();
    } else {
      // Se houver um erro, retorne uma lista com uma mensagem de erro
      return ['Erro ao buscar cidades. Status: ${response.statusCode}'];
    }
  } catch (e) {
    return ['Erro: $e'];
  }
}
