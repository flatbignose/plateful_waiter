import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:restro_range_waiter/const/colors.dart';
import 'package:restro_range_waiter/const/size_radius.dart';
import 'package:restro_range_waiter/models/restro_model.dart';
import 'package:restro_range_waiter/repository/repo.dart';
import 'package:restro_range_waiter/waiters.dart';

class LaunchScreen extends ConsumerWidget {
  static const routeName = '/launch';
  const LaunchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Center(
              child: Text(
                'RestroRange\nWaiters',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w600,
                    color: textColor),
              ),
            ),
            height20,
            const Text(
              'Select the Restaurant you work in',
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w600, color: textColor),
            ),
            height20,
            Center(
              child: InkWell(
                onTap: () {
                  restroList(context);
                },
                child: Container(
                  width: size.width / 1.5,
                  height: size.height * 0.07,
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade900,
                        offset: const Offset(4.0, 4.0),
                        blurRadius: 6.0,
                        spreadRadius: 2.0,
                      ),
                    ],
                    color: Colors.black,
                    borderRadius: radius10,
                  ),
                  child: const Center(
                    child: Text(
                      'Select Restaurant',
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: textColor,
                          fontSize: 20),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  

  void restroList(
    BuildContext context,
    // String restroId
  ) {
    final size = MediaQuery.of(context).size;
    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          backgroundColor: primColor,
          children: [
            SizedBox(
                height: size.height / 2,
                width: size.width,
                child: RestaurantList())
          ],
        );
      },
    );
  }
}

class RestaurantList extends ConsumerWidget {
  // final String restroId;
  const RestaurantList({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('restaurants').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Container(
                height: size.height / 4.5,
                width: size.height / 4.5,
                decoration: const BoxDecoration(
                    borderRadius: radius10, color: backgroundColor),
                child: const Center(
                  child: Text(
                    'Restaurants Loading...',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      color: textColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )),
          );
        }

        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Text('No restaurants available.');
        }

        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final document = snapshot.data!.docs[index];
            final data = document.data() as Map<String, dynamic>;
            final restaurants = RestroModel.fromMap(data);
            // final restroName = data['restroName'];
            // final restroPic = data['restroPic'];
            // final restroId = data['restroId'];

            return InkWell(
              onTap: () async {
                await ref
                    .watch(repoProvider)
                    .getAllWaitersData(restaurants.restroId);
                Navigator.pop(context);
                await Navigator.push(context, MaterialPageRoute(
                  builder: (context) {
                    return ScreenWaitersList(restaurant: restaurants);
                  },
                ));
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  width: size.width * 0.07,
                  decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: radius10,
                      image: DecorationImage(
                          colorFilter: ColorFilter.mode(
                              Colors.black.withOpacity(0.5), BlendMode.darken),
                          image: NetworkImage(restaurants.restroPic),
                          fit: BoxFit.cover)),
                  child: ListTile(
                    title: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          restaurants.restroName,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
