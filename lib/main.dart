
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  await Hive.initFlutter();
  await Hive.openBox('medications');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MedTimer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset('assets/animations/pills.json', width: 200),
            const SizedBox(height: 20),
            const Text(
              'MedTimer',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final TextEditingController nameController = TextEditingController();
  TimeOfDay? selectedTime;

  @override
  void initState() {
    super.initState();
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    const initSettings = InitializationSettings(android: android, iOS: ios);
    flutterLocalNotificationsPlugin.initialize(initSettings);
  }

  Future<void> scheduleNotification(String name, TimeOfDay time) async {
    final now = tz.TZDateTime.now(tz.local);
    final scheduleTime = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    ).add(const Duration(seconds: 5)); // Add 5 seconds for demo

    final androidDetails = AndroidNotificationDetails(
      'med_channel_id',
      'Medications',
      channelDescription: 'Channel for medication reminders',
      importance: Importance.max,
      priority: Priority.high,
    );

    final iosDetails = DarwinNotificationDetails();

    final notificationDetails =
        NotificationDetails(android: androidDetails, iOS: iosDetails);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      scheduleTime.hashCode,
      'Hora do medicamento',
      'É hora de tomar: $name',
      scheduleTime,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> addMedication() async {
    if (nameController.text.isEmpty || selectedTime == null) return;

    final medication = {
      'name': nameController.text,
      'time': selectedTime!.format(context),
    };

    final box = Hive.box('medications');
    final List meds = box.get('list', defaultValue: []);
    meds.add(medication);
    await box.put('list', meds);

    await scheduleNotification(nameController.text, selectedTime!);

    setState(() {
      nameController.clear();
      selectedTime = null;
    });
  }

  Future<void> fetchInfo(String name) async {
    final url = Uri.parse(
        'https://api.fda.gov/drug/label.json?search=openfda.generic_name:"$name"');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final result = data['results'][0];
        final info = [
          'Propósito: ${result['purpose']?[0] ?? 'N/A'}',
          'Indicação: ${result['indications_and_usage']?[0] ?? 'N/A'}',
          'Avisos: ${result['warnings']?[0] ?? 'N/A'}',
        ].join("\n\n");
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text('Informações sobre $name'),
            content: Text(info),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Fechar'),
              ),
            ],
          ),
        );
      } else {
        throw Exception('Erro ao buscar dados');
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Erro'),
          content: const Text('Não foi possível buscar informações.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fechar'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final box = Hive.box('medications');
    final List meds = box.get('list', defaultValue: []);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal.shade50,
        title: const Row(
          children: [
            Icon(Icons.medication, color: Colors.teal),
            SizedBox(width: 8),
            Text('MedTimer'),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Nome do medicamento',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                prefixIcon: const Icon(Icons.medication_liquid),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final time = await showTimePicker(
                          context: context, initialTime: TimeOfDay.now());
                      if (time != null) {
                        setState(() {
                          selectedTime = time;
                        });
                      }
                    },
                    icon: const Icon(Icons.timer),
                    label: Text(selectedTime == null
                        ? 'Escolher horário'
                        : selectedTime!.format(context)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: addMedication,
              icon: const Icon(Icons.add_alert),
              label: const Text('Salvar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: meds.length,
                itemBuilder: (_, i) {
                  final item = meds[i];
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.medication),
                      title: Text(item['name']),
                      subtitle: Text('Horário: ${item['time']}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.info_outline),
                        onPressed: () => fetchInfo(item['name']),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
