import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';

// Substitua esta string pela sua chave de API real
const String apiKey = '7ccf050c4bcbafd738acaf8e740d11b9';

// Função para buscar o clima por nome de cidade
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

// Função para buscar o clima pela localização atual do dispositivo
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

  if (permission == LocationPermission.deniedForever) {
    throw Exception(
        'Permissão de localização negada permanentemente. Por favor, habilite nas configurações.');
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

// Função para buscar a previsão dos próximos dias (API gratuita de 5 dias / 3 horas)
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
  if (permission == LocationPermission.deniedForever) {
    throw Exception('Permissão de localização negada permanentemente.');
  }

  Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high);

  final url =
      'https://api.openweathermap.org/data/2.5/forecast?lat=${position.latitude}&lon=${position.longitude}&cnt=24&appid=$apiKey&units=metric&lang=pt_br';

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
