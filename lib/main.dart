import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter/services.dart';

void main() => runApp(MyApp());

String thisUserToken = "";
List<String> globalBeerList;
List<String> beerIdList;
Map<String, String> beerMap;
String tiempoPedido;

Future<PostCreateOrder> createOrderPost(
    String beerId, String amount, String autToken) async {
  final response = await http.post(
    'https://embotelladora.herokuapp.com/pedidos/create/',
    headers: <String, String>{
      'Content-Type': 'application/json',
      //'Connection': 'keep-alive',
      'Authorization': 'Token  $autToken'
    },
    body: jsonEncode(<String, String>{
      'cerveza': beerId,
      'cantidad_botellas': amount,
    }),
  );

  if (response.statusCode == 201) {
    //String data = response.body.toString();
    //List splitted = data.split('"');
    debugPrint("Pedido creado con exito");
    return PostCreateOrder.fromJson(jsonDecode(response.body));
  } else {
    debugPrint(response.statusCode.toString());
    debugPrint(response.body.toString());
    return PostCreateOrder.fromJson(jsonDecode(response.body));
  }
}

class PostCreateOrder {
  final dynamic beerId, amount;

  PostCreateOrder({this.beerId, this.amount});

  factory PostCreateOrder.fromJson(Map<String, dynamic> json) {
    return PostCreateOrder(
        beerId: json['cerveza'], amount: json['cantidad_botellas']);
  }
}

Future<PostCreateBeer> createBeerPost(String price, String color,
    String alcohol, String ferm, String name, String autToken) async {
  final response = await http.post(
    'https://embotelladora.herokuapp.com/cerveza/create/',
    headers: <String, String>{
      'Content-Type': 'application/json',
      //'Connection': 'keep-alive',
      'Authorization': 'Token  $autToken'
    },
    body: jsonEncode(<String, String>{
      'precio': price,
      'color': color,
      'alcohol': alcohol,
      'fermentacion': ferm,
      'nombre': name,
    }),
  );

  if (response.statusCode == 201) {
    //String data = response.body.toString();
    //List splitted = data.split('"');
    debugPrint(price);
    debugPrint(color);
    debugPrint(alcohol);
    debugPrint(ferm);
    debugPrint(name);
    debugPrint(thisUserToken);
    debugPrint("Si se creo");
    return PostCreateBeer.fromJson(jsonDecode(response.body));
  } else {
    debugPrint(response.statusCode.toString());
    debugPrint(response.body.toString());
    return PostCreateBeer.fromJson(jsonDecode(response.body));
  }
}

class PostCreateBeer {
  final dynamic color, ferm, name;
  final dynamic alcohol;
  final dynamic price, id;

  PostCreateBeer(
      {this.price, this.color, this.alcohol, this.ferm, this.name, this.id});

  factory PostCreateBeer.fromJson(Map<String, dynamic> json) {
    return PostCreateBeer(
        price: json['precio'],
        color: json['color'],
        alcohol: json['alcohol'],
        ferm: json['fermentacion'],
        name: json['nombre'],
        id: json['id']);
  }
}

class User {
  final String user;
  final String pass;

  static String acqToken;
  static bool acqAuth;
  static List<String> beerList = new List();

  String getToken() {
    return acqToken;
  }

  bool getAuth() {
    return acqAuth;
  }

  List<String> getBeerList() {
    return beerList;
  }

  Future<PostLogin> fetchLoginPost(user, pass) async {
    final response = await http.post(
      'https://embotelladora.herokuapp.com/user/login/',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'username': user,
        'password': pass,
      }),
    );

    if (response.statusCode == 200) {
      String data = response.body.toString();
      List splitted = data.split('"');

      acqToken = splitted[3];
      acqAuth = true;
      return PostLogin.fromJson(jsonDecode(response.body));
    } else {
      acqToken = "";
      acqAuth = false;
      throw Exception('Failed to load post.');
    }
  }

  Future<GetList> fetchBeerList() async {
    final getResponse = await http.get(
        'https://embotelladora.herokuapp.com/cerveza/',
        headers: <String, String>{'Authorization': 'Token $thisUserToken'});

    if (getResponse.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      //String jsonResponse = getResponse.body.toString();

      String jsonResponse = jsonDecode(getResponse.body).toString();
      String aux1 = jsonResponse.replaceAll("[", "");
      String aux2 = aux1.replaceAll("]", "");
      String aux3 = aux2.replaceAll(":", ",");
      List<dynamic> prevBeerList = aux3.split("},");
      String listaCompleta = prevBeerList.toString();
      List<dynamic> aux4 = listaCompleta.split(",");
      num longitud = aux4.length / 12;
      beerList = new List(longitud.toInt());
      beerIdList = new List(longitud.toInt());
      beerMap = new Map();

      var auxList = new List(aux4.length + 1);

      auxList[0] = "0";
      for (var i = 0; i < aux4.length; i++) {
        auxList[i + 1] = aux4[i];
        //debugPrint(auxList[i]);
      }
      //debugPrint("Fin lista");
      var k = 0;
      for (var i = 1; i < auxList.length; i++) {
        //debugPrint("Item examinado: " + "@" + auxList[i] + "@");
        //debugPrint("Item anterior :" + "@" + auxList[i - 1] + "@");
        if (auxList[i - 1].toString() == " nombre") {
          beerList[k] = auxList[i];
          k++;
        }
      }
      for (var i = 0; i < beerList.length; i++) {
        beerIdList[i] = (i + 1).toString();
      }
      debugPrint(beerIdList.toString());

      for (var i = 0; i < beerList.length; i++) {
        beerMap[beerIdList[i]] = beerList[i];
      }
      debugPrint(beerMap["1"].toString());

      //return GetList.fromJson(jsonDecode(getResponse.body));
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load album');
    }
  }

  User(this.user, this.pass, autToken, authBool);
}

class PostLogin {
  final String token;
  final int userId;
  final String email;

  PostLogin({this.token, this.userId, this.email});

  factory PostLogin.fromJson(Map<String, dynamic> json) {
    return PostLogin(
      token: json['token'],
      userId: json['user_id'],
      email: json['email'],
    );
  }
}

class GetList {
  final int precio, id;
  final String color, fermentacion, nombre;
  final double alcohol;

  GetList(
      {this.precio,
      this.color,
      this.alcohol,
      this.fermentacion,
      this.nombre,
      this.id});

  factory GetList.fromJson(Map<String, dynamic> json) {
    return GetList(
      precio: json['precio'],
      color: json['color'],
      alcohol: json['alcohol'],
      fermentacion: json['fermentacion'],
      nombre: json['nombre'],
      id: json['id'],
    );
  }
}

Future<PostCreateUser> createUserPost(
    user, pass, email, name, last, role, gender) async {
  final response = await http.post(
    'https://embotelladora.herokuapp.com/user/create/',
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Connection': 'keep-alive',
    },
    body: jsonEncode(<String, String>{
      'username': user,
      'password': pass,
      'email': email,
      'nombres': name,
      'apellidos': last,
      'rol': role,
      'genero': gender,
    }),
  );

  if (response.statusCode == 200) {
    debugPrint("Usuario creado con éxito.");
    return PostCreateUser.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Usuario no se puede crear');
  }
}

class PostCreateUser {
  final String user, pass, email, name, last, role, gender;

  PostCreateUser(
      {this.user,
      this.pass,
      this.email,
      this.name,
      this.last,
      this.role,
      this.gender});

  factory PostCreateUser.fromJson(Map<String, dynamic> json) {
    return PostCreateUser(
        user: json['user'],
        pass: json['pass'],
        email: json['email'],
        name: json['name'],
        last: json['last'],
        role: json['role'],
        gender: json['gender']);
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login',
      home: Login(),
    );
  }
}

// Define a custom Form widget.
class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class Home extends StatefulWidget {
  _HomeState createState() => _HomeState();
}

// Define a corresponding State class.
// This class holds the data related to the Form.
class _LoginState extends State<Login> {
  // Create a text controller and use it to retrieve the current value
  // of the TextField.
  final myControllerUser = TextEditingController();
  final myControllerPass = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    myControllerUser.dispose();
    super.dispose();

    myControllerPass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Login'),
        ),
        body: Column(
          children: [
            Card(
                child: Column(children: <Widget>[
              Image.asset(
                'assets/logo.png',
                height: 100,
                width: 100,
              ),
            ])),
            Container(
              margin: EdgeInsets.all(5.0),
              child: TextField(
                obscureText: false,
                controller: myControllerUser,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'User',
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.all(5.0),
              child: TextField(
                obscureText: true,
                controller: myControllerPass,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Password',
                ),
              ),
            ),
            /*floatingActionButton:*/ RaisedButton(
              onPressed: () {
                String usuario = myControllerUser.text;
                String contra = myControllerPass.text;

                setState(() {
                  User user1 = new User(usuario, contra, "", false);
                  user1.fetchLoginPost(usuario, contra);

                  debugPrint(user1.getAuth().toString());
                  debugPrint(user1.getToken().toString());
                  thisUserToken = user1.getToken().toString();

                  if (user1.getAuth()) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Home()),
                    );
                    user1.fetchBeerList();
                    globalBeerList = user1.getBeerList();
                    debugPrint(globalBeerList.toString());
                  } else {
                    return showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          content: Text(
                              'Contraseña incorrecta, por favor intente de nuevo'),
                        );
                      },
                    );
                  }
                });
              },
              //tooltip: 'Show me the value!',
              child: Text('Login'),
              textColor: Colors.white,
              color: Colors.blue,
            ),
          ],
        ));
  }
}

class _HomeState extends State<Home> {
  //No se

  String dropdownValue = "1";

  Widget buildDrop(BuildContext context) {
    return DropdownButton<String>(
      value: dropdownValue,
      icon: Icon(Icons.arrow_downward),
      iconSize: 24,
      elevation: 16,
      style: TextStyle(color: Colors.deepPurple),
      underline: Container(
        height: 2,
        color: Colors.deepPurpleAccent,
      ),
      onChanged: (String newValue) {
        setState(() {
          dropdownValue = newValue;
        });
      },
      items: beerIdList.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(beerMap[value]),
        );
      }).toList(),
    );
  }

  //Create order controllers
  final myControllerAmmount = TextEditingController();

  //Create user controllers
  final myControllerUserName = TextEditingController();
  final myControllerPassword = TextEditingController();
  final myControllerEmail = TextEditingController();
  final myControllerName = TextEditingController();
  final myControllerLastName = TextEditingController();
  final myControllerRole = TextEditingController();
  final myControllerGender = TextEditingController();

  //Create order controllers
  final myControllerPrice = TextEditingController();
  final myControllerColor = TextEditingController();
  final myControllerAlcohol = TextEditingController();
  final myControllerBeerName = TextEditingController();

  @override
  void dispose() {
    myControllerAmmount.dispose();
    super.dispose();

    myControllerUserName.dispose();
    super.dispose();

    myControllerPassword.dispose();
    super.dispose();

    myControllerEmail.dispose();
    super.dispose();

    myControllerName.dispose();
    super.dispose();

    myControllerLastName.dispose();
    super.dispose();

    myControllerRole.dispose();
    super.dispose();

    myControllerGender.dispose();
    super.dispose();

    myControllerPrice.dispose();
    super.dispose();

    myControllerColor.dispose();
    super.dispose();

    myControllerAlcohol.dispose();
    super.dispose();

    myControllerBeerName.dispose();
    super.dispose();
  }

  String _valueFerm = "A";
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: AppBar(
            bottom: TabBar(
              tabs: [
                Tab(icon: Icon(Icons.home)),
                Tab(icon: Icon(Icons.business)),
                Tab(icon: Icon(Icons.score_outlined)),
                Tab(icon: Icon(Icons.access_alarms))
              ],
            ),
            title: Text('Home'),
          ),
          body: TabBarView(
            children: [
              Container(
                //Create order
                padding: EdgeInsets.all(20.0),
                child: Column(children: [
                  buildDrop(context),
                  Container(
                    margin: EdgeInsets.all(5.0),
                    child: TextField(
                      obscureText: false,
                      controller: myControllerAmmount,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Cantidad',
                      ),
                    ),
                  ),
                  RaisedButton(
                    onPressed: () {
                      String cantidad = myControllerAmmount.text;
                      String type = dropdownValue;
                      debugPrint(cantidad);
                      debugPrint(type);

                      var auxTime = int.parse(cantidad);

                      createOrderPost(type, cantidad, thisUserToken);
                      tiempoPedido = (auxTime * 15).toString();
                    },
                    //tooltip: 'Show me the value!',
                    child: Text('Enviar'),
                    textColor: Colors.white,
                    color: Colors.blue,
                  ),
                ]),
              ),
              Container(
                // Create User
                padding: EdgeInsets.all(50.0),
                child: SingleChildScrollView(
                  child: Column(children: [
                    Container(
                        margin: EdgeInsets.all(1.0),
                        child: TextField(
                          obscureText: false,
                          controller: myControllerUserName,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Username',
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 0.5, horizontal: 10.0)),
                          style: TextStyle(fontSize: 12.0, height: 1),
                        )),
                    Container(
                      margin: EdgeInsets.all(1.0),
                      child: TextField(
                        obscureText: true,
                        controller: myControllerPassword,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Password',
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 7.0, horizontal: 10.0),
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.all(2.0),
                      child: TextField(
                        obscureText: false,
                        controller: myControllerEmail,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Email',
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 7.0, horizontal: 10.0),
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.all(1.0),
                      child: TextField(
                        obscureText: false,
                        controller: myControllerName,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Names',
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 7.0, horizontal: 10.0),
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.all(1.0),
                      child: TextField(
                        obscureText: false,
                        controller: myControllerLastName,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Last names',
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 7.0, horizontal: 10.0),
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.all(1.0),
                      child: TextField(
                        obscureText: false,
                        controller: myControllerRole,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Role',
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 7.0, horizontal: 10.0),
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.all(1.0),
                      child: TextField(
                        obscureText: false,
                        controller: myControllerGender,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Gender',
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 7.0, horizontal: 10.0),
                        ),
                      ),
                    ),
                    RaisedButton(
                      onPressed: () {
                        String nombreUsuario = myControllerUserName.text;
                        String contraUsuario = myControllerPassword.text;
                        String emailUsuario = myControllerEmail.text;
                        String nombre = myControllerName.text;
                        String apellidos = myControllerLastName.text;
                        String rol = myControllerRole.text;
                        String genero = myControllerGender.text;

                        createUserPost(nombreUsuario, contraUsuario,
                            emailUsuario, nombre, apellidos, rol, genero);
                      },
                      child: Text('Enviar'),
                      textColor: Colors.white,
                      color: Colors.blue,
                    ),
                  ]),
                ),
              ),
              Container(
                //Create beer
                padding: EdgeInsets.all(50.0),
                child: SingleChildScrollView(
                  child: Column(children: [
                    Container(
                        margin: EdgeInsets.all(1.0),
                        child: TextField(
                          obscureText: false,
                          controller: myControllerPrice,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Price',
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 0.5, horizontal: 10.0)),
                          style: TextStyle(fontSize: 12.0, height: 1),
                        )),
                    Container(
                      margin: EdgeInsets.all(1.0),
                      child: TextField(
                        obscureText: false,
                        controller: myControllerColor,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Color',
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 7.0, horizontal: 10.0),
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.all(2.0),
                      child: TextField(
                        obscureText: false,
                        controller: myControllerAlcohol,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Alcohol degree',
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 7.0, horizontal: 10.0),
                        ),
                      ),
                    ),
                    DropdownButton(
                      value: _valueFerm,
                      items: [
                        DropdownMenuItem(
                          child: Text("Fermentación alta"),
                          value: "A",
                        ),
                        DropdownMenuItem(
                          child: Text("Fermentación baja"),
                          value: "B",
                        ),
                        DropdownMenuItem(
                          child: Text("Fermentación espontanea"),
                          value: "C",
                        )
                      ],
                      onChanged: (value) {
                        setState(() {
                          _valueFerm = value;
                        });
                      },
                    ),
                    Container(
                      margin: EdgeInsets.all(1.0),
                      child: TextField(
                        obscureText: false,
                        controller: myControllerBeerName,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Name',
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 7.0, horizontal: 10.0),
                        ),
                      ),
                    ),
                    RaisedButton(
                      onPressed: () {
                        String precio = myControllerPrice.text;
                        String color = myControllerColor.text;
                        String gradoAlcohol = myControllerAlcohol.text;
                        String fermentacion = _valueFerm;
                        String beerName = myControllerBeerName.text;

                        createBeerPost(precio, color, gradoAlcohol,
                            fermentacion, beerName, thisUserToken);
                      },
                      //tooltip: 'Show me the value!',
                      child: Text('Enviar'),
                      textColor: Colors.white,
                      color: Colors.blue,
                    ),
                  ]),
                ),
              ),
              Container(
                child: RaisedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => BluetoothApp()),
                      );
                    },
                    child: Text('Scan')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BluetoothApp extends StatefulWidget {
  @override
  _BluetoothAppState createState() => _BluetoothAppState();
}

class _BluetoothAppState extends State<BluetoothApp> {
  // Initializing the Bluetooth connection state to be unknown
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;
  // Initializing a global key, as it would help us in showing a SnackBar later
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  // Get the instance of the Bluetooth
  FlutterBluetoothSerial _bluetooth = FlutterBluetoothSerial.instance;
  // Track the Bluetooth connection with the remote device
  BluetoothConnection connection;

  int _deviceState;

  bool isDisconnecting = false;

  Map<String, Color> colors = {
    'onBorderColor': Colors.green,
    'offBorderColor': Colors.red,
    'neutralBorderColor': Colors.transparent,
    'onTextColor': Colors.green[700],
    'offTextColor': Colors.red[700],
    'neutralTextColor': Colors.blue,
  };

  // To track whether the device is still connected to Bluetooth
  bool get isConnected => connection != null && connection.isConnected;

  // Define some variables, which will be required later
  List<BluetoothDevice> _devicesList = [];
  BluetoothDevice _device;
  bool _connected = false;
  bool _isButtonUnavailable = false;

  @override
  void initState() {
    super.initState();

    // Get current state
    FlutterBluetoothSerial.instance.state.then((state) {
      setState(() {
        _bluetoothState = state;
      });
    });

    _deviceState = 0; // neutral

    // If the bluetooth of the device is not enabled,
    // then request permission to turn on bluetooth
    // as the app starts up
    enableBluetooth();

    // Listen for further state changes
    FlutterBluetoothSerial.instance
        .onStateChanged()
        .listen((BluetoothState state) {
      setState(() {
        _bluetoothState = state;
        if (_bluetoothState == BluetoothState.STATE_OFF) {
          _isButtonUnavailable = true;
        }
        getPairedDevices();
      });
    });
  }

  @override
  void dispose() {
    // Avoid memory leak and disconnect
    if (isConnected) {
      isDisconnecting = true;
      connection.dispose();
      connection = null;
    }

    super.dispose();
  }

  // Request Bluetooth permission from the user
  Future<void> enableBluetooth() async {
    // Retrieving the current Bluetooth state
    _bluetoothState = await FlutterBluetoothSerial.instance.state;

    // If the bluetooth is off, then turn it on first
    // and then retrieve the devices that are paired.
    if (_bluetoothState == BluetoothState.STATE_OFF) {
      await FlutterBluetoothSerial.instance.requestEnable();
      await getPairedDevices();
      return true;
    } else {
      await getPairedDevices();
    }
    return false;
  }

  // For retrieving and storing the paired devices
  // in a list.
  Future<void> getPairedDevices() async {
    List<BluetoothDevice> devices = [];

    // To get the list of paired devices
    try {
      devices = await _bluetooth.getBondedDevices();
    } on PlatformException {
      print("Error");
    }

    // It is an error to call [setState] unless [mounted] is true.
    if (!mounted) {
      return;
    }

    // Store the [devices] list in the [_devicesList] for accessing
    // the list outside this class
    setState(() {
      _devicesList = devices;
    });
  }

  // Now, its time to build the UI
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text("Flutter Bluetooth"),
          backgroundColor: Colors.deepPurple,
          actions: <Widget>[
            FlatButton.icon(
              icon: Icon(
                Icons.refresh,
                color: Colors.white,
              ),
              label: Text(
                "Refresh",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              splashColor: Colors.deepPurple,
              onPressed: () async {
                // So, that when new devices are paired
                // while the app is running, user can refresh
                // the paired devices list.
                await getPairedDevices().then((_) {
                  show('Device list refreshed');
                });
              },
            ),
          ],
        ),
        body: Container(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Visibility(
                visible: _isButtonUnavailable &&
                    _bluetoothState == BluetoothState.STATE_ON,
                child: LinearProgressIndicator(
                  backgroundColor: Colors.yellow,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        'Enable Bluetooth',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Switch(
                      value: _bluetoothState.isEnabled,
                      onChanged: (bool value) {
                        future() async {
                          if (value) {
                            await FlutterBluetoothSerial.instance
                                .requestEnable();
                          } else {
                            await FlutterBluetoothSerial.instance
                                .requestDisable();
                          }

                          await getPairedDevices();
                          _isButtonUnavailable = false;

                          if (_connected) {
                            _disconnect();
                          }
                        }

                        future().then((_) {
                          setState(() {});
                        });
                      },
                    )
                  ],
                ),
              ),
              Stack(
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(
                          "PAIRED DEVICES",
                          style: TextStyle(fontSize: 24, color: Colors.blue),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              'Device:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            DropdownButton(
                              items: _getDeviceItems(),
                              onChanged: (value) =>
                                  setState(() => _device = value),
                              value: _devicesList.isNotEmpty ? _device : null,
                            ),
                            RaisedButton(
                              onPressed: _isButtonUnavailable
                                  ? null
                                  : _connected
                                      ? _disconnect
                                      : _connect,
                              child:
                                  Text(_connected ? 'Disconnect' : 'Connect'),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            side: new BorderSide(
                              color: _deviceState == 0
                                  ? colors['neutralBorderColor']
                                  : _deviceState == 1
                                      ? colors['onBorderColor']
                                      : colors['offBorderColor'],
                              width: 3,
                            ),
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                          elevation: _deviceState == 0 ? 4 : 0,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: Text(
                                    "DEVICE 1",
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: _deviceState == 0
                                          ? colors['neutralTextColor']
                                          : _deviceState == 1
                                              ? colors['onTextColor']
                                              : colors['offTextColor'],
                                    ),
                                  ),
                                ),
                                FlatButton(
                                  onPressed: _connected
                                      ? _sendMessageToBluetooth
                                      : null,
                                  child: Text("ON"),
                                ),
                                FlatButton(
                                  onPressed: _connected
                                      ? _sendOffMessageToBluetooth
                                      : null,
                                  child: Text("OFF"),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    color: Colors.blue,
                  ),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          "NOTE: If you cannot find the device in the list, please pair the device by going to the bluetooth settings",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                        SizedBox(height: 15),
                        RaisedButton(
                          elevation: 2,
                          child: Text("Bluetooth Settings"),
                          onPressed: () {
                            FlutterBluetoothSerial.instance.openSettings();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // Create the List of devices to be shown in Dropdown Menu
  List<DropdownMenuItem<BluetoothDevice>> _getDeviceItems() {
    List<DropdownMenuItem<BluetoothDevice>> items = [];
    if (_devicesList.isEmpty) {
      items.add(DropdownMenuItem(
        child: Text('NONE'),
      ));
    } else {
      _devicesList.forEach((device) {
        items.add(DropdownMenuItem(
          child: Text(device.name),
          value: device,
        ));
      });
    }
    return items;
  }

  // Method to connect to bluetooth
  void _connect() async {
    setState(() {
      _isButtonUnavailable = true;
    });
    if (_device == null) {
      show('No device selected');
    } else {
      if (!isConnected) {
        await BluetoothConnection.toAddress(_device.address)
            .then((_connection) {
          print('Connected to the device');
          connection = _connection;
          setState(() {
            _connected = true;
          });

          connection.input.listen(null).onDone(() {
            if (isDisconnecting) {
              print('Disconnecting locally!');
            } else {
              print('Disconnected remotely!');
            }
            if (this.mounted) {
              setState(() {});
            }
          });
        }).catchError((error) {
          print('Cannot connect, exception occurred');
          print(error);
        });
        show('Device connected');

        setState(() => _isButtonUnavailable = false);
      }
    }
  }

  // void _onDataReceived(Uint8List data) {
  //   // Allocate buffer for parsed data
  //   int backspacesCounter = 0;
  //   data.forEach((byte) {
  //     if (byte == 8 || byte == 127) {
  //       backspacesCounter++;
  //     }
  //   });
  //   Uint8List buffer = Uint8List(data.length - backspacesCounter);
  //   int bufferIndex = buffer.length;

  //   // Apply backspace control character
  //   backspacesCounter = 0;
  //   for (int i = data.length - 1; i >= 0; i--) {
  //     if (data[i] == 8 || data[i] == 127) {
  //       backspacesCounter++;
  //     } else {
  //       if (backspacesCounter > 0) {
  //         backspacesCounter--;
  //       } else {
  //         buffer[--bufferIndex] = data[i];
  //       }
  //     }
  //   }
  // }

  // Method to disconnect bluetooth
  void _disconnect() async {
    setState(() {
      _isButtonUnavailable = true;
      _deviceState = 0;
    });

    await connection.close();
    show('Device disconnected');
    if (!connection.isConnected) {
      setState(() {
        _connected = false;
        _isButtonUnavailable = false;
      });
    }
  }

  // Method to send message,
  // for turning the Bluetooth device on
  void _sendMessageToBluetooth() async {
    connection.output.add(utf8.encode(tiempoPedido + "\r\n"));
    await connection.output.allSent;
    debugPrint(tiempoPedido);
    show('Device Turned On');
    setState(() {
      _deviceState = 1; // device on
    });
  }

  // Method to send message,
  // for turning the Bluetooth device off
  void _sendOffMessageToBluetooth() async {
    connection.output.add(utf8.encode("0" + "\r\n"));
    await connection.output.allSent;
    show('Device Turned Off');
    setState(() {
      _deviceState = -1; // device off
    });
  }

  // Method to show a Snackbar,
  // taking message as the text
  Future show(
    String message, {
    Duration duration: const Duration(seconds: 3),
  }) async {
    await new Future.delayed(new Duration(milliseconds: 100));
    _scaffoldKey.currentState.showSnackBar(
      new SnackBar(
        content: new Text(
          message,
        ),
        duration: duration,
      ),
    );
  }
}
