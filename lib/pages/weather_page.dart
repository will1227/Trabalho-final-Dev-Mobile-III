// lib/pages/weather_screen.dart
import 'package:flutter/material.dart';
import '../services/weather_service.dart';
import 'package:intl/intl.dart';

class WeatherScreen extends StatefulWidget {
  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final _cityController = TextEditingController();
  Future<List<Map<String, dynamic>>>? _weatherData;

  @override
  void initState() {
    super.initState();
    _fetchWeatherByCurrentLocation();
  }

  void _fetchWeatherByCurrentLocation() {
    setState(() {
      _weatherData = Future.wait([
        getWeatherByLocation(),
        get5DayForecastByLocation(),
      ]);
    });
  }

  void _searchWeather() {
    if (_cityController.text.isNotEmpty) {
      setState(() {
        _weatherData = Future.wait([
          getWeather(_cityController.text),
          get5DayForecastByLocation(),
        ]);
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
                child: FutureBuilder<List<Map<String, dynamic>>>(
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
                      final currentData = snapshot.data![0];
                      final forecastData = snapshot.data![1];

                      // Verifica se a lista de previsão não está vazia
                      if (forecastData['list'] == null ||
                          forecastData['list'].isEmpty) {
                        return Text('Nenhum dado de previsão encontrado.');
                      }

                      return SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            // Informações do clima atual
                            Text(
                              '${currentData['name']}, ${currentData['sys']['country']}',
                              style: TextStyle(
                                  fontSize: 32, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 10),
                            Text(
                              '${currentData['main']['temp'].toStringAsFixed(1)}°C',
                              style: TextStyle(
                                  fontSize: 64, fontWeight: FontWeight.w300),
                            ),
                            Text(
                              'Sensação: ${currentData['main']['feels_like'].toStringAsFixed(1)}°C',
                              style: TextStyle(fontSize: 20),
                            ),
                            SizedBox(height: 20),
                            Text(
                              currentData['weather'][0]['description'],
                              style: TextStyle(
                                  fontSize: 24, fontStyle: FontStyle.italic),
                            ),

                            SizedBox(height: 40),
                            Text(
                              'Previsão para os próximos 2 dias',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 10),

                            // Lista de previsão
                            // Usamos o loop `for` e adicionamos um `if` para segurança
                            Column(
                              children: [
                                for (int i = 1; i <= 3; i++)
                                  if ((i * 8) < forecastData['list'].length)
                                    ListTile(
                                      title: Text(
                                        DateFormat('EEE, d').format(
                                          DateTime.fromMillisecondsSinceEpoch(
                                            forecastData['list'][i * 8]['dt'] *
                                                1000,
                                          ),
                                        ),
                                      ),
                                      subtitle: Text(
                                        'Min: ${forecastData['list'][i * 8]['main']['temp_min'].toStringAsFixed(1)}°C / Máx: ${forecastData['list'][i * 8]['main']['temp_max'].toStringAsFixed(1)}°C',
                                      ),
                                      trailing: Text(forecastData['list'][i * 8]
                                          ['weather'][0]['description']),
                                    ),
                              ],
                            ),
                          ],
                        ),
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
