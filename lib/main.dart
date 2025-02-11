import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CropPredictionScreen(),
    );
  }
}

class CropPredictionScreen extends StatefulWidget {
  @override
  _CropPredictionScreenState createState() => _CropPredictionScreenState();
}

class _CropPredictionScreenState extends State<CropPredictionScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nitrogenController = TextEditingController();
  final TextEditingController _phosphorousController = TextEditingController();
  final TextEditingController _potassiumController = TextEditingController();
  final TextEditingController _temperatureController = TextEditingController();
  final TextEditingController _humidityController = TextEditingController();
  final TextEditingController _pHController = TextEditingController();
  final TextEditingController _rainfallController = TextEditingController();

  String? predictedCrop;

  Future<void> getCropPrediction() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Collect user input
    final Map<String, dynamic> inputData = {
      "N": double.parse(_nitrogenController.text),
      "P": double.parse(_phosphorousController.text),
      "K": double.parse(_potassiumController.text),
      "temperature": double.parse(_temperatureController.text),
      "humidity": double.parse(_humidityController.text),
      "ph": double.parse(_pHController.text),
      "rainfall": double.parse(_rainfallController.text),
    };

    try {
      // Send input data to the backend API
      final response = await http.post(
        Uri.parse('http:..'), // Replace with your backend URL
        headers: {"Content-Type": "application/json","Accept": "application/json" },
        body: jsonEncode(inputData),
      );

      if (response.statusCode == 200) {
        setState(() {
          predictedCrop = jsonDecode(response.body)['prediction'];
        });
      }else {
        setState(() {
          predictedCrop = ('Error: ${response.statusCode}');
        });
      }
    } catch (e) {
      setState(() {
        predictedCrop = "Error: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Crop Prediction')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Input fields for each feature
              buildInputField("Nitrogen", _nitrogenController),
              buildInputField("Phosphorous", _phosphorousController),
              buildInputField("Potassium", _potassiumController),
              buildInputField("Temperature", _temperatureController),
              buildInputField("Humidity", _humidityController),
              buildInputField("pH", _pHController),
              buildInputField("Rainfall", _rainfallController),

              const SizedBox(height: 20),

              // Predict button
              ElevatedButton(
                onPressed: getCropPrediction,
                child: Text('Predict Crop'),
              ),

              const SizedBox(height: 20),

              // Display predicted crop
              if (predictedCrop != null)
                Text(
                  "Predicted Crop: $predictedCrop",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildInputField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        keyboardType: TextInputType.number,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          if (double.tryParse(value) == null) {
            return 'Please enter a valid number';
          }
          return null;
        },
      ),
    );
  }
}
