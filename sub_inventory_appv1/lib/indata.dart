import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'usermangament.dart';
import 'side_menu.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

class InDataScreen extends StatefulWidget {
  const InDataScreen({Key? key}) : super(key: key);

  @override
  _InDataScreenState createState() => _InDataScreenState();
}

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

class _InDataScreenState extends State<InDataScreen> {
  List<String> locationOptions = [];
  List<dynamic> apiLocations = [];
  String? selectedOption;
  final String audioAsset = "assets/erroralert.wav";
  final String alertDialog = "Warning";
  final String okayMessage = "Okay";
  final String selectLocationFirst = "Please select location first<<";
  //Change for your own API Key
  final String tokenAddControl = 'testkey';
  //Change for your API route
  final String routeInclute = 'http://1.1.1.1:1111/fetch/include';
  final String includeHasBeenGood = 'Material has been included successfully';
   //Change for your own API Key
  final String tokenCount = 'testkey';
  //Change for your API route
  final String routeCountControls =
      'http://1.1.1.1:1111/fetch/countcontrols';
  final String countControlsFetch = 'Count controls fetching';
  final String countWord = 'count';
  final String typeJason = 'application/json';
  //Change for your own API Key
  final String tokenFetchLoc = 'testkey';
  //Change for your API route
  final String locationRoute = 'http://1.1.1.1:1111/fetch/locations';
  final String titleScreen = 'InData Screen';
  final String selectLoc = 'Select location';
  final String locationname = 'locationName';
  final String subLocationText = 'Sublocation';
  final String controlText = 'Control';
  final TextEditingController _subLocationController = TextEditingController();
  final TextEditingController _controlController = TextEditingController();
  final FocusNode _subLocationFocusNode = FocusNode();

  AudioPlayer audioPlayer = AudioPlayer();
  String controlsScannedText = 'Controls scanned: 0 / inSublocation: 0';
  List<List<String>> tableData = [];

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
    FocusScope.of(context).requestFocus(_subLocationFocusNode);
    Future.delayed(Duration(milliseconds: 0), () {
      textInput.invokeMethod('TextInput.hide');
    });
  }

  void _showDialogWithSound(String message) {
    // Muestra el cuadro de diálogo con el mensaje
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            alertDialog,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            message,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          backgroundColor: Color.fromARGB(173, 10, 78, 134),
          actions: [
            TextButton(
              onPressed: () {
                // Detiene el sonido cuando el usuario hace clic en "Aceptar"
                _stopErrorSound();

                Navigator.of(context).pop(); // Cierra el cuadro de diálogo
              },
              child: Text(
                okayMessage,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ignore: non_constant_identifier_names

  void _processData() async {
    _addControl();
    //await _putControlsCountSublocation();
  }

  static const MethodChannel textInput = OptionalMethodChannel(
    'flutter/textinput',
    JSONMethodCodec(),
  );

  // Añade este método a tu clase _InDataScreenState
  void _addControl() async {
    // Obtén los valores seleccionados y escritos

    String? selectedLocation = selectedOption;
    String subLocation = _subLocationController.text;
    String control = _controlController.text;
    _controlController.clear();
    FocusScope.of(context).requestFocus(_subLocationFocusNode);
    Future.delayed(Duration(milliseconds: 0), () {
      textInput.invokeMethod('TextInput.hide');
    });
    // ignore: non_constant_identifier_names
    String ModifiedBy = UserManager.userName;

    if (selectedOption == null) {
      _playErrorSound();
      _showDialogWithSound(selectLocationFirst);
      return;
    }
    // Construye el cuerpo de la solicitud en formato JSON
    Map<String, dynamic> requestData = {
      'ControlNumber': control,
      'Location': selectedLocation,
      'SubLocation': subLocation,
      'ModifiedBy': ModifiedBy,
    };

    final response = await http.post(
      //Production mode
      Uri.parse(routeInclute),

      headers: <String, String>{
        'Content-Type': typeJason,
        'Authorization': tokenAddControl,
      },
      body: jsonEncode(requestData),
    );

    if (response.statusCode == 200) {
      // Solicitud exitosa

      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      final ApiResponse apiResponse = ApiResponse.fromJson(jsonResponse);

      // Agrega los datos a la tabla localmente
      if (apiResponse.success) {
        if (apiResponse.message == includeHasBeenGood) {
          // Busca la posición del control existente en la tabla
          // Verifica si el control ya existe en la tabla
          bool controlExists = tableData.any((row) => row[1] == control);

          if (controlExists) {
            // Elimina el control existente
            tableData.removeWhere((row) => row[1] == control);
          }

          // Agrega el nuevo control a la tabla
          setState(() {
            tableData.insert(0, [subLocation, control]);
          });
          _putControlsCountSublocation();
        }
      } else {
        // La solicitud fue fallida
        // Muestra un mensaje de error al usuario
        _playErrorSound();
        _subLocationFocusNode.unfocus();
        _showDialogWithSound(apiResponse.message + controlText + control);
      }
    } else {
      // Error en la solicitud
      _playErrorSound();
      _subLocationFocusNode.unfocus();
      _showDialogWithSound('${response.statusCode} ${response.body}');
    }
  }

  Future<void> _putControlsCountSublocation() async {
    // Obtén los valores seleccionados y escritos
    String? selectedLocation = selectedOption;
    String subLocation = _subLocationController.text;

    // Construye el cuerpo de la solicitud en formato JSON
    Map<String, dynamic> requestData = {
      'Location': selectedLocation,
      'SubLocation': subLocation,
    };

    final response = await http.post(
      Uri.parse(routeCountControls),
      headers: <String, String>{
        'Content-Type': typeJason,
        'Authorization': tokenCount,
      },
      body: jsonEncode(requestData),
    );

    if (response.statusCode == 200) {
      // Solicitud exitosa

      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      final ApiResponse apiResponse = ApiResponse.fromJson(jsonResponse);

      // Agrega los datos a la tabla localmente
      if (apiResponse.success) {
        if (apiResponse.message == countControlsFetch) {
          // Verificación de tipo antes de acceder al campo 'result'
          if (apiResponse.result.containsKey(countWord)) {
            // Accede al campo 'Count' dentro del mapa result
            dynamic countValue = apiResponse.result[countWord];
            int controlsCount = (countValue is int)
                ? countValue
                : int.tryParse(countValue) ?? 0;

            setState(() {
              // Mantén la parte inicial del texto y actualiza solo la última parte
              controlsScannedText =
                  'Controls scanned: ${tableData.length}/ inSublocation: $controlsCount';
            });

            ;
            // Resto del código...
          }
        }
      }
    }
  }

  void _moveToControl() {
    FocusScope.of(context).requestFocus(_subLocationFocusNode);
  }

  @override
  void initState() {
    super.initState();

    // Escucha los cambios en la visibilidad del teclado

    // Inicializa selectedOption con el primer elemento de locationOptions
    selectedOption = locationOptions.isNotEmpty ? locationOptions.first : null;
    // Llama a la función para obtener las ubicaciones al cargar la pantalla
    _fetchLocations();

    _subLocationFocusNode.addListener(() {});
  }

  // Muestra una superposición que envía el teclado al fondo

  // Nueva función para obtener ubicaciones desde la API
  void _fetchLocations() async {
    try {
      final response = await http.get(
        Uri.parse(locationRoute),
        headers: <String, String>{
          'Content-Type': typeJason,
          'Authorization': tokenFetchLoc,
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final ApiResponse apiResponse = ApiResponse.fromJson(jsonResponse);

        if (apiResponse.success) {
          setState(() {
            apiLocations = apiResponse.result;
          });
        }
      } else {}
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          titleScreen,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      drawer: SideMenu(),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/backgroundd.png'),
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 1),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    selectLoc,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  DropdownButton<String>(
                    value: selectedOption,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedOption = newValue;
                      });
                    },
                    items: apiLocations.map((location) {
                      return DropdownMenuItem<String>(
                        value: location[locationname].toString(),
                        child: Text(
                          location[locationname].toString(),
                          style: const TextStyle(
                            color: Color.fromARGB(213, 8, 59, 94),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Container(
                width: 300,
                height: 50,
                child: TextField(
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  controller: _subLocationController,
                  decoration: InputDecoration(
                    labelText: subLocationText,
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
                    _moveToControl();
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
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  controller: _controlController,
                  focusNode: _subLocationFocusNode,
                  decoration: InputDecoration(
                    labelText: controlText,
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
                    //_addControl();
                    _processData();
                  },
                ),
              ),
              const SizedBox(height: 5),
              Container(
                width: 300,
                height: 35,
                child: ElevatedButton(
                  onPressed: _addControl,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(95, 21, 241, 131),
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  child: const Text(
                    'Add Control',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                controlsScannedText,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
              _buildDataTable(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDataTable() {
    return Container(
      height: 290, // Ajusta la altura de la caja según tus necesidades
      child: ListView.builder(
        scrollDirection: Axis.vertical,
        itemCount: 1, // Solo habrá una fila
        itemBuilder: (BuildContext context, int index) {
          return SingleChildScrollView(
            child: DataTable(
              columns: const [
                DataColumn(
                  label: Text(
                    'Sub Location',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Control',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
              rows: tableData.map((rowData) {
                return DataRow(
                  cells: rowData.map((data) {
                    return DataCell(
                      Text(
                        data,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
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
}
