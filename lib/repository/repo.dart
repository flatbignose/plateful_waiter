// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

final repoProvider = Provider((ref) => Repo(
      auth: FirebaseAuth.instance,
      firestore: FirebaseFirestore.instance,
    ));

class Repo {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;
  Repo({
    required this.auth,
    required this.firestore,
  });

  Stream<QuerySnapshot<Object>> waitersList(String? restroId) {
    return firestore
        .collection('restaurants')
        .doc(restroId)
        .collection('waiters')
        .snapshots();
  }

  List<Map<String, dynamic>> waitersData = [];
  Future<void> getAllWaitersData(String? restroId) async {
    final waitersList = await firestore
        .collection('restaurants')
        .doc(restroId)
        .collection('waiters')
        .get();

        waitersList.docs.forEach((document) {
          final data = document.data();
          waitersData.add(data);
        });
  } 

  Stream<QuerySnapshot<Object>> restroList(String? restroId) {
    return firestore.collection('restaurants').snapshots();
  }

  Future<DocumentSnapshot> getwaiter(
      {required String restroId, required String waiterId}) async {
    DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection('restaurants')
        .doc(restroId)
        .collection('waiters')
        .doc(waiterId)
        .get();

    return snapshot;
  }

  final List<Map<String, dynamic>> orderList = [];
  double grandTotal = 0;
  grandtotalChnage() {
    grandTotal = 0;
  }

  increasegrand(double value) {
    grandTotal = grandTotal + value;
  }

  Set<dynamic> setFood = {};
  // final int index;
  Future<void> orderTaking({
    required BuildContext context,
    required Map<String, dynamic> datas,
    required String quantity,
    required int index,
    required String tableId,
  }) async {
    String price = datas['foodPrice'];
    double priceNum = double.parse(price);
    int qty = int.parse(quantity);
    double total = priceNum * qty;

    Map<String, dynamic> order = {
      'foodName': datas['foodName'],
      'foodPrice': datas['foodPrice'],
      'quantity': qty,
      'total': total,
    };
    itemList(
        data: order,
        restroId: datas['restroId'],
        index: index,
        tableId: tableId);
  }

  itemList({
    Map<String, dynamic>? data,
    String? restroId,
    int? index,
    String? tableId,
  }) async {
    final document = await firestore
        .collection('restaurants')
        .doc('r47DlfmwH3R5Sc8HZT9BZnlau4y2')
        .collection('tables')
        .doc(tableId)
        .collection('orders')
        .get();

    Map<String, dynamic> itemMap = document.docs[0].data();
    List<dynamic> tableDocListDynamic = itemMap['orderList'];

    List<Map<String, dynamic>> tableDocList =
        List<Map<String, dynamic>>.from(tableDocListDynamic);

    tableDocList.add(data!);

    Map<String, dynamic> tableOrders = {'orderList': tableDocList};
    await firestore
        .collection('restaurants')
        .doc('r47DlfmwH3R5Sc8HZT9BZnlau4y2')
        .collection('tables')
        .doc(tableId)
        .collection('orders')
        .doc('orderlist')
        .set(tableOrders);
  }

  Future<void> makeOrder(
      {required BuildContext context,
      required String tableId,
      required String waiterId,
      required String waiterName,
      required String restroId}) async {
    final doc = await firestore
        .collection('restaurants')
        .doc(restroId)
        .collection('tables')
        .doc(tableId)
        .collection('orders')
        .get();

    final document = doc.docs[0];
    final data = document.data();
    final List foodList = data['orderList'];
    foodList.removeAt(0);

    DateTime time = DateTime.now();

    final uid = const Uuid().v1();
    Map<String, dynamic> orders = {
      'order': foodList,
      'orderTime': time,
      'orderId': uid,
      'orderTotal': grandTotal,
      'restroId': restroId,
      'tableId': tableId,
      'waiterId': waiterId,
      'waiterName': waiterName
    };
    showDialog(
      context: context,
      builder: (context) {
        return const AlertDialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          content: Center(
              child: CircularProgressIndicator(
            color: Colors.orange,
          )),
        );
      },
    );
    await firestore
        .collection('restaurants')
        .doc('r47DlfmwH3R5Sc8HZT9BZnlau4y2')
        .collection('orders')
        .doc(tableId)
        .set(orders);

    List<Map<String, dynamic>> orderList = [
      {'foodSet': 'check'}
    ];
    Map<String, dynamic> foodsList = {'orderList': orderList};
    await firestore
        .collection('restaurants')
        .doc(restroId)
        .collection('tables')
        .doc(tableId)
        .collection('orders')
        .doc('orderlist')
        .set(foodsList);
    grandTotal = 0;
    Navigator.pop(context);
  }

  deletesingleItem(int index) async {
    final data = orderList[index];
    final int total = data['total'];
    grandTotal = grandTotal - total;
    // print(grandTotal);
    orderList.removeAt(index);
  }

  deleteFoodOrder(int index) async {
    orderList.clear();
    grandTotal = 0;
  }

  increaseOrder(int index) {
    final data = orderList[index];
    int quantity = data['quantity'];
    int increasedQuantity = quantity + 1;
    int price = int.parse(data['foodPrice']);
    double total = data['total'] + price;

    Map<String, dynamic> order = {
      'foodName': data['foodName'],
      'foodPrice': data['foodPrice'],
      'quantity': increasedQuantity,
      'total': total,
    };
    orderList[index] = order;
    grandTotal = grandTotal + price;
  }
}
