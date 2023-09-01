import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() => runApp(ViagemInteligenteApp());

class ViagemInteligenteApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Viagem Inteligente',
      home: ViagemInteligenteScreen(),
    );
  }
}

class ViagemInteligenteScreen extends StatefulWidget {
  @override
  _ViagemInteligenteScreenState createState() =>
      _ViagemInteligenteScreenState();
}

class _ViagemInteligenteScreenState extends State<ViagemInteligenteScreen> {
  TextEditingController origemController = TextEditingController();
  TextEditingController destinoController = TextEditingController();
  TextEditingController chegadaController = TextEditingController();
  TextEditingController quantidadeDinheiroEstimadoController =
      TextEditingController();
  String quantidadeDinheiro = '';

  Future<void> calcularViagem() async {
    // Obter informações de fuso horário do destino usando a API timezonedb
    String apiKeyTimezoneDB = 'A5G9JE63YNBV';
    String destino = destinoController.text;
    String urlTimezoneDB =
        'http://api.timezonedb.com/v2.1/get-time-zone?key=$apiKeyTimezoneDB&format=json&by=zone&zone=$destino';

    final responseTimezoneDB = await http.get(Uri.parse(urlTimezoneDB));

    if (responseTimezoneDB.statusCode == 200) {
      final dataTimezoneDB = json.decode(responseTimezoneDB.body);
      int timezone = dataTimezoneDB['gmtOffset'];

      // Obter informações de taxa de câmbio usando a API exchangerates
      String apiKeyExchangeRates = 'bebda881b301374bab4aac58026f9e33';
      String origem = origemController.text;
      String urlExchangeRates =
          'https://api.apilayer.com/exchangerates_data/latest?base=$origem';

      final responseExchangeRates = await http.get(
        Uri.parse(urlExchangeRates),
        headers: {
          'apikey': apiKeyExchangeRates,
        },
      );

      if (responseExchangeRates.statusCode == 200) {
        final dataExchangeRates = json.decode(responseExchangeRates.body);

        if (dataExchangeRates != null && dataExchangeRates.containsKey('rates')) {
          double taxaCambio = dataExchangeRates['rates'][destino];
          double dinheiroOrigem =
              double.tryParse(quantidadeDinheiroEstimadoController.text) ?? 0.0;
          double dinheiroDestino = dinheiroOrigem * taxaCambio;

          setState(() {
            quantidadeDinheiro =
                '${dinheiroDestino.toStringAsFixed(2)} ${destinoController.text}';
          });
        } else {
          // Lidar com a ausência da chave 'rates' na resposta da API exchangerates
          setState(() {
            quantidadeDinheiro = 'Erro na obtenção das taxas de câmbio';
          });
        }
      } else {
        // Lidar com problemas na solicitação à API exchangerates
        setState(() {
          quantidadeDinheiro = 'Erro na solicitação da API de taxas de câmbio';
        });
      }
    } else {
      // Lidar com problemas na solicitação à API timezonedb
      setState(() {
        quantidadeDinheiro = 'Erro na solicitação da API de fuso horário';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Viagem Inteligente'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('País de Origem'),
            TextFormField(controller: origemController),
            Text('Destino'),
            TextFormField(controller: destinoController),
            Text('Horário de Chegada Estimado'),
            TextFormField(controller: chegadaController),
            Text('Quantidade de Dinheiro Estimada (Moeda de Origem)'),
            TextFormField(controller: quantidadeDinheiroEstimadoController),
            ElevatedButton(
              onPressed: calcularViagem,
              child: Text('Calcular Viagem'),
            ),
            SizedBox(height: 20.0),
            Text('Quantidade de Dinheiro Disponível no Destino'),
            Text(quantidadeDinheiro),
          ],
        ),
      ),
    );
  }
}
