import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';

// Substitua esta string pela sua chave de API real
const String apiKey = '7ccf050c4bcbafd738acaf8e740d11b9';

// Mapeamento dos códigos da API para os nomes dos seus arquivos SVG
const Map<String, String> iconMap = {
  '01d': 'clear-day.svg',
  '01n': 'clear-night.svg',
  '02d': 'cloudy-1-day.svg',
  '02n': 'cloudy-1-night.svg',
  '03d': 'cloudy.svg',
  '03n': 'cloudy.svg',
  '04d': 'cloudy.svg',
  '04n': 'cloudy.svg',
  '09d': 'rainy-1-day.svg',
  '09n': 'rainy-1-night.svg',
  '10d': 'rainy-2-day.svg',
  '10n': 'rainy-2-night.svg',
  '11d': 'isolated-thunderstorms-day.svg',
  '11n': 'isolated-thunderstorms-night.svg',
  '13d': 'snow.svg',
  '13n': 'snow.svg',
  '50d': 'haze-day.svg',
  '50n': 'haze-night.svg',
};

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

// Função para buscar a previsão por nome de cidade
Future<Map<String, dynamic>> get5DayForecastByCity(String city) async {
  final url =
      'https://api.openweathermap.org/data/2.5/forecast?q=$city&appid=$apiKey&units=metric&lang=pt_br';
  try {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
          'Falha ao carregar a previsão para a cidade. Verifique o nome.');
    }
  } catch (e) {
    throw Exception('Erro ao buscar a previsão: $e');
  }
}

// Função para buscar a previsão dos próximos dias pela localização (API gratuita de 5 dias / 3 horas)
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
      'https://api.openweathermap.org/data/2.5/forecast?lat=${position.latitude}&lon=${position.longitude}&appid=$apiKey&units=metric&lang=pt_br';
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
