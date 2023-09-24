import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userProvider = Provider((ref) => UserVerification(
      auth: FirebaseAuth.instance,
      firestore: FirebaseFirestore.instance,
    ));

class UserVerification {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;
  UserVerification({
    required this.auth,
    required this.firestore,
  });
  // Future<void> userIdVerify({
  //   required BuildContext context,
  //   required String userId,
  //   required ProviderRef ref,
  // }) async {
  //   QuerySnapshot snapshot = await firestore
  //       .collection('restaurants')
  //       .doc(auth.currentUser!.uid)
  //       .collection('waiters')
  //       .where('userId', isEqualTo: userId)
  //       .get();

  //   if (snapshot.docs.isNotEmpty) {
  //     DocumentSnapshot userDoc = snapshot.docs.first;
  //     String userId = userDoc['userId'];
  //   }
  // }
  
}
