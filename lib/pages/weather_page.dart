import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:intl/intl.dart';
import '../services/weather_service.dart';
import '../services/geodb_service.dart';

class WeatherScreen extends StatefulWidget {
  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final _cityController = TextEditingController();
  Future<Map<String, dynamic>>? _weatherData;
  bool _showForecastPopup = false;

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

  void _onCitySelected(String city) {
    _cityController.text = city;
    setState(() {
      _weatherData = getWeather(city);
    });
  }

  void _toggleForecastPopup() {
    setState(() {
      _showForecastPopup = !_showForecastPopup;
    });
  }

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  // Função para processar os dados da API e extrair a previsão diária
  List<Map<String, dynamic>> _processDailyForecast(List<dynamic> forecastList) {
    final Map<String, List<double>> dailyTemps = {};
    for (var item in forecastList) {
      final date = DateFormat('EEE, d MMM')
          .format(DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000));
      final temp = item['main']['temp'].toDouble();
      if (!dailyTemps.containsKey(date)) {
        dailyTemps[date] = [temp, temp];
      } else {
        if (temp < dailyTemps[date]![0]) {
          dailyTemps[date]![0] = temp;
        }
        if (temp > dailyTemps[date]![1]) {
          dailyTemps[date]![1] = temp;
        }
      }
    }
    final List<Map<String, dynamic>> processedList = [];
    dailyTemps.forEach((day, temps) {
      final dailyDescription = forecastList.firstWhere((item) =>
          DateFormat('EEE, d MMM')
              .format(DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000)) ==
          day)['weather'][0]['description'];
      processedList.add({
        'day': day,
        'min_temp': temps[0],
        'max_temp': temps[1],
        'description': dailyDescription
      });
    });
    return processedList;
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
      body: Stack(
        children: [
          // Conteúdo principal da tela
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                TypeAheadField(
                  textFieldConfiguration: TextFieldConfiguration(
                    controller: _cityController,
                    decoration: const InputDecoration(
                      labelText: 'Digite uma cidade',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  suggestionsCallback: (pattern) async {
                    return await searchCities(pattern);
                  },
                  itemBuilder: (context, suggestion) {
                    return ListTile(
                      title: Text(suggestion),
                    );
                  },
                  onSuggestionSelected: (suggestion) {
                    _onCitySelected(suggestion);
                  },
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: Center(
                    child: FutureBuilder<Map<String, dynamic>>(
                      future: _weatherData,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
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
                              ElevatedButton(
                                onPressed: _toggleForecastPopup,
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

          // Pop-up e fundo escuro - MANTENHA-OS SEMPRE NA ÁRVORE DE WIDGETS
          // A visibilidade e interação são controladas por IgnorePointer e AnimatedOpacity
          IgnorePointer(
            ignoring: !_showForecastPopup,
            child: AnimatedOpacity(
              opacity: _showForecastPopup ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 1000),
              child: GestureDetector(
                onTap: _toggleForecastPopup,
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                  alignment: Alignment.bottomCenter,
                  child: Hero(
                    tag: 'forecast-popup',
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeOutExpo,
                      height: _showForecastPopup
                          ? MediaQuery.of(context).size.height * 0.75
                          : 0,
                      width: MediaQuery.of(context).size.width,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Align(
                              alignment: Alignment.topRight,
                              child: IconButton(
                                icon: const Icon(Icons.close,
                                    color: Colors.black),
                                onPressed: _toggleForecastPopup,
                              ),
                            ),
                            const Text(
                              'Previsão de 5 Dias',
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                            const Divider(),
                            _ForecastContent(
                              processDailyForecast: _processDailyForecast,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Novo Widget para o conteúdo da previsão (para organizar o código)
class _ForecastContent extends StatelessWidget {
  final Function(List<dynamic>) processDailyForecast;

  const _ForecastContent({required this.processDailyForecast});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: get5DayForecastByLocation(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
            child: Text(
              'Erro: ${snapshot.error}',
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          );
        } else if (snapshot.hasData) {
          final forecastData = snapshot.data!;
          final List<dynamic> forecastList = forecastData['list'];

          if (forecastList.isEmpty) {
            return const Center(
                child: Text('Nenhum dado de previsão encontrado.'));
          }

          final dailyForecast = processDailyForecast(forecastList);

          return ListView.builder(
            shrinkWrap: true,
            physics:
                const NeverScrollableScrollPhysics(), // Isso é importante para evitar que o ListView lute com o SingleChildScrollView por rolagem
            itemCount: dailyForecast.length,
            itemBuilder: (context, index) {
              final dayData = dailyForecast[index];
              return ListTile(
                title: Text(dayData['day']),
                subtitle: Text(
                  'Min: ${dayData['min_temp'].toStringAsFixed(1)}°C / Máx: ${dayData['max_temp'].toStringAsFixed(1)}°C',
                ),
                trailing: Text(dayData['description']),
              );
            },
          );
        } else {
          return const Center(
              child: Text('Nenhum dado de previsão encontrado.'));
        }
      },
    );
  }
}
