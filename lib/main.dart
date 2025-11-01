import 'package:flutter/material.dart';
import 'package:p007/form.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const Registration(),
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        scaffoldBackgroundColor: const Color.fromARGB(255, 43, 50, 38),
        colorScheme: const ColorScheme.dark(
          primary: Color.fromARGB(255, 135, 169, 107), // Sage green
          secondary: Color.fromARGB(255, 180, 200, 165),
          surface: Color.fromARGB(255, 55, 64, 50),
        ),
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: <TargetPlatform, PageTransitionsBuilder>{
            TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
            TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
          },
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: Color.fromARGB(255, 135, 169, 107), // Sage green
          iconTheme: IconThemeData(color: Color.fromARGB(255, 237, 242, 230)),
          titleTextStyle: TextStyle(
            color: Color.fromARGB(255, 237, 242, 230),
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: Color.fromARGB(255, 68, 78, 62),
          contentTextStyle: TextStyle(
            color: Color.fromARGB(255, 237, 242, 230),
            fontWeight: FontWeight.w600,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color.fromARGB(255, 68, 78, 62),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: Color.fromARGB(255, 107, 123, 90),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: Color.fromARGB(255, 135, 169, 107), // Sage green
              width: 1.8,
            ),
          ),
          labelStyle: const TextStyle(
            color: Color.fromARGB(255, 237, 242, 230),
          ),
          hintStyle: const TextStyle(color: Color.fromARGB(255, 180, 200, 165)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(
              255,
              135,
              169,
              107,
            ), // Sage green
            foregroundColor: const Color.fromARGB(255, 237, 242, 230),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            textStyle: const TextStyle(fontWeight: FontWeight.w700),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color.fromARGB(255, 237, 242, 230),
            side: const BorderSide(
              color: Color.fromARGB(200, 135, 169, 107),
            ), // Sage green
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            textStyle: const TextStyle(fontWeight: FontWeight.w600),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
        ),
        checkboxTheme: CheckboxThemeData(
          fillColor: WidgetStateProperty.resolveWith<Color?>(
            (Set<WidgetState> states) => states.contains(WidgetState.selected)
                ? const Color.fromARGB(255, 135, 169, 107) // Sage green
                : const Color.fromARGB(255, 107, 123, 90),
          ),
          checkColor: WidgetStateProperty.all<Color>(
            const Color.fromARGB(255, 237, 242, 230),
          ),
        ),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.all<Color>(
            const Color.fromARGB(255, 237, 242, 230),
          ),
          trackColor: WidgetStateProperty.resolveWith<Color>(
            (Set<WidgetState> states) => states.contains(WidgetState.selected)
                ? const Color.fromARGB(200, 135, 169, 107) // Sage green
                : const Color.fromARGB(255, 107, 123, 90),
          ),
        ),
        sliderTheme: const SliderThemeData(
          trackHeight: 4,
          overlayShape: RoundSliderOverlayShape(overlayRadius: 18),
          thumbShape: RoundSliderThumbShape(enabledThumbRadius: 10),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: const Color.fromARGB(200, 68, 78, 62),
          selectedColor: const Color.fromARGB(150, 135, 169, 107), // Sage green
          labelStyle: const TextStyle(
            color: Color.fromARGB(255, 237, 242, 230),
            fontWeight: FontWeight.w600,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          secondaryLabelStyle: const TextStyle(
            color: Color.fromARGB(255, 237, 242, 230),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          side: const BorderSide(color: Color.fromARGB(255, 107, 123, 90)),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Color.fromARGB(255, 237, 242, 230)),
          bodyMedium: TextStyle(color: Color.fromARGB(255, 237, 242, 230)),
          bodySmall: TextStyle(color: Color.fromARGB(255, 180, 200, 165)),
        ),
      ),
    );
  }
}
