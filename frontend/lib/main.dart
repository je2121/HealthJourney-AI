import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; 
import 'package:device_preview/device_preview.dart'; 
import 'package:http/http.dart' as http; 

void main() {
  runApp(
    DevicePreview(
      enabled: !kReleaseMode, 
      builder: (context) => const HealthPredictApp(),
    ),
  );
}

class HealthPredictApp extends StatelessWidget {
  const HealthPredictApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: const Color(0xFF4F46E5),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4F46E5),
          primary: const Color(0xFF4F46E5),
          secondary: const Color(0xFF7C3AED),
        ),
        textTheme: GoogleFonts.plusJakartaSansTextTheme(),
      ),
      home: const SplashScreen(),
    );
  }
}

// ========================================================
// 📱 SCREEN 1: SPLASH SCREEN / OPENING
// ========================================================
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  void _navigateToHome() async {
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainNavigationHolder()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.analytics_rounded,
                size: 80,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "HealthJourney",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "AI Predictive Analytics Engine",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 48),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ========================================================
// 🗂️ HOLDER: NAVIGASI BAWAH (BOTTOM NAVIGATION)
// ========================================================
class MainNavigationHolder extends StatefulWidget {
  const MainNavigationHolder({super.key});

  @override
  State<MainNavigationHolder> createState() => _MainNavigationHolderState();
}

class _MainNavigationHolderState extends State<MainNavigationHolder> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const ProfileDummyScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: const Color(0xFF4F46E5),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_customize_rounded),
            label: 'Analytics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_pin_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// ========================================================
// 📊 SCREEN 2: DASHBOARD FORM DATA
// ========================================================
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _ageController = TextEditingController(text: "17");
  final TextEditingController _sleepController = TextEditingController(text: "8.0");
  final TextEditingController _activityController = TextEditingController(text: "80");
  final TextEditingController _weightController = TextEditingController(text: "65.0");
  final TextEditingController _heightController = TextEditingController(text: "175.0");
  final TextEditingController _heartRateController = TextEditingController(text: "70");
  final TextEditingController _stepsController = TextEditingController(text: "8000");

  int _selectedGender = 0; // 0 = Male, 1 = Female
  int _selectedSleepDisorder = 0; // 0 = None, 1 = Insomnia, 2 = Sleep Apnea

  bool isLoading = false;

  void predictHealth() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
    });

    final url = Uri.parse('http://127.0.0.1:8000/predict');

    // Sinkronisasi penuh dengan Pydantic di Python API terbaru
    final Map<String, dynamic> payload = {
      'gender_encoded': _selectedGender,
      'age': double.tryParse(_ageController.text) ?? 25.0,
      'sleep_duration': double.tryParse(_sleepController.text) ?? 7.0,
      'physical_activity_level': double.tryParse(_activityController.text) ?? 45.0,
      'weight': double.tryParse(_weightController.text) ?? 70.0,
      'height': double.tryParse(_heightController.text) ?? 170.0,
      'heart_rate': double.tryParse(_heartRateController.text) ?? 72.0,
      'daily_steps': double.tryParse(_stepsController.text) ?? 6000.0,
      'sleep_disorder_encoded': _selectedSleepDisorder,
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        
        if (!mounted) return;

        // Ekstraksi data aman dengan Null-Safety & Num Parsing
        double parsedSleepQuality = (data['sleep_quality'] as num?)?.toDouble() ?? 0.0;
        double parsedStressLevel = (data['stress_level'] as num?)?.toDouble() ?? 0.0;
        double calculatedBmi = (data['bmi_score'] as num?)?.toDouble() ?? 0.0;
        String bmiCategory = data['bmi_category']?.toString() ?? "Normal";

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(
              bmiScore: calculatedBmi.toStringAsFixed(1),
              bmiCategory: bmiCategory,
              sleepQuality: parsedSleepQuality,
              stressLevel: parsedStressLevel,
            ),
          ),
        );
      } else {
        _showErrorSnackBar("Terjadi kesalahan pada server Python (Status: ${response.statusCode})");
      }
    } catch (e) {
      _showErrorSnackBar("Gagal terhubung ke server Python. Pastikan FastAPI aktif!");
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(125),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              // 🌟 PERBAIKAN: Menggunakan 'child', bukan 'widget' agar tidak error kompilasi
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "HealthJourney AI",
                        style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const Icon(Icons.bolt, color: Colors.amber, size: 24)
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Sinkronisasi langsung dengan Model XGBoost Anda.",
                    style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Input Biometric Data",
                style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
              ),
              const SizedBox(height: 14),
              
              _buildDropdownField(
                label: "Gender",
                value: _selectedGender,
                icon: Icons.wc_rounded,
                items: const [
                  DropdownMenuItem(value: 0, child: Text("Male")),
                  DropdownMenuItem(value: 1, child: Text("Female")),
                ],
                onChanged: (val) => setState(() => _selectedGender = val!),
              ),

              _buildInputField(label: "Age (Tahun)", controller: _ageController, icon: Icons.cake_outlined),
              _buildInputField(label: "Sleep Duration (Jam)", controller: _sleepController, icon: Icons.bedtime_outlined),
              _buildInputField(label: "Physical Activity Level (Menit)", controller: _activityController, icon: Icons.fitness_center_outlined),
              _buildInputField(label: "Weight (Kg)", controller: _weightController, icon: Icons.monitor_weight_outlined),
              _buildInputField(label: "Height (Cm)", controller: _heightController, icon: Icons.height_rounded),
              _buildInputField(label: "Heart Rate (BPM)", controller: _heartRateController, icon: Icons.favorite_border_rounded),
              _buildInputField(label: "Daily Steps (Langkah)", controller: _stepsController, icon: Icons.directions_walk_rounded),
              
              _buildDropdownField(
                label: "Sleep Disorder History",
                value: _selectedSleepDisorder,
                icon: Icons.gpp_maybe_outlined,
                items: const [
                  DropdownMenuItem(value: 0, child: Text("None")),
                  DropdownMenuItem(value: 1, child: Text("Insomnia")),
                  DropdownMenuItem(value: 2, child: Text("Sleep Apnea")),
                ],
                onChanged: (val) => setState(() => _selectedSleepDisorder = val!),
              ),

              const SizedBox(height: 24),
              
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: isLoading ? null : predictHealth,
                  style: ElevatedButton.styleFrom(padding: EdgeInsets.zero, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)]),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Container(
                      alignment: Alignment.center,
                      child: isLoading
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                          : Text("Run AI Diagnostic", style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({required String label, required TextEditingController controller, required IconData icon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.plusJakartaSans(color: Colors.black45, fontSize: 13),
          prefixIcon: Icon(icon, color: const Color(0xFF64748B), size: 20),
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.2)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 1.8)),
        ),
        validator: (value) => value == null || value.isEmpty ? "$label tidak boleh kosong" : null,
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required int value,
    required IconData icon,
    required List<DropdownMenuItem<int>> items,
    required ValueChanged<int?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: DropdownButtonFormField<int>(
        value: value,
        items: items,
        onChanged: onChanged,
        style: GoogleFonts.plusJakartaSans(fontSize: 14, color: Colors.black87),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.plusJakartaSans(color: Colors.black45, fontSize: 13),
          prefixIcon: Icon(icon, color: const Color(0xFF64748B), size: 20),
          contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.2)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 1.8)),
        ),
      ),
    );
  }
}

// ========================================================
// 🎯 SCREEN 3: DIAGNOSTIC RESULT SCREEN
// ========================================================
class ResultScreen extends StatelessWidget {
  final String bmiScore;
  final String bmiCategory;
  final double sleepQuality;
  final double stressLevel;

  const ResultScreen({
    super.key,
    required this.bmiScore,
    required this.bmiCategory,
    required this.sleepQuality,
    required this.stressLevel,
  });

  @override
  Widget build(BuildContext context) {
    String stressDesc = stressLevel >= 5.0 ? "High Stress" : "Normal Level";

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text("Diagnostic Results", style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "AI Prediction Summary",
              style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _buildResultCard(
                    title: "Sleep Quality",
                    value: "${(sleepQuality * 10).toStringAsFixed(0)}%",
                    // 🌟 PERBAIKAN DESIMAL: Membatasi agar tidak muncul angka desimal super panjang
                    subtitle: "${sleepQuality.toStringAsFixed(1)} / 10 score",
                    color: const Color(0xFF3B82F6),
                    icon: Icons.dark_mode_rounded,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _buildResultCard(
                    title: "Stress Level",
                    value: stressLevel.toStringAsFixed(1),
                    subtitle: stressDesc,
                    color: stressLevel >= 5.0 ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                    icon: Icons.sentiment_very_dissatisfied_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Body Mass Index (BMI)", style: GoogleFonts.plusJakartaSans(color: Colors.grey, fontSize: 13)),
                      const SizedBox(height: 4),
                      Text(bmiScore, style: GoogleFonts.plusJakartaSans(fontSize: 28, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Chip(
                    label: Text(bmiCategory),
                    backgroundColor: const Color(0xFF10B981).withOpacity(0.12),
                    labelStyle: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold),
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  )
                ],
              ),
            ),
            
            const SizedBox(height: 28),
            Text(
              "Smart Recommendations",
              style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
            ),
            const SizedBox(height: 12),
            _buildRecommendationCard(
              icon: Icons.lightbulb_outline_rounded,
              color: Colors.amber,
              text: stressLevel > 5 
                ? "Stress Level Anda terpantau tinggi. Kurangi kafein dan cobalah meditasi pernapasan 5 menit sebelum tidur."
                : "Tingkat stres Anda normal. Pertahankan pola aktivitas fisik Anda untuk menjaga kebugaran hormon.",
            ),
            _buildRecommendationCard(
              icon: Icons.bed_outlined,
              color: Colors.blue,
              text: sleepQuality < 6.0 
                ? "Kualitas tidur Anda di bawah batas ideal. Atur jadwal tidur konstan dan hindari melihat layar HP 30 menit sebelum tidur."
                : "Kualitas istirahat Anda sudah sangat baik. Menjaga durasi ini terbukti mengoptimalkan daya kerja otak harian.",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard({required String title, required String value, required String subtitle, required Color color, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.12), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 14),
          Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 13, color: Colors.black54)),
          const SizedBox(height: 2),
          Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 26, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 2),
          Text(subtitle, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: Colors.black45)),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard({required IconData icon, required Color color, required String text}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 14),
          Expanded(
            child: Text(text, style: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF475569), height: 1.4)),
          )
        ],
      ),
    );
  }
}

// ========================================================
// 👤 SCREEN 4: PROFILE DUMMY
// ========================================================
class ProfileDummyScreen extends StatelessWidget {
  const ProfileDummyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 45,
              backgroundColor: Color(0xFF4F46E5),
              child: Icon(Icons.person, size: 45, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text("User Diagnostics Profile", style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text("Patient ID: #129402", style: GoogleFonts.plusJakartaSans(fontSize: 13, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}