// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:restro_range_waiter/models/waiter_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:restro_range_waiter/const/colors.dart';
import 'package:restro_range_waiter/launch_screen.dart';

import 'const/size_radius.dart';
import 'menu/menu.dart';

class WaiterHome extends StatelessWidget {
  // final String? waiterPic;
  // final String? waiterName;
  // final String? restroId;
  // final String? restroName;
  final WaiterModel? waiter;

  static const routeName = '/waiterHome';
  const WaiterHome({
    this.waiter,
    Key? key,
    // this.waiterPic,
    // this.waiterName,
    // this.restroId,
    // this.restroName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.amberAccent.withOpacity(0.5),
          leading: Padding(
            padding: const EdgeInsets.only(
              left: 5,
            ),
            child: Container(
              height: size.height * 0.08,
              width: size.height * 0.08,
              decoration: BoxDecoration(
                  borderRadius: radius20,
                  border: Border.all(color: primColor, width: 5),
                  image: DecorationImage(
                      image: NetworkImage(waiter!.waiterPic),
                      colorFilter: ColorFilter.mode(
                          Colors.black.withOpacity(0.2), BlendMode.darken),
                      fit: BoxFit.cover)),
            ),
          ),
          title: Text(waiter!.waiterName),
          actions: [
            IconButton(
                onPressed: () {
                  logOUt(context, size);
                },
                icon: const Icon(Icons.logout))
          ]),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('restaurants')
                .doc(waiter!.restroId)
                .collection('tables')
                .orderBy('createDate')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              return Consumer(
                builder: (context, ref, child) {
                  return GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 1,
                            mainAxisSpacing: 20),
                    itemBuilder: (context, index) {
                      final document = snapshot.data!.docs[index];
                      final data = document.data();
                      final tableId = data['tableId'];

                      return GestureDetector(
                        onLongPress: (){
                          if (data['occupied'] == true) {
                            
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return TableMenu(
                                waiterName: waiter!.waiterName,
                                waiterId: waiter!.userId,
                                tableId: tableId,
                                index: index,
                                restroId: waiter!.restroId,
                                
                              );
                            }));
                          } else {
                            HapticFeedback.vibrate();
                          }

                        },
                        onTap: () async {
                          bool occupied = !data['occupied'];
                          // Map<String, dynamic> datas = {
                          //   'tableId': data['tableId'],
                          //   'createDate': data['createDate'],
                          //   'occupied': occupied
                          // };
                          await FirebaseFirestore.instance
                              .collection('restaurants')
                              .doc(waiter!.restroId)
                              .collection('tables')
                              .doc(data['tableId'])
                              .update({'occupied': occupied});
                        },
                        // onLongPress: () async {
                        //   HapticFeedback.vibrate();
                        //   await FirebaseFirestore.instance
                        //       .collection('restaurants')
                        //       .doc(restroId)
                        //       .collection('tables')
                        //       .doc(data['tableId'])
                        //       .delete();
                        // },
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            data['occupied'] == false
                                ? Image.asset(
                                    'asset/tables/table_2_unoccupied.png')
                                : Image.asset(
                                    'asset/tables/table_2_occuppied.png'),
                            Positioned(
                                bottom: 10,
                                child: Container(
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      borderRadius: radius20,
                                      color: Colors.black,
                                    ),
                                    child: Text(
                                      'Table ${index + 1}',
                                      style: TextStyle(color: textColor),
                                    )))
                          ],
                        ),
                      );
                    },
                    itemCount: snapshot.data!.docs.length,
                  );
                },
              );
            }),
      ),
    );
  }

  logOUt(
    BuildContext context,
    Size size,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          elevation: 5,
          backgroundColor: textColor,
          content: const Text(
            'Log Out Current Session?',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: size.width / 8,
                  height: size.width / 8,
                  decoration: BoxDecoration(
                    color: primColor,
                    borderRadius: radius10,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade300,
                        offset: const Offset(4.0, 4.0),
                        blurRadius: 6.0,
                        spreadRadius: 2.0,
                      ),
                    ],
                  ),
                  child: TextButton(
                      onPressed: () async {
                        const CircularProgressIndicator();
                        SharedPreferences pref =
                            await SharedPreferences.getInstance();
                        pref.remove('userId');
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LaunchScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        'Yes',
                        style: TextStyle(color: textColor),
                      )),
                ),
                Container(
                    // duration: const Duration(milliseconds: 150),
                    width: size.width / 8,
                    height: size.width / 8,
                    decoration: BoxDecoration(
                      color: primColor,
                      borderRadius: radius10,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade300,
                          offset: const Offset(4.0, 4.0),
                          blurRadius: 6.0,
                          spreadRadius: 2.0,
                        ),
                      ],
                    ),
                    child: TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'No',
                          style: TextStyle(color: textColor),
                        ))),
              ],
            )
          ],
        );
      },
    );
  }

  options(
      {required BuildContext context,
      required String tableName,
      required String tableId,
      required Map<String, dynamic> data,
      required restroId}) async {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          child: Column(),
        );
      },
    );
  }
}
