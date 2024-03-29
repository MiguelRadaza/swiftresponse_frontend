import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gap/gap.dart';
import 'package:swiftresponse/pages/bottom_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:swiftresponse/pages/home_page.dart';
import 'package:swiftresponse/utils/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailTextController = TextEditingController(text: "");
  final passwordTextController = TextEditingController(text: "");
  final firstNameTextController = TextEditingController(text: "");
  final lastNameTextController = TextEditingController(text: "");
  final numberTextController = TextEditingController(text: "");
  final permanentAddressTextController = TextEditingController(text: "");
  final ageTextController = TextEditingController(text: "");
  FirebaseAuth auth = FirebaseAuth.instance;
  bool _isUserSignedIn = false;
  DateTime _selectedDate = DateTime.now();
  bool _showRegisterPage = false;
  bool _isReceiveEmailUpdate = false;
  bool isRegisterButtonDisabled = false;
  final db = FirebaseFirestore.instance;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _handUserSession();
    // FirebaseAuth.instance.signOut();
  }

  void _handUserSession() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        print('User is currently signed out!');
      } else {
        setState(() {
          _isUserSignedIn = true;
        });
        print('User is signed in!');
      }
    });
  }

  void _createUser() async {
    setState(() {
      _isLoading = true;
    });
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: emailTextController.text,
              password: passwordTextController.text);
      String uid = userCredential.user!.uid;
      CollectionReference users = db.collection('users');
      
      await users.doc(uid).set({
        'birthdate': _selectedDate.toString(),
        'email': emailTextController.text.toString(),
        'address': permanentAddressTextController.text.toString(),
        'firstname': firstNameTextController.text.toString(),
        'lastname': lastNameTextController.text.toString(),
        'password': passwordTextController.text.toString(),
        'user_id': uid,
        'number': numberTextController.text.toString(),
        'age': ageTextController.text.toString(),
        'isReceiveEmailUpdate': _isReceiveEmailUpdate
      });

      if (userCredential.user != null) {
        Fluttertoast.showToast(
            msg: "registered successfully.",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
        print(
            'User ${userCredential.user!.uid.toString()} is registered successfully');
        setState(() {
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        Fluttertoast.showToast(
            msg: "Failed to Register User.",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (e.code == 'weak-password') {
        Fluttertoast.showToast(
            msg: "The password provided is too weak.",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.grey,
            textColor: Colors.white,
            fontSize: 16.0);
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        setState(() {
          _isLoading = false;
        });
        Fluttertoast.showToast(
            msg: "The account already exists for that email.",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
        print('The account already exists for that email.');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      Fluttertoast.showToast(
          msg: "An error occurred please contact developer :$e",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
      setState(() {
        isRegisterButtonDisabled = false;
      });
    }
  }

  int calculateAge(DateTime birthday) {
    DateTime today = DateTime.now();
    int age = today.year - birthday.year;
    if (today.month < birthday.month ||
        (today.month == birthday.month && today.day < birthday.day)) {
      age--;
    }
    return age;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        ageTextController.text = calculateAge(picked).toString();
        _selectedDate = picked;
      });
    }
  }

  void _signInUser() async {
    setState(() {
      _isLoading = true;
    });
    try {
      if (emailTextController.text.isEmpty) {
        Fluttertoast.showToast(
            msg: "Email is required to sign in.",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.grey,
            textColor: Colors.black,
            fontSize: 16.0);
      }
      if (passwordTextController.text.isEmpty) {
        Fluttertoast.showToast(
            msg: "Password is required to sign in.",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.grey,
            textColor: Colors.black,
            fontSize: 16.0);
      }
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailTextController.text.toString(),
          password: passwordTextController.text.toString());
      setState(() {
        _isLoading = false;
        _isUserSignedIn = true;
      });
      Fluttertoast.showToast(
          msg: "Login Successfully.",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.grey,
          textColor: Colors.black,
          fontSize: 16.0);
    } on FirebaseAuthException catch (e) {
      print(e);
      setState(() {
        _isLoading = false;
      });
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
        Fluttertoast.showToast(
            msg: "No user found for that email.",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.red.shade400,
            textColor: Colors.white,
            fontSize: 16.0);
      } else if (e.code == 'wrong-password') {
        setState(() {
          _isLoading = false;
        });
        Fluttertoast.showToast(
            msg: "Wrong password provided for that user.",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.red.shade400,
            textColor: Colors.white,
            fontSize: 16.0);
        print('Wrong password provided for that user.');
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    emailTextController.dispose();
    passwordTextController.dispose();
    permanentAddressTextController.dispose();
    firstNameTextController.dispose();
    lastNameTextController.dispose();
    passwordTextController.dispose();
    numberTextController.dispose();
    ageTextController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return !_isUserSignedIn ? _loginPage() : HomePage();
  }

  Widget _registerPage() {
    return Stack(
      children: [
        Material(
            child: ListView(
          padding: EdgeInsets.symmetric(vertical: 50),
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: const [
                      Text(
                        "Sign Up",
                        style: TextStyle(
                            fontSize: 40, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "●",
                        style: TextStyle(fontSize: 24),
                      ),
                    ],
                  ),
                  const Gap(20),
                  Row(
                    children: const [
                      Text("Already have an account?"),
                      Gap(20),
                      Text("Login"),
                    ],
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  TextField(
                    controller: firstNameTextController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'First Name',
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  TextField(
                    controller: lastNameTextController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Last Name',
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: ageTextController,
                          decoration: const InputDecoration(
                            labelText: 'Age',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Flexible(
                        child: ListTile(
                          title: const Text("Select Birthdate:"),
                          subtitle: Text(
                              "${_selectedDate.year}-${_selectedDate.month}-${_selectedDate.day}"),
                          trailing: const Icon(Icons.keyboard_arrow_down),
                          onTap: () => _selectDate(context),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  TextField(
                    controller: numberTextController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Number',
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  TextField(
                    controller: permanentAddressTextController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Permanent Address',
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  TextField(
                    controller: emailTextController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Email',
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  TextField(
                    controller: passwordTextController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Password',
                    ),
                  ),
                  Row(children: [
                    Checkbox(
                      value: _isReceiveEmailUpdate,
                      onChanged: (bool? value) {
                        setState(() {
                          _isReceiveEmailUpdate = value!;
                        });
                      },
                    ),
                    const Text("Receive email updates")
                  ]),
                  GestureDetector(
                    onTap: isRegisterButtonDisabled
                        ? null
                        : () {
                            setState(() {
                              _createUser();
                            });
                          },
                    child: Container(
                      height: 50,
                      width: double.maxFinite,
                      decoration: BoxDecoration(color: AppColors.buttonColor),
                      child: const Center(
                        child: Text(
                          "SIGN UP",
                          style: TextStyle(
                              color: AppColors.buttonTextColor,
                              fontSize: 15,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                  Gap(15),
                  Row(
                    children: const [
                      Text("By signing up you agree to our:"),
                    ],
                  ),
                  Row(
                    children: const [
                      Text("Privacy Policy & Terms of Service"),
                    ],
                  )
                ],
              ),
            )
          ],
        )),
        _isLoading
            ? Container(
                color: Colors.black.withOpacity(0.5),
              )
            : SizedBox.shrink(),
        // progress indicator
        _isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : SizedBox.shrink(),
      ],
    );
  }

  Widget _loginPage() {
    return !_showRegisterPage
        ? Stack(
            children: [
              Material(
                  child: Container(
                color: AppColors.backgroundColor,
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "CALLision",
                      style: TextStyle(
                          fontSize: 70,
                          fontWeight: FontWeight.w500,
                          color: Colors.white),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    const Text("Login Account",
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                    const SizedBox(
                      height: 25,
                    ),
                    TextField(
                      controller: emailTextController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter Email',
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    const Gap(15),
                    TextField(
                      obscureText: true,
                      controller: passwordTextController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter Password',
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    InkWell(
                        onTap: () => _signInUser(),
                        child: Container(
                          height: 40,
                          width: double.maxFinite,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              color: AppColors.buttonColor2),
                          child: const Center(
                            child: Text(
                              "Sign In",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 20),
                            ),
                          ),
                        )),
                    const SizedBox(
                      height: 16,
                    ),
                    InkWell(
                      child: Container(
                        height: 40,
                        width: double.maxFinite,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            color: AppColors.buttonColor2),
                        child: const Center(
                          child: Text("Register",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 20)),
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          _showRegisterPage = true;
                        });
                      },
                    )
                  ],
                ),
              )),
              _isLoading
                  ? Container(
                      color: Colors.black.withOpacity(0.5),
                    )
                  : SizedBox.shrink(),
              // progress indicator
              _isLoading
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : SizedBox.shrink(),
            ],
          )
        : _registerPage();
  }
}
