// lib/pages/weather_screen.dart
import 'package:flutter/material.dart';
import '../services/weather_service.dart';
// Certifique-se de que o caminho está correto

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
    // Você pode começar a tela buscando o clima da localização atual
    _fetchWeatherByCurrentLocation();
  }

  // Função para buscar o clima pela localização atual
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Clima App'),
        actions: [
          // Adicione um botão para buscar a localização
          IconButton(
            icon: Icon(Icons.my_location),
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
              decoration: InputDecoration(
                labelText: 'Digite uma cidade',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _searchWeather(),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _searchWeather,
              child: Text('Pesquisar'),
            ),
            SizedBox(height: 20),
            Expanded(
              child: Center(
                child: FutureBuilder<Map<String, dynamic>>(
                  future: _weatherData,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text(
                        'Erro: ${snapshot.error}',
                        style: TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      );
                    } else if (snapshot.hasData) {
                      final data = snapshot.data!;
                      final main = data['main'];
                      final weather = data['weather'][0];

                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            '${data['name']}, ${data['sys']['country']}',
                            style: TextStyle(
                                fontSize: 32, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 10),
                          Text(
                            '${main['temp'].toStringAsFixed(1)}°C',
                            style: TextStyle(
                                fontSize: 64, fontWeight: FontWeight.w300),
                          ),
                          Text(
                            'Sensação: ${main['feels_like'].toStringAsFixed(1)}°C',
                            style: TextStyle(fontSize: 20),
                          ),
                          SizedBox(height: 20),
                          Text(
                            weather['description'],
                            style: TextStyle(
                                fontSize: 24, fontStyle: FontStyle.italic),
                          ),
                        ],
                      );
                    } else {
                      return Text(
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
