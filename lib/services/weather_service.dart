// lib/services/weather_api.dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';

const String apiKey = '7ccf050c4bcbafd738acaf8e740d11b9';

Future<Map<String, dynamic>> getWeather(String city) async {
  final url =
      'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric&lang=pt_br';
  try {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
          'Falha ao carregar os dados do clima. Verifique o nome da cidade.');
    }
  } catch (e) {
    throw Exception('Erro ao buscar o clima: $e');
  }
}

Future<Map<String, dynamic>> getWeatherByLocation() async {
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    throw Exception(
        'Serviço de localização desabilitado. Por favor, habilite o GPS.');
  }

  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      throw Exception('Permissão de localização negada.');
    }
  }

  Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high);

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
    throw Exception('Erro ao buscar o clima por localização: $e');
  }
}

// Essa função será usada para a nova tela de previsão
Future<Map<String, dynamic>> get5DayForecastByLocation() async {
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    throw Exception(
        'Serviço de localização desabilitado. Por favor, habilite o GPS.');
  }

  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      throw Exception('Permissão de localização negada.');
    }
  }

  Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high);

  final url =
      'https://api.openweathermap.org/data/2.5/forecast?lat=${position.latitude}&lon=${position.longitude}&cnt=40&appid=$apiKey&units=metric&lang=pt_br';
  try {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Falha ao carregar a previsão do tempo de 5 dias.');
    }
  } catch (e) {
    throw Exception('Erro ao buscar a previsão: $e');
  }
}
