import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart'; // Autocomplete para cidades
import 'package:intl/intl.dart'; // Formatação de datas
import 'package:flutter_svg/flutter_svg.dart'; // Para exibir ícones SVG
import '../services/weather_service.dart'; // Serviço para buscar dados de clima
import '../services/geodb_service.dart'; // Serviço para buscar cidades

// Tela principal do aplicativo de clima
class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final _cityController = TextEditingController(); // Controla o campo de cidade
  Future<Map<String, dynamic>>?
      _weatherData; // Future que guarda os dados do clima

  // Variável para animar a opacidade do container de clima
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();
    // Ao iniciar a tela, busca o clima pela localização atual
    _fetchWeatherByCurrentLocation();
  }

  // Função que busca o clima usando GPS/localização do usuário
  void _fetchWeatherByCurrentLocation() {
    setState(() {
      _opacity = 0.0; // Esconde o conteúdo antes de atualizar
      _weatherData = getWeatherByLocation(); // Chamada à API
    });

    // Quando os dados chegarem, mostra o conteúdo com animação de opacidade
    _weatherData!.then((_) {
      Future.delayed(const Duration(milliseconds: 50), () {
        setState(() {
          _opacity = 1.0;
        });
      });
    });
  }

  // Função chamada quando o usuário seleciona uma cidade no autocomplete
  void _onCitySelected(String city) {
    _cityController.text = city;
    setState(() {
      _opacity = 0.0; // Esconde o conteúdo antigo
      _weatherData = getWeather(city); // Busca clima da cidade selecionada
    });

    // Mostra o novo conteúdo com animação
    _weatherData!.then((_) {
      Future.delayed(const Duration(milliseconds: 50), () {
        setState(() {
          _opacity = 1.0;
        });
      });
    });
  }

  // Função que processa a previsão de 5 dias para exibir apenas mín, máx, descrição e ícone por dia
  List<Map<String, dynamic>> _processDailyForecast(List<dynamic> forecastList) {
    final Map<String, List<double>> dailyTemps = {};
    for (var item in forecastList) {
      final date = DateFormat('EEE, d MMM')
          .format(DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000));
      final temp = item['main']['temp'].toDouble();

      // Guarda temperatura mínima e máxima de cada dia
      if (!dailyTemps.containsKey(date)) {
        dailyTemps[date] = [temp, temp];
      } else {
        if (temp < dailyTemps[date]![0]) dailyTemps[date]![0] = temp;
        if (temp > dailyTemps[date]![1]) dailyTemps[date]![1] = temp;
      }
    }

    // Cria lista final com dia, mín/máx, descrição e ícone
    final List<Map<String, dynamic>> processedList = [];
    dailyTemps.forEach((day, temps) {
      final dailyData = forecastList.firstWhere((item) =>
          DateFormat('EEE, d MMM')
              .format(DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000)) ==
          day);
      processedList.add({
        'day': day,
        'min_temp': temps[0],
        'max_temp': temps[1],
        'description': dailyData['weather'][0]['description'],
        'icon': dailyData['weather'][0]['icon']
      });
    });
    return processedList;
  }

  @override
  void dispose() {
    _cityController.dispose(); // Libera memória do controlador
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clima App'),
        actions: [
          // Botão para atualizar clima pela localização
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
          children: [
            // Campo de texto com autocomplete de cidades
            TypeAheadField(
              textFieldConfiguration: TextFieldConfiguration(
                controller: _cityController,
                decoration: const InputDecoration(
                  labelText: 'Digite uma cidade',
                  border: OutlineInputBorder(),
                ),
              ),
              suggestionsCallback: (pattern) async =>
                  await searchCities(pattern),
              itemBuilder: (context, suggestion) =>
                  ListTile(title: Text(suggestion)),
              onSuggestionSelected: _onCitySelected,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: FutureBuilder<Map<String, dynamic>>(
                future: _weatherData, // Conecta aos dados do clima
                builder: (context, snapshot) {
                  // Mostra indicador de carregamento enquanto espera
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    // Mostra erro caso a API falhe
                    return Center(
                      child: Text(
                        'Erro: ${snapshot.error}',
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    );
                  } else if (snapshot.hasData) {
                    final currentData = snapshot.data!;
                    final iconCode = currentData['weather'][0]['icon'];
                    final iconPath = iconMap[iconCode];

                    // Container animado que aparece suavemente com opacidade
                    return AnimatedOpacity(
                      duration: const Duration(milliseconds: 700),
                      opacity: _opacity,
                      curve: Curves.easeInOut,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 700),
                        curve: Curves.easeInOut,
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Nome da cidade e país
                            Text(
                              '${currentData['name']}, ${currentData['sys']['country']}',
                              style: const TextStyle(
                                  fontSize: 32, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 10),
                            // Ícone do clima
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
                            // Descrição do clima
                            Text(
                              currentData['weather'][0]['description'],
                              style: const TextStyle(
                                  fontSize: 24, fontStyle: FontStyle.italic),
                            ),
                            const SizedBox(height: 40),
                            // Botão que abre modal com previsão de 5 dias
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
                                  builder: (context) => SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.75,
                                    child: Column(
                                      children: [
                                        // "Alça" para arrastar o modal
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
                                  ),
                                );
                              },
                              child: const Text('Ver Previsão de 5 Dias'),
                            ),
                          ],
                        ),
                      ),
                    );
                  } else {
                    // Caso não haja dados ainda
                    return const Center(
                      child: Text(
                        'Nenhum dado encontrado. Digite uma cidade ou use a sua localização.',
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget que exibe a previsão detalhada de 5 dias
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
          // Indicador de carregamento
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          // Mostra erro
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
