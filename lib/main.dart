import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medalarm/api/notification_api.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool switch1 = false;
  bool switch2 = true;
  bool switch3 = true;

  bool isMorning = true;
  bool isAfternoon = true;
  bool isNight = true;

  String selectedMedicineName = "";
  dynamic selectedPower;
  String selectedPowerUnit = "mg";

  String morningTime = '9:00 AM';
  String afternoonTime = '2:00 PM';
  String nightTime = '10:00 PM';

  @override
  Widget build(BuildContext context) {
    //Medicine Query
    Stream<QuerySnapshot> medicineQuery =
        FirebaseFirestore.instance.collection("medicine").snapshots();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Medicine', icon: Icon(Icons.medication)),
              Tab(text: 'Alarm', icon: Icon(Icons.alarm))
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
            child: const Icon(Icons.add),
            onPressed: () {
              NotificationApi.showNotification(
                  title: 'Hello',
                  body: 'This is a test notification',
                  payload: 'Hello test');
            } //callingModal,
            ),
        body: TabBarView(
          children: [
            //Medicine tab
            StreamBuilder(
                stream: medicineQuery,
                builder:
                    (context, AsyncSnapshot<QuerySnapshot> streamSnapShot) {
                  return streamSnapShot.hasData
                      ? ListView.builder(
                          itemCount: streamSnapShot.data!.docs.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              //leading: const Icon(Icons.arrow_right),
                              title: Text(streamSnapShot.data!.docs[index]
                                      ['medicine_name'] +
                                  ' - ' +
                                  streamSnapShot.data!.docs[index]['power']
                                      .toString() +
                                  ' ' +
                                  streamSnapShot.data!.docs[index]['unit']),
                              subtitle: textOfTheDay(
                                  streamSnapShot.data!.docs[index]['morning'],
                                  streamSnapShot.data!.docs[index]['afternoon'],
                                  streamSnapShot.data!.docs[index]['night']),
                              leading: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                      onPressed: () {
                                        editMedicine(streamSnapShot.data!
                                            .docs[index]['medicine_name']);
                                      },
                                      icon: const Icon(Icons.edit)),
                                  IconButton(
                                      onPressed: () {
                                        deleteMedicine(streamSnapShot.data!
                                            .docs[index]['medicine_name']);
                                      },
                                      icon: const Icon(Icons.delete))
                                ],
                              ),
                            );
                          },
                        )
                      : const Center(child: CircularProgressIndicator());
                }),

            //Alarm tab
            ListView(
              children: [
                ListTile(
                    leading: const Icon(Icons.arrow_right),
                    title: InkWell(
                      child: Text(morningTime),
                      onTap: () async {
                        var time = await showTimePicker(
                            context: context, initialTime: TimeOfDay.now());
                        if (time != null) {
                          setState(() {
                            morningTime = time.format(context);
                          });
                        }
                      },
                    ),
                    subtitle: const Text('Morning'),
                    trailing: Switch.adaptive(
                      value: switch1,
                      onChanged: (value) => setState(() {
                        switch1 = value;
                      }),
                    )),
                ListTile(
                    leading: const Icon(Icons.arrow_right),
                    title: InkWell(
                      child: Text(afternoonTime),
                      onTap: () async {
                        var time = await showTimePicker(
                            context: context, initialTime: TimeOfDay.now());
                        if (time != null) {
                          setState(() {
                            afternoonTime = time.format(context);
                          });
                        }
                      },
                    ),
                    subtitle: const Text('Afternoon'),
                    trailing: Switch.adaptive(
                      value: switch2,
                      onChanged: (value) => setState(() {
                        switch2 = value;
                      }),
                    )),
                ListTile(
                    leading: const Icon(Icons.arrow_right),
                    title: InkWell(
                      child: Text(nightTime),
                      onTap: () async {
                        var time = await showTimePicker(
                            context: context, initialTime: TimeOfDay.now());
                        if (time != null) {
                          setState(() {
                            nightTime = time.format(context);
                          });
                        }
                      },
                    ),
                    subtitle: const Text('Night'),
                    trailing: Switch.adaptive(
                        value: switch3,
                        onChanged: (value) {
                          setState(() {
                            switch3 = value;
                          });
                        })),
              ],
            ),
          ],
        ),
      ),
    );
  }

  //Modal Bottom Sheet caller function
  void callingModal() {
    showModalBottomSheet(
        context: context,
        //isScrollControlled: true,
        builder: (context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text('Add New Medicine'),
                  const Divider(),
                  TextField(
                    onChanged: (value) => selectedMedicineName = value,
                    decoration: const InputDecoration(
                      labelText: 'Medicine Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: TextField(
                          onChanged: (value) {
                            if (value.contains('.')) {
                              if (!value.contains('0.')) {
                                value = '0' + value;
                              }
                              selectedPower = double.parse(value);
                            } else {
                              selectedPower = int.parse(value);
                            }
                          },
                          decoration: const InputDecoration(
                            labelText: 'Power',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Flexible(
                        child: DropdownButton(
                          value: selectedPowerUnit,
                          icon: const Icon(Icons.arrow_drop_down),
                          iconSize: 24,
                          elevation: 20,
                          style: const TextStyle(color: Colors.black),
                          underline: Container(
                            height: 2,
                            color: Colors.white,
                          ),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedPowerUnit = newValue!;
                            });
                          },
                          items: <String>["mg", "ml"]
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text('When to take?'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Checkbox(
                        value: isMorning,
                        onChanged: (bool? value) {
                          setState(() {
                            isMorning = value!;
                          });
                        },
                      ),
                      const Text('Morning'),
                      Checkbox(
                        value: isAfternoon,
                        onChanged: (bool? value) {
                          setState(() {
                            isAfternoon = value!;
                          });
                        },
                      ),
                      const Text('Afternoon'),
                      Checkbox(
                        value: isNight,
                        onChanged: (bool? value) {
                          setState(() {
                            isNight = value!;
                          });
                        },
                      ),
                      const Text('Evening'),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                      onPressed: () {
                        addNewMedicine(selectedMedicineName, selectedPower,
                            selectedPowerUnit, isMorning, isAfternoon, isNight);
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          content: Text('Medicine has been added!'),
                        ));

                        Navigator.of(context).pop();
                      },
                      child: const Text('Add Medicine')),
                ],
              ),
            );
          });
        }).whenComplete(() {
      setState(() {
        selectedPowerUnit = "mg";
        isMorning = true;
        isAfternoon = true;
        isNight = true;
      });
    });
  }

  //Determine the medicine intake time & format
  Text textOfTheDay(bool morning, bool afternoon, bool night) {
    String result = '';

    if (morning == true) result = 'Morning';
    if (morning == true && afternoon == true) result += ' - ';
    if ((morning == true && night == true) && afternoon == false) {
      result += ' - ';
    }
    if (afternoon == true) result += 'Afternoon';
    if (afternoon == true && night == true) result += ' - ';
    if (night == true) result += 'Night';
    if (morning == false && afternoon == false && night == false) {
      result = 'No time added';
    }

    return Text(result);
  }

  //Adding new medicine to database
  void addNewMedicine(
      String selectedMedicineName,
      dynamic selectedPower,
      String selectedPowerUnit,
      bool isMorning,
      bool isAfternoon,
      bool isNight) {
    FirebaseFirestore.instance.collection('medicine').add({
      'medicine_name': selectedMedicineName,
      'power': selectedPower,
      'unit': selectedPowerUnit,
      'morning': isMorning,
      'afternoon': isAfternoon,
      'night': isNight
    });
  }

  //Edit the properties of selected medicine
  void editMedicine(String medicineName) async {
    String medicName = medicineName;
    String pow = '';
    String unitValue = '';
    bool morning = true;
    bool afternoon = true;
    bool night = true;

    await FirebaseFirestore.instance
        .collection('medicine')
        .where('medicine_name', isEqualTo: medicineName)
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((element) {
        pow = element.data()['power'].toString();
        unitValue = element.data()['unit'];
        morning = element.data()['morning'];
        afternoon = element.data()['afternoon'];
        night = element.data()['night'];
      });
    });

    showModalBottomSheet(
        context: context,
        //isScrollControlled: true,
        builder: (context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text('Add New Medicine'),
                  const Divider(),
                  TextFormField(
                    initialValue: medicName,
                    onChanged: (value) => medicineName = value,
                    decoration: const InputDecoration(
                      labelText: 'Medicine Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: TextFormField(
                          initialValue: pow,
                          onChanged: (value) {
                            if (value.contains('.')) {
                              if (!value.contains('0.')) {
                                value = '0' + value;
                              }
                              selectedPower = double.parse(value);
                            } else {
                              selectedPower = int.parse(value);
                            }
                          },
                          decoration: const InputDecoration(
                            labelText: 'Power',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Flexible(
                        child: DropdownButton(
                          value: unitValue.toString(),
                          icon: const Icon(Icons.arrow_drop_down),
                          iconSize: 24,
                          elevation: 20,
                          style: const TextStyle(color: Colors.black),
                          underline: Container(
                            height: 2,
                            color: Colors.white,
                          ),
                          onChanged: (String? newValue) {
                            setState(() {
                              unitValue = newValue!;
                            });
                          },
                          items: <String>["mg", "ml"]
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text('When to take?'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Checkbox(
                        value: morning,
                        onChanged: (bool? value) {
                          setState(() {
                            morning = value!;
                          });
                        },
                      ),
                      const Text('Morning'),
                      Checkbox(
                        value: afternoon,
                        onChanged: (bool? value) {
                          setState(() {
                            afternoon = value!;
                          });
                        },
                      ),
                      const Text('Afternoon'),
                      Checkbox(
                        value: night,
                        onChanged: (bool? value) {
                          setState(() {
                            night = value!;
                          });
                        },
                      ),
                      const Text('Evening'),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                      onPressed: () {
                        addNewMedicine(medicName, selectedPower, unitValue,
                            morning, afternoon, night);
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          content: Text('Medicine has been updated!'),
                        ));

                        Navigator.of(context).pop();
                      },
                      child: const Text('Update Medicine')),
                ],
              ),
            );
          });
        }).whenComplete(() {
      setState(() {
        medicName = '';
        pow = '';
        unitValue = '';
        morning = true;
        afternoon = true;
        night = true;
      });
    });
  }

  //Delete selected medicine
  void deleteMedicine(String medicineName) {
    FirebaseFirestore.instance
        .collection('medicine')
        .where('medicine_name', isEqualTo: medicineName)
        .get()
        .then((value) => value.docs.first.reference.delete());
  }
}
