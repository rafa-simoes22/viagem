import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CurrencyConversionScreen extends StatefulWidget {
  @override
  _CurrencyConversionScreenState createState() => _CurrencyConversionScreenState();
}

class _CurrencyConversionScreenState extends State<CurrencyConversionScreen> {
  double availableMoney = 0.0;
  String convertedMoney = '0.00';
  String baseCurrency = 'USD';
  String targetCurrency = 'EUR';

  List<String> currencies = ['USD', 'BRL', 'EUR', 'GBP', 'JPY'];

  Future<void> fetchCurrencyConversion() async {
    final response = await http.get(
      Uri.parse('http://data.fixer.io/api/latest?access_key=6a6252851c50f01cf5b7d96a5e19e281&format=1'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final rates = data['rates'];

      if (rates != null) {
        final dynamic baseRate = rates[baseCurrency];
        final dynamic targetRate = rates[targetCurrency];

        if (baseRate != null && targetRate != null) {
          final double exchangeRate = targetRate / baseRate.toDouble();
          final double result = availableMoney * exchangeRate;
          setState(() {
            convertedMoney = result.toStringAsFixed(2);
          });
        } else {
          setState(() {
            convertedMoney = '0.00';
          });
        }
      } else {
        setState(() {
          convertedMoney = '0.00';
        });
      }
    } else {
      setState(() {
        convertedMoney = '0.00';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Viagem Inteligente - Conversão de Moeda'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              onChanged: (value) {
                setState(() {
                  availableMoney = double.parse(value);
                });
              },
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Quantidade de Dinheiro Disponível'),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                DropdownButton<String>(
                  value: baseCurrency,
                  onChanged: (value) {
                    setState(() {
                      baseCurrency = value!;
                    });
                  },
                  items: currencies.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                DropdownButton<String>(
                  value: targetCurrency,
                  onChanged: (value) {
                    setState(() {
                      targetCurrency = value!;
                    });
                  },
                  items: currencies.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: () {
                fetchCurrencyConversion();
              },
              child: Text('Converter Moeda'),
            ),
            Text('Quantidade de Dinheiro no Destino: $convertedMoney $targetCurrency'),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: CurrencyConversionScreen(),
  ));
}
