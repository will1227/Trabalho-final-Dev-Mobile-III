import 'package:flutter/material.dart';
import '../services/weather_service.dart';
import 'package:flutterapp/pages/forecast_page.dart'; // Importe a nova tela

class WeatherScreen extends StatefulWidget {
  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final _cityController = TextEditingController();
  Future<Map<String, dynamic>>? _weatherData;

  @override
  void initState() {
    super.initState();
    _fetchWeatherByCurrentLocation();
  }

  void _fetchWeatherByCurrentLocation() {
    setState(() {
      _weatherData = getWeatherByLocation();
    });
  }

  void _searchWeather() {
    if (_cityController.text.isNotEmpty) {
      setState(() {
        _weatherData = getWeather(_cityController.text);
      });
    }
  }

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  // Função para navegar para a tela de previsão
  void _navigateToForecast() {
    Navigator.push(
      context,
      // Cria uma transição de página customizada (slide para cima)
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const ForecastPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.ease;

          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clima App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _fetchWeatherByCurrentLocation,
            tooltip: 'Buscar clima da localização atual',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _cityController,
              decoration: const InputDecoration(
                labelText: 'Digite uma cidade',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _searchWeather(),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _searchWeather,
              child: const Text('Pesquisar'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Center(
                child: FutureBuilder<Map<String, dynamic>>(
                  future: _weatherData,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text(
                        'Erro: ${snapshot.error}',
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      );
                    } else if (snapshot.hasData) {
                      final currentData = snapshot.data!;
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            '${currentData['name']}, ${currentData['sys']['country']}',
                            style: const TextStyle(
                                fontSize: 32, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            '${currentData['main']['temp'].toStringAsFixed(1)}°C',
                            style: const TextStyle(
                                fontSize: 64, fontWeight: FontWeight.w300),
                          ),
                          Text(
                            'Sensação: ${currentData['main']['feels_like'].toStringAsFixed(1)}°C',
                            style: const TextStyle(fontSize: 20),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            currentData['weather'][0]['description'],
                            style: const TextStyle(
                                fontSize: 24, fontStyle: FontStyle.italic),
                          ),
                          const SizedBox(height: 40),
                          // Botão para ver a previsão com animação
                          ElevatedButton(
                            onPressed: _navigateToForecast,
                            child: const Text('Ver Previsão de 5 Dias'),
                          ),
                        ],
                      );
                    } else {
                      return const Text(
                          'Nenhum dado encontrado. Digite uma cidade ou use a sua localização.');
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
