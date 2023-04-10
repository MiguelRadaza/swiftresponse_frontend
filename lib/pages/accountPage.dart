import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:swiftresponse/pages/loginPage.dart';
import 'package:swiftresponse/utils/colors.dart';
import 'package:swiftresponse/widgets/big_text.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({Key? key}) : super(key: key);

  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  FirebaseAuth auth = FirebaseAuth.instance;
  final emailTextController = TextEditingController(text: "");
  final passwordTextController = TextEditingController(text: "");
  final firstNameTextController = TextEditingController(text: "");
  final lastNameTextController = TextEditingController(text: "");
  final numberTextController = TextEditingController(text: "");
  final permanentAddressTextController = TextEditingController(text: "");
  final ageTextController = TextEditingController(text: "");
  bool _isReceiveEmailUpdate = false;
  bool isRegisterButtonDisabled = false;
  DateTime _selectedDate = DateTime.now();

  int calculateAge(DateTime birthday) {
    DateTime today = DateTime.now();
    int age = today.year - birthday.year;
    if (today.month < birthday.month ||
        (today.month == birthday.month && today.day < birthday.day)) {
      age--;
    }
    return age;
  }

  @override
  void initState() {
    super.initState();
    _handUserSession();
  }

  void _handUserSession() async {
    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      if (user == null) {
        print('User is currently signed out!');
      } else {
        var variable = await FirebaseFirestore.instance
            .collection('users')
            .where('user_id', isEqualTo: user.uid)
            .get();
        var userData = variable.docs.first.data() as Map;
        setState(() {
          emailTextController.text = userData['email'];
          permanentAddressTextController.text = userData['address'];
          lastNameTextController.text = userData['lastname'];
          ageTextController.text = userData['age'];
          numberTextController.text = userData['number'];
          firstNameTextController.text = userData['firstname'];
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    // emailTextController.dispose();
    // passwordTextController.dispose();
    // permanentAddressTextController.dispose();
    // firstNameTextController.dispose();
    // lastNameTextController.dispose();
    // passwordTextController.dispose();
    // numberTextController.dispose();
    // ageTextController.dispose();
  }

  void _logout() async {
    FirebaseAuth.instance.signOut();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        title: const Text(''),
      ),
      body: ListView(
        children: [
          Container(
            decoration: const BoxDecoration(
                color: AppColors.backgroundColor,
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(190),
                    bottomRight: Radius.circular(190))),
            child: Column(
              children: [
                Container(
                  height: 55,
                ),
                Container(
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                            padding: EdgeInsets.all(15),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(100)),
                            child: const Icon(
                              Icons.people,
                              size: 50,
                            )),
                      ]),
                ),
                Container(
                  height: 120,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                            padding: EdgeInsets.all(15),
                            child: Column(
                              children: [
                                BigText(
                                  text: "Miguel Radaza",
                                  size: 30,
                                ),
                                BigText(
                                  text: "Putatan Muntinlupa",
                                  size: 15,
                                ),
                              ],
                            )),
                      ]),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Gap(20),
                TextField(
                  enabled: false,
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
                  enabled: false,
                  controller: lastNameTextController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Last Name',
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                TextField(
                  enabled: false,
                  controller: ageTextController,
                  decoration: const InputDecoration(
                    labelText: 'Age',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                TextField(
                  controller: numberTextController,
                  enabled: false,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Number',
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                TextField(
                  enabled: false,
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
                  enabled: false,
                  controller: emailTextController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Email',
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _logout();
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (Container) => const LoginPage()));
                    });
                  },
                  child: Container(
                    height: 50,
                    width: double.maxFinite,
                    decoration: BoxDecoration(color: AppColors.backgroundColor),
                    child: Center(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.update),
                          Gap(10),
                          Text(
                            "Update",
                            style: TextStyle(
                                color: AppColors.buttonTextColor,
                                fontSize: 15,
                                fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _logout();
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (Container) => const LoginPage()));
                    });
                  },
                  child: Container(
                    height: 50,
                    width: double.maxFinite,
                    decoration: BoxDecoration(color: Colors.red.shade400),
                    child: Center(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.logout),
                          Gap(10),
                          Text(
                            "Log Out",
                            style: TextStyle(
                                color: AppColors.buttonTextColor,
                                fontSize: 15,
                                fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                Gap(30),
              ],
            ),
          )
        ],
      ),
    );
  }
}
