// lib/services/weather_api.dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart'; // Importe o geolocator

Future<Map<String, dynamic>> getWeather(String city) async {
  final apiKey = '7ccf050c4bcbafd738acaf8e740d11b9';
  final url =
      'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric&lang=pt_br';

  try {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Falha ao carregar os dados do clima.');
    }
  } catch (e) {
    throw Exception('Erro: $e');
  }
}

// Nova função para obter o clima pela localização
Future<Map<String, dynamic>> getWeatherByLocation() async {
  final apiKey = '7ccf050c4bcbafd738acaf8e740d11b9';
  // Primeiro, verifique se o serviço de localização está habilitado.
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    throw Exception('Serviço de localização desabilitado.');
  }

  // Em seguida, verifique se a permissão foi concedida.
  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    // Se não, solicite a permissão ao usuário.
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Se o usuário negar novamente, retorne um erro.
      throw Exception('Permissão de localização negada.');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    throw Exception(
        'Permissão de localização negada permanentemente. Por favor, habilite nas configurações do seu dispositivo.');
  }

  // Se tudo estiver ok, pegue a posição atual.
  Position position = await Geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.high, // Tenta obter a melhor precisão
  );

  final url =
      'https://api.openweathermap.org/data/2.5/weather?lat=${position.latitude}&lon=${position.longitude}&appid=$apiKey&units=metric&lang=pt_br';

  try {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
          'Falha ao carregar os dados do clima para a sua localização.');
    }
  } catch (e) {
    throw Exception('Erro: $e');
  }
}
