// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:restro_range_waiter/const/colors.dart';
import 'package:restro_range_waiter/const/size_radius.dart';
import 'package:restro_range_waiter/orders.dart';
import 'package:restro_range_waiter/repository/repo.dart';

class TableMenu extends ConsumerStatefulWidget {
  final String tableId;
  final String restroId;
  final String waiterId;
  final String waiterName;
  final int index;
  const TableMenu({
    super.key,
    required this.waiterName,
    required this.tableId,
    required this.restroId,
    required this.waiterId,
    required this.index,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => TableMenuState();
}

final quantityController = TextEditingController();

class TableMenuState extends ConsumerState<TableMenu> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(title: Text('Menu For Table ${widget.index + 1}')),
      floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.black,
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(
              builder: (context) {
                return OrderList(
                  waiterName: widget.waiterName,
                  tableId: widget.tableId,
                  restroId: widget.restroId,
                  waiterId: widget.waiterId,
                  index: widget.index,
                );
              },
            ));
          },
          child: Icon(
            Icons.menu_book_outlined,
            color: Colors.amber,
          )),
      body: SafeArea(
          child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('restaurants')
                  .doc(widget.restroId)
                  .collection('menuCategory')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Text('No Menu available right Now');
                }
                return Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        final document = snapshot.data!.docs[index];
                        final data = document.data() as Map<String, dynamic>;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data['categoryName'],
                              textAlign: TextAlign.start,
                              style:
                                  TextStyle(color: Colors.black, fontSize: 28),
                            ),
                            Container(
                              width: double.infinity,
                              height: 250,
                              color: Colors.white,
                              child: StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection('restaurants')
                                    .doc(widget.restroId)
                                    .collection('menu')
                                    .where("categoryName",
                                        isEqualTo: data['categoryName'])
                                    .snapshots(),
                                builder: (context, category1) {
                                  if (category1.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Center(
                                        child: CircularProgressIndicator());
                                  }
                                  if (category1.hasError) {
                                    return Text('Error: ${category1.error}');
                                  }

                                  if (!category1.hasData ||
                                      category1.data!.docs.isEmpty) {
                                    return const Text(
                                        'No Menu available right Now');
                                  }
                                  return ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemBuilder: (context, index) {
                                      final document1 =
                                          category1.data!.docs[index];
                                      final data1 = document1.data()
                                          as Map<String, dynamic>;

                                      return Row(
                                        children: [
                                          Stack(
                                            children: [
                                              InkWell(
                                                onTap: () {
                                                  addOrder(
                                                      context,
                                                      data1,
                                                      size,
                                                      widget.index,
                                                      widget.tableId);
                                                },
                                                child: Container(
                                                  height: double.infinity,
                                                  width: 105,
                                                  decoration: BoxDecoration(
                                                    borderRadius: radius20,
                                                  ),
                                                  child: ClipRRect(
                                                    borderRadius: radius20,
                                                    child: CachedNetworkImage(
                                                      imageUrl:
                                                          data1['foodPic'],
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                bottom: 0,
                                                right: 5,
                                                child: Container(
                                                  width: size.width * 0.2,
                                                  decoration: BoxDecoration(
                                                    borderRadius: radius10,
                                                    color: Colors.white,
                                                  ),
                                                  child: Column(
                                                    children: [
                                                      Text(
                                                        data1['foodName'],
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                      Text(
                                                        '₹${data1['foodPrice']}',
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          width20
                                        ],
                                      );
                                    },
                                    itemCount: category1.data?.docs.length,
                                  );
                                },
                              ),
                            ),
                            height20,
                          ],
                        );
                      }),
                );
              })),
    );
  }

  Future<dynamic> addOrder(BuildContext context, Map<String, dynamic> data1,
      Size size, int index, String tableId) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: primColor,
          title: Text(data1['foodName']),
          content: Text('Enter Quantity Required'),
          actions: [
            Center(
              child: Container(
                  width: size.width / 6,
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: textColor,
                      focusedBorder: OutlineInputBorder(borderRadius: radius20),
                      border: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: backgroundColor, width: 10)),
                    ),
                    controller: quantityController,
                  )),
            ),
            ElevatedButton(
                onPressed: () async {
                  await ref.read(repoProvider).orderTaking(
                      tableId: tableId,
                      index: index,
                      context: context,
                      datas: data1,
                      quantity: quantityController.text);
                  quantityController.clear();
                  Navigator.pop(context);
                },
                child: Text('Add')),
          ],
        );
      },
    );
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> fetch(
      {required String restroId}) async* {
    final category = await FirebaseFirestore.instance
        .collection('restaurants')
        .doc(restroId)
        .collection('menuCategory')
        .get();

    yield category;
  }
}
