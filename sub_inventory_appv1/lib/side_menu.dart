import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sub_inventory_appv1/usermangament.dart';

import 'checklabels.dart';
import 'indata.dart';
import 'main.dart';

class SideMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 10, 78, 134),
            ),
            child: Container(
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 40,
                  ),
                  SizedBox(width: 10),
                  Text(
                    'User: ${UserManager.userName}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.menu),
            title: Text(
              'Main Menu',
              style: TextStyle(
                fontSize: 18, // Ajusta el tamaño del texto
                color: Color.fromARGB(
                    255, 12, 11, 11), // Ajusta el color del texto
                fontWeight: FontWeight.bold, // Agrega negrita si es necesario
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MyApp()),
              );
            },
          ),
          ListTile(
            leading: Image.asset(
              'assets/indata.png',
              width: 22,
              height: 22,
            ),
            title: Text(
              'In Data',
              style: TextStyle(
                fontSize: 18,
                color: Color.fromARGB(255, 12, 11, 11),
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => InDataScreen()),
              );
            },
          ),
          ListTile(
            leading: Image.asset(
              'assets/chekdata.png',
              width: 22,
              height: 22,
            ),
            title: Text(
              'Check Labels',
              style: TextStyle(
                fontSize: 18,
                color: Color.fromARGB(255, 12, 11, 11),
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CheckLabelsScreen()),
              );
            },
          ),
          ListTile(
            leading: Image.asset(
              'assets/exitt.png',
              width: 22,
              height: 22,
            ),
            title: Text(
              'Exit App',
              style: TextStyle(
                fontSize: 18,
                color: Color.fromARGB(255, 12, 11, 11),
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () {
              // Muestra un cuadro de diálogo de confirmación antes de salir
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    backgroundColor: Color.fromARGB(173, 10, 78, 134),
                    title: Text(
                      "Confirmation exit",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    content: Text(
                      "Are you sure that do you want to exit from App?",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context)
                              .pop(); // Cierra el cuadro de diálogo
                        },
                        child: Text(
                          "Cancel",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context)
                              .pop(); // Cierra el cuadro de diálogo
                          // Cierra la aplicación
                          exit(0);
                        },
                        child: Text(
                          "Out App",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
          // Agregar más opciones según sea necesario
          SizedBox(height: 60), // Espacio entre las opciones y la leyenda
          Container(
            alignment: Alignment.bottomCenter,
            padding: EdgeInsets.all(16),
            child: Text(
              'RL Jones Customs House Brokers®\nDev by Noel Cazares\nVersion 0.9.3.2\nLastUpdate 1/31/2024',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center, // Alinear el texto al centro
            ),
          ),
        ],
      ),
    );
  }
}
