import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'side_menu.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';
import 'text_field_with_no_keyboard.dart';

class ApiResponse {
  final bool success;
  final String message;
  final dynamic result;

  ApiResponse({
    required this.success,
    required this.message,
    required this.result,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      success: json['success'],
      message: json['message'],
      result: json['result'],
    );
  }
}

class CheckLabelsScreen extends StatefulWidget {
  const CheckLabelsScreen({Key? key}) : super(key: key);

  @override
  _CheckLabelsScreenState createState() => _CheckLabelsScreenState();
}

class _CheckLabelsScreenState extends State<CheckLabelsScreen> {
  TextEditingController controlController = TextEditingController();
  TextEditingController partNumController = TextEditingController();
  //TextEditingController vendorPNController = TextEditingController();
  final FocusNode _controlFocusNode = FocusNode();
  final FocusNode _partNumFocusNode = FocusNode();
  final String warningText = "Warning";
  final String okayText = "Okay";
  final String apiUrl = 'http://192.168.111.69:8083/fetch/fetch';
  final String scanTypeControl = 'Please scan / type ControlNumer>>';
  final String scan1partNumber = 'Please scan/ type almost 1 PartNumber>>';
  final String typeJason = 'application/json';
  final String tokenFetchLoc = 'm0bmfbhfxihknx14q9gem2w9f7apacx9';
  final String pnvaluated = 'pnvaluated';
  final String pnreturned = 'pnreturned';
  final String validationSucc = 'Validation successful';
  final String badValidation = 'Bad validation';
  final String failedVal = 'Failed validation FALSE<<';
  final String nodataProvided = 'No data found for the provided ControlNum.';
  final String errorProvided = 'There was an error on request:';
  final String truee = 'True';
  final String falsee = 'False';
  final String validationSucs = "Validation successful";
  AudioPlayer audioPlayer = AudioPlayer();
  bool keyboardOpened = false;

  List<List<String>> tableData = [];
  final String audioAsset = "assets/erroralert.wav";

  void _playErrorSound() async {
    try {
      ByteData data = await rootBundle.load(audioAsset);
      List<int> bytes = data.buffer.asUint8List();
      Uint8List uint8List = Uint8List.fromList(bytes);

      // Usa BytesSource en lugar de Uint8List
      BytesSource bytesSource = BytesSource(uint8List);

      await audioPlayer.play(bytesSource);

      Vibration.vibrate(duration: 1000);
    } catch (e) {}
  }

  void _stopErrorSound() {
    audioPlayer.stop();

    Vibration.cancel();
    FocusScope.of(context).requestFocus(_controlFocusNode);
    Future.delayed(Duration(milliseconds: 0), () {
      textInput.invokeMethod('TextInput.hide');
    });
  }

  void _showDialogWithSound(String message) async {
    // Muestra el cuadro de diálogo con el mensaje
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            warningText,
            style: TextStyle(
              color: Colors.white, // Color del texto
              fontWeight: FontWeight.bold, // Texto en negritas
            ),
          ),
          content: Text(
            message,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16, // Color del texto
            ),
          ),
          backgroundColor: Color.fromARGB(173, 10, 78, 134), // Color de fondo
          actions: [
            TextButton(
              onPressed: () {
                // Detiene el sonido cuando el usuario hace clic en "Aceptar"
                _stopErrorSound();
                Navigator.of(context).pop(); // Cierra el cuadro de diálogo
              },
              child: Text(
                okayText,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16, // Color del texto del botón
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDataTable() {
    return Container(
      width: 800, // Ajusta el ancho de la caja según tus necesidades
      height: 350, // Ajusta la altura de la caja según tus necesidades
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 1, // Solo habrá una fila
        itemBuilder: (BuildContext context, int index) {
          return SingleChildScrollView(
            child: DataTable(
              columnSpacing: 10,
              dataRowHeight: 30,
              headingRowHeight: 30,
              columns: const [
                DataColumn(
                  label: Text(
                    'Control',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'PN Valuated',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'PN Returned',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Validation',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 8,
                    ),
                  ),
                ),
              ],
              rows: tableData.map((rowData) {
                return DataRow(
                  cells: rowData.map((data) {
                    return DataCell(
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          data,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Check Labels',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      drawer: SideMenu(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: MediaQuery.of(context).size.height,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/backgroundd.png'),
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const SizedBox(height: 1),
                    /*Transform.scale(
                      scale: 0.7,
                      child: Image.asset(
                        'assets/rljoneslogo.png',
                        fit: BoxFit.cover,
                        height: 60,
                        width: 380,
                      ),
                    ),*/
                    const SizedBox(height: 2),
                    Container(
                      width: 300,
                      height: 50,
                      child: TextField(
                        // keyboardType: TextInputType.none,
                        controller: controlController,
                        focusNode: _controlFocusNode,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Control',
                          labelStyle: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          border: OutlineInputBorder(),
                        ),
                        onTap: () {
                          Future.delayed(Duration(milliseconds: 0), () {
                            textInput.invokeMethod('TextInput.hide');
                          });
                        },
                        onSubmitted: (value) {
                          moveToPartNumber();
                          Future.delayed(Duration(milliseconds: 0), () {
                            textInput.invokeMethod('TextInput.hide');
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      width: 300,
                      height: 50,
                      child: TextField(
                        //keyboardType: TextInputType.none,
                        controller: partNumController,
                        focusNode: _partNumFocusNode,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'PartNumber',
                          labelStyle: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          border: OutlineInputBorder(),
                        ),
                        onTap: () {
                          Future.delayed(Duration(milliseconds: 0), () {
                            textInput.invokeMethod('TextInput.hide');
                          });
                        },
                        onSubmitted: (value) {
                          sendRequest();
                        },
                      ),
                    ),
                    const SizedBox(height: 5),
                    /*Container(
                      width: 300,
                      height: 50,
                      child: TextField(
                        // keyboardType: TextInputType.none,
                        controller: vendorPNController,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'VendorPN',
                          labelStyle: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          border: OutlineInputBorder(),
                        ),
                        onSubmitted: (value) {
                          sendRequest();
                        },
                        
                      ),
                    ),*/
                    const SizedBox(height: 5),
                    Container(
                      width: 300,
                      height: 35,
                      child: ElevatedButton(
                        onPressed: sendRequest,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(95, 21, 241, 131),
                          minimumSize: const Size(double.infinity, 48),
                        ),
                        child: const Text(
                          'Validate',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    _buildDataTable(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static const MethodChannel textInput = OptionalMethodChannel(
    'flutter/textinput',
    JSONMethodCodec(),
  );

  void moveToPartNumber() {
    FocusScope.of(context).requestFocus(_partNumFocusNode);
  }

  void sendRequest() async {
    // Obtener los valores de los controladores
    String partNum = partNumController.text;
    //String partDescription = vendorPNController.text;
    String controlNum = controlController.text;
    partNumController.clear();
    // vendorPNController.clear();
    controlController.clear();
    FocusScope.of(context).requestFocus(_controlFocusNode);
    Future.delayed(Duration(milliseconds: 0), () {
      textInput.invokeMethod('TextInput.hide');
    });

    if (controlNum.isEmpty) {
      _showDialogWithSound(scanTypeControl);
    }
    // Validar que al menos uno de los campos PartNum o PartDescription no esté vacío
    if (partNum.isEmpty /*&& partDescription.isEmpty*/) {
      // Mostrar un mensaje indicando que se debe agregar al menos uno
      _showDialogWithSound(scan1partNumber);
      // Detener la ejecución si la validación falla
    }

    // Construir el mapa de datos para la solicitud
    Map<String, dynamic> data = {
      'itemDetailID': 0,
      'PartDescription': partNum,
      'PartNum': partNum,
      'ControlNum': controlNum,
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: json.encode(data),
        headers: {
          'Content-Type': typeJason,
          'Authorization': tokenFetchLoc,
        },
      );

      final Map<String, dynamic> jsonResponse2 = json.decode(response.body);
      final ApiResponse apiResponse = ApiResponse.fromJson(jsonResponse2);

      String message = apiResponse.message;
      String pnValuated = apiResponse.result[pnvaluated];
      String pnReturned = apiResponse.result[pnreturned];
      if (message.contains(validationSucc)) {
        // Extrae el mensaje específico si es necesario

        // Verde para éxito

        updateTable(message, pnValuated, pnReturned, controlNum);
      } else if (message.contains(badValidation)) {
        // Reproduce el sonido al mostrar el diálogo
        _playErrorSound();
        _controlFocusNode.unfocus();
        _showDialogWithSound(failedVal);

        updateTable(message, pnValuated, pnReturned, controlNum);
      } else if (message.contains(nodataProvided)) {
        // Extrae el mensaje específico si es necesario
        // Reproduce el sonido al mostrar el diálogo
        _playErrorSound();
        _controlFocusNode.unfocus();
        _showDialogWithSound(nodataProvided);
        // Rojo para error
      }

      // Actualizar la tabla
    } catch (error) {
      // Reproduce el sonido al mostrar el diálogo
      _playErrorSound();
      _controlFocusNode.unfocus();
      _showDialogWithSound('$errorProvided $error');
    }
  }

  @override
  void initState() {
    super.initState();
    _controlFocusNode.addListener(() {});
    _partNumFocusNode.addListener(() {});
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      // Darle el foco al campo de texto cuando la pantalla esté completamente construida
      FocusScope.of(context).requestFocus(_controlFocusNode);
      Future.delayed(Duration(milliseconds: 0), () {
        textInput.invokeMethod('TextInput.hide');
      });
    });
  }

  void updateTable(
      String message, String pnValuated, String pnReturned, String control_) {
    if (pnValuated.isNotEmpty && pnReturned.isNotEmpty) {
      // Decodificar el jsonResponse y obtener los valores necesarios

      String control = control_;

      bool controlExists = tableData.any(
          (row) => row[0].trim().toLowerCase() == control.trim().toLowerCase());

      if (controlExists) {
        // Elimina el control existente

        setState(() {
          tableData.removeWhere((row) => row[0] == control);
        });
      }

      if (message.contains(validationSucs)) {
        setState(() {
          tableData.insert(0, [control, pnValuated, pnReturned, truee]);
        });
      } else {
        setState(() {
          tableData.insert(0, [control, pnValuated, pnReturned, falsee]);
        });
      }
    }
  }
}
