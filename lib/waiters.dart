import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:restro_range_waiter/const/colors.dart';
import 'package:restro_range_waiter/const/size_radius.dart';
import 'package:restro_range_waiter/home_waiter.dart';
import 'package:restro_range_waiter/launch_screen.dart';
import 'package:restro_range_waiter/models/restro_model.dart';
import 'package:restro_range_waiter/models/waiter_model.dart';
import 'package:restro_range_waiter/repository/repo.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScreenWaitersList extends ConsumerStatefulWidget {
  // final String? restroId;
  // final String? restroName;
  // final String? waiterPic;
  // final String? waiterName;
  final RestroModel restaurant;
  static const routeName = '/waiterList';
  ScreenWaitersList({super.key, required this.restaurant});

  @override
  ConsumerState<ScreenWaitersList> createState() => _ScreenWaitersListState();
}

class _ScreenWaitersListState extends ConsumerState<ScreenWaitersList> {
  final userController = TextEditingController();

  Future<bool> clearListOnBackPress() async {
    ref.read(repoProvider).waitersData.clear();
    await Navigator.push(
        context, MaterialPageRoute(builder: (context) => LaunchScreen()));
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        return clearListOnBackPress();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
              onPressed: () {
                ref.read(repoProvider).waitersData.clear();
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back)),
          title: Text("${widget.restaurant.restroName} waiters"),
        ),
        body: SafeArea(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, crossAxisSpacing: 20, mainAxisSpacing: 20),
            itemCount: ref.read(repoProvider).waitersData.length,
            itemBuilder: (context, index) {
              final data = ref.read(repoProvider).waitersData[index];
              final waiterName = data['waiterName'];
              final waiterPic = data['waiterPic'];
              final waiters = WaiterModel.fromMap(data);
              return InkWell(
                onTap: () async {
                  await userIdCheck(waiter: waiters);
                },
                child: Card(
                  shape: RoundedRectangleBorder(borderRadius: radius10),
                  elevation: 5,
                  borderOnForeground: true,
                  child: Stack(
                    alignment: Alignment.center,
                    fit: StackFit.loose,
                    children: [
                      SizedBox(
                        width: size.width,
                        height: size.height,
                        child: ClipRRect(
                            borderRadius: radius10,
                            child: CachedNetworkImage(
                                imageUrl: waiterPic, fit: BoxFit.cover)),
                      ),
                      Positioned(
                          bottom: 0,
                          child: Container(
                            decoration: const BoxDecoration(
                                color: hintColor,
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    topRight: Radius.circular(10))),
                            height: size.height * 0.05,
                            child: Center(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: Text(
                                  waiterName,
                                  style: const TextStyle(
                                      color: textColor,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 20),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ))
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  userIdCheck({required WaiterModel waiter}) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Hi ${waiter.waiterName}! \n Please Enter Your UserId to Proceed',
            style: TextStyle(
                color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          elevation: 5,
          backgroundColor: primColor,
          actionsAlignment: MainAxisAlignment.center,
          content: const Row(
            children: [
              Icon(Icons.info_outline),
              Expanded(
                child: Text(
                  'Personal UserID is provided by your Restaurant',
                  textAlign: TextAlign.left,
                ),
              ),
            ],
          ),
          actions: [
            Column(
              children: [
                TextFormField(
                  controller: userController,
                  decoration:
                      const InputDecoration(hintText: 'Enter UserID here'),
                ),
                height10,
                ElevatedButton(
                    onPressed: () async {
                      if (userController.text == waiter.userId) {
                        await saveId(waiterId:  waiter.userId,restroId: waiter.restroId);
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => WaiterHome(
                            waiter: waiter,
                          ),
                        ));
                      } else {
                        Navigator.pop(context);
                      }
                    },
                    child: const Text(
                      'Confirm',
                      style: TextStyle(color: backgroundColor),
                    ))
              ],
            )
          ],
        );
      },
    );
  }

  saveId({required String waiterId,required String restroId}) async {
    SharedPreferences userId = await SharedPreferences.getInstance();
    userId.setString('userId', waiterId);
    userId.setString('restroId', restroId);
  }
}
