import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../services/weather_service.dart'; // Serviço responsável por buscar dados de clima
import '../services/geodb_service.dart'; // Serviço responsável por buscar cidades

// Tela principal do aplicativo de clima
class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final _cityController =
      TextEditingController(); // Controlador para o campo de texto de cidade
  Future<Map<String, dynamic>>?
      _weatherData; // Armazena os dados de clima que vêm da API

  @override
  void initState() {
    super.initState();
    _fetchWeatherByCurrentLocation(); // Quando a tela abre, já busca o clima da localização atual
  }

  // Busca os dados de clima baseados na localização atual do usuário
  void _fetchWeatherByCurrentLocation() {
    setState(() {
      _weatherData = getWeatherByLocation();
    });
  }

  // Quando o usuário seleciona uma cidade no autocomplete
  void _onCitySelected(String city) {
    _cityController.text = city;
    setState(() {
      _weatherData =
          getWeather(city); // Faz a chamada da API para a cidade digitada
    });
  }

  @override
  void dispose() {
    _cityController.dispose(); // Libera memória quando o widget for destruído
    super.dispose();
  }

  // Processa os dados da previsão de 5 dias e gera valores diários (mínima, máxima, descrição, ícone)
  List<Map<String, dynamic>> _processDailyForecast(List<dynamic> forecastList) {
    final Map<String, List<double>> dailyTemps =
        {}; // Armazena mín e máx por dia

    // Percorre cada item da lista da API
    for (var item in forecastList) {
      final date = DateFormat('EEE, d MMM')
          .format(DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000));
      final temp = item['main']['temp'].toDouble();

      // Se ainda não temos o dia, inicializa com mín e máx iguais
      if (!dailyTemps.containsKey(date)) {
        dailyTemps[date] = [temp, temp];
      } else {
        // Atualiza mín e máx do dia
        if (temp < dailyTemps[date]![0]) {
          dailyTemps[date]![0] = temp;
        }
        if (temp > dailyTemps[date]![1]) {
          dailyTemps[date]![1] = temp;
        }
      }
    }

    // Lista final processada para exibir
    final List<Map<String, dynamic>> processedList = [];

    // Para cada dia, pega também a descrição e o ícone correspondente
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
          // Botão para atualizar pelo GPS
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
            // Campo de busca com autocomplete de cidades
            TypeAheadField(
              textFieldConfiguration: TextFieldConfiguration(
                controller: _cityController,
                decoration: const InputDecoration(
                  labelText: 'Digite uma cidade',
                  border: OutlineInputBorder(),
                ),
              ),
              suggestionsCallback: (pattern) async {
                return await searchCities(
                    pattern); // Busca cidades pelo texto digitado
              },
              itemBuilder: (context, suggestion) {
                return ListTile(
                  title: Text(suggestion),
                );
              },
              onSuggestionSelected: (suggestion) {
                _onCitySelected(
                    suggestion); // Quando usuário escolhe uma cidade
              },
            ),
            const SizedBox(height: 20),

            // Área principal do app (dados do clima atual)
            Expanded(
              child: Center(
                child: FutureBuilder<Map<String, dynamic>>(
                  future: _weatherData, // Conecta os dados da API
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      // Enquanto carrega
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      // Se der erro
                      return Text(
                        'Erro: ${snapshot.error}',
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      );
                    } else if (snapshot.hasData) {
                      // Se os dados chegaram, monta a tela
                      final currentData = snapshot.data!;
                      final iconCode = currentData['weather'][0]['icon'];
                      final iconPath = iconMap[iconCode];

                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          // Nome da cidade + país
                          Text(
                            '${currentData['name']}, ${currentData['sys']['country']}',
                            style: const TextStyle(
                                fontSize: 32, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10),

                          // Ícone animado do clima
                          if (iconPath != null)
                            SvgPicture.asset(
                              'assets/weather_animations/$iconPath',
                              width: 150,
                              height: 150,
                            )
                          else
                            const Icon(Icons.wb_sunny, size: 150),

                          // Temperatura atual
                          Text(
                            '${currentData['main']['temp'].toStringAsFixed(1)}°C',
                            style: const TextStyle(
                                fontSize: 64, fontWeight: FontWeight.w300),
                          ),

                          // Sensação térmica
                          Text(
                            'Sensação: ${currentData['main']['feels_like'].toStringAsFixed(1)}°C',
                            style: const TextStyle(fontSize: 20),
                          ),

                          const SizedBox(height: 20),

                          // Descrição do clima (ex: "céu limpo")
                          Text(
                            currentData['weather'][0]['description'],
                            style: const TextStyle(
                                fontSize: 24, fontStyle: FontStyle.italic),
                          ),

                          const SizedBox(height: 40),

                          // Botão que abre o modal com a previsão de 5 dias
                          ElevatedButton(
                            onPressed: () {
                              final String city = _cityController.text.trim();
                              Future<Map<String, dynamic>> forecastFuture;

                              // Se o usuário digitou cidade, busca por cidade
                              if (city.isNotEmpty) {
                                forecastFuture = get5DayForecastByCity(city);
                              } else {
                                // Caso contrário, busca pela localização
                                forecastFuture = get5DayForecastByLocation();
                              }

                              // Modal inferior para exibir a lista de previsões
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(20)),
                                ),
                                builder: (context) {
                                  return SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.75,
                                    child: Column(
                                      children: [
                                        // "alça" de arrastar
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
                      );
                    } else {
                      // Caso inicial (sem dados ainda)
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

// Widget responsável por exibir a previsão detalhada de 5 dias
class _ForecastContent extends StatelessWidget {
  final Function(List<dynamic>)
      processDailyForecast; // Função que processa dados
  final Future<Map<String, dynamic>> forecastFuture; // Future da API

  const _ForecastContent({
    required this.processDailyForecast,
    required this.forecastFuture,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: forecastFuture, // Usa os dados da API recebidos
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Enquanto carrega
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          // Se ocorrer erro
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

          // Processa os dados para exibir apenas mín/máx e descrição por dia
          final dailyForecast = processDailyForecast(forecastList);

          // Lista de previsões dos próximos dias
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
