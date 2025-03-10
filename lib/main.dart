import 'dart:io';
import 'dart:math'; // for min() function
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  File? galleryPhoto;
  bool isDarkMode = false;
  double? originalWidth;
  double? originalHeight;

  @override
  void initState() {
    super.initState();
    _retrieveThemePref();
  }

  Future<void> _retrieveThemePref() async {
    final retrievePref = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = retrievePref.getBool('isDarkMode') ?? false;
    });
  }

  Future<void> _storeThemePref(bool value) async {
    final storePref = await SharedPreferences.getInstance();
    storePref.setBool('isDarkMode', value);
  }

  // to pick an image and get size
  Future<void> _selectPhoto() async {
    final picker = ImagePicker();
    final pickedPhoto = await picker.pickImage(source: ImageSource.gallery);
    if (pickedPhoto != null) {
      File file = File(pickedPhoto.path);
      final bytes = await file.readAsBytes();
      final decoded = await decodeImageFromList(bytes);
      setState(() {
        galleryPhoto = file;
        originalWidth = decoded.width.toDouble();
        originalHeight = decoded.height.toDouble();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // display photo based on natural size, limit max size to 400 (if statement)
    const double maxSize = 400;
    double? displayWidth;
    double? displayHeight;

    if (originalWidth != null && originalHeight != null) {
      double scaleFactor = min(maxSize / originalWidth!, maxSize / originalHeight!);
      displayWidth = originalWidth! * scaleFactor;
      displayHeight = originalHeight! * scaleFactor;
    }

    return MaterialApp(
      title: 'CIT 238 Unit 4 Assignment - Segura',
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.light(
          primary: const Color.fromARGB(255, 6, 163, 90),
          surface: Colors.white,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color.fromARGB(255, 6, 163, 90),
          titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 6, 163, 90),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.black, fontSize: 16),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        colorScheme: ColorScheme.dark(
          primary: const Color.fromARGB(255, 61, 61, 61),
          surface: Colors.black,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color.fromARGB(255, 61, 61, 61),
          titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 61, 61, 61),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('CIT 238 UNIT 4 ASSIGNMENT'),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ElevatedButton(
                  onPressed: _selectPhoto,
                  child: const Text('Pick Photo from Gallery'),
                ),
                const SizedBox(height: 30),
                galleryPhoto != null
                  ? Container(
                      width: displayWidth, 
                      height: displayHeight,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.hardEdge,
                      child: Image.file(
                        galleryPhoto!,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Text(
                      'No photo selected',
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black,
                        fontSize: 16,
                      ),
                    ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Dark Mode',
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black,
                        fontSize: 16,
                      ),
                    ),
                    Switch(
                      value: isDarkMode,
                      onChanged: (bool value) {
                        setState(() {
                          isDarkMode = value;
                          _storeThemePref(value);
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
