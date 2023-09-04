import 'package:flutter/material.dart';
import 'tela1.dart'; // Importe a tela TimeZoneScreen
import 'tela2.dart'; // Importe a tela CurrencyConversionScreen

void main() {
  runApp(ViagemInteligenteApp());
}

class ViagemInteligenteApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Viagem Inteligente',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => HomeScreen(),
        '/timezone': (context) => TimeZoneScreen(), // Rota para TimeZoneScreen
        '/currency_conversion': (context) => CurrencyConversionScreen(), // Rota para CurrencyConversionScreen
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Viagem Inteligente'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/timezone');
              },
              child: Text('Calcular Fuso Horário'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/currency_conversion');
              },
              child: Text('Converter Moeda'),
            ),
          ],
        ),
      ),
    );
  }
}
