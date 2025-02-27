import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class BMICalculatorScreen extends StatefulWidget {
  const BMICalculatorScreen({super.key});

  @override
  State<BMICalculatorScreen> createState() => _BMICalculatorScreenState();
}

class _BMICalculatorScreenState extends State<BMICalculatorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  String _bmiResult = '';
  String _aiAdvice = '';
  bool _isLoading = false;

  // Ganti dengan API key Gemini Anda
  final model = GenerativeModel(
    model: 'gemini-pro',
    apiKey: 'AIzaSyCpr21sjPL8aE6V-DxarU3HQt0WNH1NEME',
  );

  Future<void> _calculateBMI() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      double weight = double.parse(_weightController.text);
      double height =
          double.parse(_heightController.text) / 100; // Convert cm to m
      double bmi = weight / (height * height);

      String category = '';
      if (bmi < 18.5) {
        category = 'Kekurangan Berat Badan';
      } else if (bmi < 25) {
        category = 'Normal';
      } else if (bmi < 30) {
        category = 'Kelebihan Berat Badan';
      } else {
        category = 'Obesitas';
      }

      setState(() {
        _bmiResult = 'BMI: ${bmi.toStringAsFixed(1)} ($category)';
      });

      // Generate saran dari Gemini AI
      try {
        final prompt = '''
          Berikan saran kesehatan untuk seseorang dengan:
          - BMI: ${bmi.toStringAsFixed(1)}
          - Kategori: $category
          
          Berikan saran spesifik tentang:
          1. Pola makan yang disarankan
          2. Jenis olahraga yang cocok
          3. Target berat badan ideal
          
          Berikan jawaban dalam bahasa Indonesia yang mudah dipahami.
        ''';

        final content = [Content.text(prompt)];
        final response = await model.generateContent(content);

        setState(() {
          _aiAdvice =
              response.text ?? 'Maaf, tidak dapat menghasilkan saran saat ini.';
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          _aiAdvice = 'Terjadi kesalahan saat memuat saran: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kalkulator BMI'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _heightController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Tinggi Badan (cm)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Mohon masukkan tinggi badan';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _weightController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Berat Badan (kg)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Mohon masukkan berat badan';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _calculateBMI,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Hitung BMI'),
                ),
                if (_bmiResult.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _bmiResult,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Saran dari AI:',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(_aiAdvice),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }
}
