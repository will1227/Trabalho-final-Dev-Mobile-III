import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../services/weather_service.dart';
import '../services/geodb_service.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
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

  void _onCitySelected(String city) {
    _cityController.text = city;
    setState(() {
      _weatherData = getWeather(city);
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
      final dailyData = forecastList.firstWhere((item) =>
          DateFormat('EEE, d MMM')
              .format(DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000)) ==
          day);
      final dailyDescription = dailyData['weather'][0]['description'];
      final dailyIconCode = dailyData['weather'][0]['icon'];
      processedList.add({
        'day': day,
        'min_temp': temps[0],
        'max_temp': temps[1],
        'description': dailyDescription,
        'icon': dailyIconCode
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
      body: Padding(
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
                      final iconCode = currentData['weather'][0]['icon'];
                      final iconPath = iconMap[iconCode];

                      // Animação de Opacidade para o conteúdo principal
                      return AnimatedOpacity(
                        opacity:
                            snapshot.connectionState == ConnectionState.done
                                ? 1.0
                                : 0.0,
                        duration: const Duration(milliseconds: 500),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            // Animando o contêiner do cartão do clima
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeInOut,
                              padding: const EdgeInsets.all(24.0),
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(15.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    '${currentData['name']}, ${currentData['sys']['country']}',
                                    style: const TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 10),
                                  if (iconPath != null)
                                    SvgPicture.asset(
                                      'assets/weather_animations/$iconPath',
                                      width: 150,
                                      height: 150,
                                    )
                                  else
                                    const Icon(Icons.wb_sunny, size: 150),
                                  Text(
                                    '${currentData['main']['temp'].toStringAsFixed(1)}°C',
                                    style: const TextStyle(
                                        fontSize: 64,
                                        fontWeight: FontWeight.w300),
                                  ),
                                  Text(
                                    'Sensação: ${currentData['main']['feels_like'].toStringAsFixed(1)}°C',
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    currentData['weather'][0]['description'],
                                    style: const TextStyle(
                                        fontSize: 24,
                                        fontStyle: FontStyle.italic),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 40),
                            ElevatedButton(
                              onPressed: () {
                                final String city = _cityController.text.trim();
                                Future<Map<String, dynamic>> forecastFuture;

                                if (city.isNotEmpty) {
                                  forecastFuture = get5DayForecastByCity(city);
                                } else {
                                  forecastFuture = get5DayForecastByLocation();
                                }

                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(20)),
                                  ),
                                  builder: (context) {
                                    return SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.75,
                                      child: Column(
                                        children: [
                                          Container(
                                            height: 5,
                                            width: 40,
                                            margin: const EdgeInsets.symmetric(
                                                vertical: 10),
                                            decoration: BoxDecoration(
                                              color: Colors.grey[300],
                                              borderRadius:
                                                  BorderRadius.circular(2.5),
                                            ),
                                          ),
                                          const Text(
                                            'Previsão de 5 Dias',
                                            style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          const Divider(),
                                          Expanded(
                                            child: _ForecastContent(
                                              processDailyForecast:
                                                  _processDailyForecast,
                                              forecastFuture: forecastFuture,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                              child: const Text('Ver Previsão de 5 Dias'),
                            ),
                          ],
                        ),
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

// O Widget _ForecastContent continua inalterado

class _ForecastContent extends StatelessWidget {
  final Function(List<dynamic>) processDailyForecast;
  final Future<Map<String, dynamic>> forecastFuture;

  const _ForecastContent({
    required this.processDailyForecast,
    required this.forecastFuture,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: forecastFuture,
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
            itemCount: dailyForecast.length,
            itemBuilder: (context, index) {
              final dayData = dailyForecast[index];
              final iconPath = iconMap[dayData['icon']];

              return ListTile(
                leading: iconPath != null
                    ? SvgPicture.asset(
                        'assets/weather_animations/$iconPath',
                        width: 40,
                        height: 40,
                      )
                    : const Icon(Icons.cloud_queue, size: 40),
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
