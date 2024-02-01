import 'package:flutter/material.dart';
import 'indata.dart';
import 'checklabels.dart';
import 'dart:io';
import 'login.dart';
import 'usermangament.dart';
import 'side_menu.dart';

void main() {
  runApp(const MaterialApp(
    home: loginScreen(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 95, 112, 148)),
        useMaterial3: true,
      ),
      home: Builder(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text(
              'Main Menu',
              style: TextStyle(
                fontSize:
                    18, // Ajusta el tamaño de la fuente según tus necesidades
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          drawer: SideMenu(), // Agrega SideMenu como un Drawer
          body: const MyHomePage(title: 'Sub inventory RL Jones App'),
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          margin: EdgeInsets.zero,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/backgroundd.png'),
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Hello ${UserManager.userName}',
                    style: TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(173, 10, 78, 134),
                    ),
                  ),
                ),
              ),
              Center(
                child: Container(
                  width: 360, // Ancho deseado para el logo
                  child: Transform.scale(
                    scale: 0.9, // Ajusta este valor según tus necesidades
                    child: Image.asset(
                      'assets/rljoneslogo.png',
                      fit: BoxFit.cover,
                      height: 95,
                      width: 380,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: Container(
                  width: 280, // Ancho deseado para los botones
                  child: _buildCard(
                    Color.fromARGB(31, 52, 226, 58),
                    'In data sys',
                    'assets/indata.png',
                    () => _navigateToInDataScreen(context),
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Center(
                child: Container(
                  width: 280, // Ancho deseado para los botones
                  child: _buildCard(
                    Colors.blue,
                    'Check labels',
                    'assets/chekdata.png',
                    () => _navigateToChekLabelsScreen(context),
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Center(
                child: Container(
                  width: 280, // Ancho deseado para los botones
                  child: _buildCard(
                    const Color.fromARGB(255, 238, 75, 64),
                    'Exit app',
                    'assets/exitt.png',
                    () => _navigateToExitApp(context),
                  ),
                ),
              ),
              const SizedBox(
                  height: 10), // Ajusta este valor según sea necesario
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToInDataScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const InDataScreen()),
    );
  }

  void _navigateToChekLabelsScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CheckLabelsScreen()),
    );
  }

  void _navigateToExitApp(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color.fromARGB(173, 10, 78, 134),
          title: Text(
            "Confirmation exit",
            style: TextStyle(
              color: Colors.white, // Color blanco
              fontWeight: FontWeight.bold, // Negrita
            ),
          ),
          content: Text(
            "Are you sure that do you want to exit from App?",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16, // Color blanco
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el cuadro de diálogo
              },
              child: Text(
                "Cancel",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16, // Color blanco
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el cuadro de diálogo
                // Cierra la aplicación
                exit(0);
              },
              child: Text(
                "Out App",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16, // Color blanco
                  fontWeight: FontWeight.bold, // Negrita
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCard(
      Color cardColor, String cardTitle, String imagePath, Function()? onTap) {
    // Tamaño deseado en pulgadas
    double cardWidthInches = 2;
    double cardHeightInches = .7;
    double iconSizeInches = 0.18;

    // Convertir pulgadas a píxeles basado en la densidad de píxeles
    double cardWidth = cardWidthInches *
        160.0; // 160 es la densidad de píxeles para pantallas mdpi
    double cardHeight = cardHeightInches * 160.0;
    double iconSize = iconSizeInches * 160.0;

    // Agrega opacidad al color de la tarjeta
    Color cardColorWithOpacity = cardColor.withOpacity(0.38);

    return InkWell(
      onTap: onTap,
      child: Card(
        color: cardColorWithOpacity,
        child: SizedBox(
          width: cardWidth,
          height: cardHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                alignment: Alignment.centerLeft,
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  height: iconSize,
                  width: iconSize,
                ),
              ),
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      cardTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22.0,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
