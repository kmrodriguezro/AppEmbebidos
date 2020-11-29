import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

void main() => runApp(MyApp());

class ListItem {
  int value;
  String name;

  ListItem(this.value, this.name);
}

class User {
  final String user;
  final String pass;

  static String acqToken;
  static bool acqAuth;
  static String autToken;
  static bool authBool;

  User entregable;

  String getToken() {
    return acqToken;
  }

  bool getAuth() {
    return acqAuth;
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

  User(this.user, this.pass, autToken, authBool);
}

class PostLogin {
  final String token;
  final int userId;
  final String email;

  PostLogin({this.token, this.userId, this.email});

  factory PostLogin.fromJson(Map<String, dynamic> json) {
    return PostLogin(
        token: json['token'], userId: json['user_id'], email: json['email']);
  }
}

Future<PostLogin> createUserPost(
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

  if (response.statusCode == 201) {
    debugPrint("Usuario creado con éxito.");
    return PostLogin.fromJson(jsonDecode(response.body));
  } else {
    debugPrint("este usuario no se puede crear");
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

                User user1 = new User(usuario, contra, "", false);
                user1.fetchLoginPost(usuario, contra);

                debugPrint(user1.getAuth().toString());

                if (user1.getAuth()) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Home()),
                  );
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
  final myControllerAmmount = TextEditingController();
  final myControllerUserName = TextEditingController();
  final myControllerPassword = TextEditingController();
  final myControllerEmail = TextEditingController();
  final myControllerName = TextEditingController();
  final myControllerLastName = TextEditingController();
  final myControllerRole = TextEditingController();
  final myControllerGender = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.

    myControllerAmmount.dispose();
    super.dispose();
  }

  String _valueBeer = "Birra";
  String _valueSize = "100";
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            bottom: TabBar(
              tabs: [
                Tab(icon: Icon(Icons.home)),
                Tab(icon: Icon(Icons.business)),
                Tab(icon: Icon(Icons.score_outlined)),
              ],
            ),
            title: Text('Home'),
          ),
          body: TabBarView(
            children: [
              Container(
                padding: EdgeInsets.all(20.0),
                child: Column(children: [
                  DropdownButton(
                    value: _valueBeer,
                    items: [
                      DropdownMenuItem(
                        child: Text("Birra"),
                        value: "Birra",
                      ),
                      DropdownMenuItem(
                        child: Text("Chevecha"),
                        value: "Chevecha",
                      ),
                      DropdownMenuItem(child: Text("Pola"), value: "Pola"),
                      DropdownMenuItem(child: Text("Chela"), value: "Chela")
                    ],
                    onChanged: (value) {
                      setState(() {
                        _valueBeer = value;
                      });
                    },
                  ),
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
                  DropdownButton(
                      value: _valueSize,
                      items: [
                        DropdownMenuItem(
                          child: Text("Pequeña xd"),
                          value: "100",
                        ),
                        DropdownMenuItem(
                          child: Text("Mediana xd"),
                          value: "350",
                        ),
                        DropdownMenuItem(
                            child: Text("Grande :v"), value: "750"),
                        DropdownMenuItem(
                            child: Text("Africana XD"), value: "1000")
                      ],
                      onChanged: (value) {
                        setState(() {
                          _valueSize = value;
                        });
                      }),
                  RaisedButton(
                    onPressed: () {
                      String cantidad = myControllerAmmount.text;
                      String type = _valueBeer;
                      String size = _valueSize;
                      debugPrint(cantidad);
                      debugPrint(type);
                      debugPrint(size);

                      //Lógica para enviar el pedido de cerveza
                    },
                    //tooltip: 'Show me the value!',
                    child: Text('Enviar'),
                    textColor: Colors.white,
                    color: Colors.blue,
                  ),
                ]),
              ),
              Container(
                padding: EdgeInsets.all(50.0),
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

                      debugPrint(nombreUsuario);
                      debugPrint(contraUsuario);
                      debugPrint(emailUsuario);
                      debugPrint(nombre);
                      debugPrint(apellidos);
                      debugPrint(rol);
                      debugPrint(genero);

                      createUserPost(nombreUsuario, contraUsuario, emailUsuario,
                          nombre, apellidos, rol, genero);
                    },
                    //tooltip: 'Show me the value!',
                    child: Text('Enviar'),
                    textColor: Colors.white,
                    color: Colors.blue,
                  ),
                ]),
              ),
              Icon(Icons.directions_bike),
            ],
          ),
        ),
      ),
    );
  }
}
