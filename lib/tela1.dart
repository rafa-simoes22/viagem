import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TimeZoneScreen extends StatefulWidget {
  @override
  _TimeZoneScreenState createState() => _TimeZoneScreenState();
}

class _TimeZoneScreenState extends State<TimeZoneScreen> {
  String selectedOriginCountry = 'United States';
  String selectedDestinationCountry = 'United States';
  String selectedOriginZoneName = 'America/New_York';
  String selectedDestinationZoneName = 'America/New_York';
  String estimatedArrivalTime = '00:00';
  double timezoneDifference = 0.0;

  Map<String, String> countryToZoneMap = {};

  Future<void> fetchCountries() async {
    final response = await http.get(
      Uri.parse('https://api.timezonedb.com/v2.1/list-time-zone?key=8PBVQRZKDBMY&format=json'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final zones = data['zones'];

      if (zones != null) {
        final countryZoneMap = Map.fromIterable(zones, key: (zone) => zone['countryName'] as String, value: (zone) => zone['zoneName'] as String);

        final sortedCountryZoneMap = Map.fromEntries(countryZoneMap.entries.toList()..sort((a, b) => a.key.compareTo(b.key)));

        setState(() {
          countryToZoneMap = sortedCountryZoneMap;
        });
      }
    }
  }

  Future<void> fetchTimezoneDifference() async {
    final responseOrigin = await http.get(
      Uri.parse('http://api.timezonedb.com/v2.1/get-time-zone?key=8PBVQRZKDBMY&format=json&by=zone&zone=$selectedOriginZoneName'),
    );

    if (responseOrigin.statusCode == 200) {
      final dataOrigin = jsonDecode(responseOrigin.body);
      final originOffset = dataOrigin['gmtOffset'];

      final responseDestination = await http.get(
        Uri.parse('http://api.timezonedb.com/v2.1/get-time-zone?key=8PBVQRZKDBMY&format=json&by=zone&zone=$selectedDestinationZoneName'),
      );

      if (responseDestination.statusCode == 200) {
        final dataDestination = jsonDecode(responseDestination.body);
        final destinationOffset = dataDestination['gmtOffset'];

        setState(() {
          final offsetDifference = (destinationOffset - originOffset) / 3600;
          timezoneDifference = double.parse(offsetDifference.toStringAsFixed(2));
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    fetchCountries();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Viagem Inteligente - Fuso Horário'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButton<String>(
              value: selectedOriginCountry,
              onChanged: (value) {
                setState(() {
                  selectedOriginCountry = value!;
                  selectedOriginZoneName = countryToZoneMap[value]!;
                });
              },
              items: countryToZoneMap.keys.map<DropdownMenuItem<String>>((String countryName) {
                return DropdownMenuItem<String>(
                  value: countryName,
                  child: Text(countryName),
                );
              }).toList(),
              hint: Text('País de Origem'),
            ),
            DropdownButton<String>(
              value: selectedDestinationCountry,
              onChanged: (value) {
                setState(() {
                  selectedDestinationCountry = value!;
                  selectedDestinationZoneName = countryToZoneMap[value]!;
                });
              },
              items: countryToZoneMap.keys.map<DropdownMenuItem<String>>((String countryName) {
                return DropdownMenuItem<String>(
                  value: countryName,
                  child: Text(countryName),
                );
              }).toList(),
              hint: Text('País de Destino'),
            ),
            TextField(
              onChanged: (value) {
                estimatedArrivalTime = value;
              },
              keyboardType: TextInputType.datetime,
              decoration: InputDecoration(labelText: 'Horário de Chegada Estimado (hh:mm)'),
            ),
            ElevatedButton(
              onPressed: () {
                fetchTimezoneDifference();
              },
              child: Text('Calcular Diferença de Fuso Horário'),
            ),
            Text('Diferença de Fuso Horário: $timezoneDifference horas'),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: TimeZoneScreen(),
  ));
}
