import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weatherapp/AdditionalInfo.dart';
import 'package:weatherapp/hourlyForecast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:weatherapp/secrets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weatherapp/temp/weather.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  late Future<Map<String,dynamic>> weather;
  double temp = 0;


  Future<Position> getPosition() async {
  bool serviceEnabled;
  LocationPermission permission;
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return Future.error('Location permissions are denied');
    }
  }
  
  if (permission == LocationPermission.deniedForever) {
    return Future.error(
      'Location permissions are permanently denied, we cannot request permissions.');
  } 

  return await Geolocator.getCurrentPosition();
}


  Future<Map<String,dynamic>> getCurrentWeather() async {
    try{
      // Position position = await getPosition();
      // String uri = 'https://api.openweathermap.org/data/3.0/onecall?lat=${position.latitude}&lon=${position.longitude}&appid=$API';
      // final result = await http.get(Uri.parse(uri));
      // final data = jsonDecode(result.body);

      final data = jsonDecode(dummyData); // dummy data;

      if(data['cod'] != '200'){
        throw 'An Unexpected Occurred';
      }
      return data;
  } catch (e){
    throw e.toString();
    }
  }

  @override
  void initState(){
    super.initState();
    weather = getCurrentWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather App',style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        centerTitle: true,
        actions:[
          IconButton(
            onPressed: (){
              // on refresh
              setState(() {
                weather = getCurrentWeather();
              });
            }, 
            icon:const Icon(Icons.refresh),
            )
        ],
      ),
      body: FutureBuilder(
        future: weather,
        builder:(context,snapshot) {
          if(snapshot.connectionState == ConnectionState.waiting){
            return const Center(child: CircularProgressIndicator.adaptive());
          }
          if(snapshot.hasError){
            return Center(child: Text(snapshot.error.toString()));
          }
          final data = snapshot.data!;
          final currentWeatherData = data['list'][0];
          final currentTemperature = currentWeatherData['main']['temp'];
          final currentSky = currentWeatherData['weather'][0]['main'];
          final currentPressure = currentWeatherData['main']['pressure'];
          final currentWindSpeed = currentWeatherData['wind']['speed'];
          final currentHumidity = currentWeatherData['main']['humidity'];
          return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // main card
                SizedBox(
                  width: double.infinity,
                  child: Card(
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10,sigmaY: 10),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Text(
                                '$currentTemperature k',
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                                ),
                                const SizedBox(height: 16),
                                Icon(
                                  currentSky == 'Clouds' || currentSky == 'Rain'? Icons.cloud:Icons.sunny,
                                  size:64
                                  ),
                                const SizedBox(height: 16),
                                Text(
                                  currentSky,
                                  style: const TextStyle(
                                    fontSize: 20,
                                  ),
                                )
                            ],
                          ),
                        ),
                      ),
                    )
                  ),
                ),
        
                const SizedBox(height: 20),
        
                const Text(
                  'Weather Forecast',
                  style : TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  )
                ),
        
                const SizedBox(height: 8),

                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    itemCount: 5,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index){
                  
                      final hourlyForecast = data['list'][index+1];
                      final hourlySky = hourlyForecast['weather'][0]['main'];
                      final hourlyTemp = hourlyForecast['main']['temp'].toString();
                      final time = DateTime.parse(hourlyForecast['dt_txt']);
                      
                      return HourlyForecast(
                            time: DateFormat.j().format(time),
                            icon: hourlySky == 'Clouds' || hourlySky == 'Rain'?Icons.cloud:Icons.sunny,
                            temperature:hourlyTemp,
                          );
                    },
                  ),
                ),

                const SizedBox(height: 8),
                // weather forecast cards
                const Text(
                  'Additional Information',
                  style : TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  )
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children:[
                    AdditionalInfo(
                      icon: Icons.water_drop,
                      label:'Humidity',
                      value:currentHumidity.toString(),
                    ),
                    AdditionalInfo(
                      icon: Icons.air,
                      label:'Wind Speed',
                      value:currentWindSpeed.toString(),
                    ),
                    AdditionalInfo(
                      icon: Icons.beach_access,
                      label:'Pressure',
                      value:currentPressure.toString(),
                    ),
                  ]
                )
              ],
            ),
        );
        },
      ),
    );
  }
}

