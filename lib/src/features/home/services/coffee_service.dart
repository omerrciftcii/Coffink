
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/coffee_model.dart';

class CoffeeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Coffee>> getCoffees() {
    return _firestore.collection('coffees').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Coffee.fromMap(doc.data(), doc.id)).toList();
    });
  }
}
