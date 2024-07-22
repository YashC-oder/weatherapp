import 'package:flutter/material.dart';
class HourlyForecast extends StatelessWidget {
  final String time;
  final String temperature;
  final IconData icon;
  const HourlyForecast({
    super.key, 
    required this.time, 
    required this.temperature, 
    required this.icon
    });

  @override
  Widget build(BuildContext context) {
    return Card(
                elevation: 6,
                 child: Container(
                  width: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                      children: [
                      Text(
                        time,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                              ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                       ),
                            
                      const SizedBox(height: 8),
                      Icon(icon,size: 32,),
                       const SizedBox(height: 8),
                      Text(temperature),
          ],
        ),
      ),
    );
  }
}