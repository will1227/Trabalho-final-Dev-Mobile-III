import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/weather_service.dart';

class ForecastPage extends StatelessWidget {
  const ForecastPage({super.key});

  // Função para processar os dados da API e extrair a previsão diária
  List<Map<String, dynamic>> _processDailyForecast(List<dynamic> forecastList) {
    final Map<String, List<double>> dailyTemps = {};

    for (var item in forecastList) {
      final date = DateFormat('EEE, d MMM').format(
        DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000),
      );
      final temp = item['main']['temp'].toDouble();

      if (!dailyTemps.containsKey(date)) {
        dailyTemps[date] = [temp, temp]; // [min, max]
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
      // Encontra a descrição do clima para o dia. Usaremos a do primeiro item de cada dia
      final dailyDescription = forecastList.firstWhere((item) =>
          DateFormat('EEE, d MMM')
              .format(DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000)) ==
          day)['weather'][0]['description'];

      processedList.add({
        'day': day,
        'min_temp': temps[0],
        'max_temp': temps[1],
        'description': dailyDescription,
      });
    });

    return processedList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Previsão de 5 Dias'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
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

            // Processa a lista completa para obter a previsão diária
            final dailyForecast = _processDailyForecast(forecastList);

            return ListView.builder(
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
      ),
    );
  }
}
