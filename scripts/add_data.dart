
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:myapp/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final firestore = FirebaseFirestore.instance;

  final coffees = [
    {
      'name': 'Espresso',
      'description': 'A concentrated coffee beverage brewed by forcing hot water through finely-ground coffee beans.',
      'imageUrl': 'https://images.unsplash.com/photo-1541167760496-1628856ab772',
    },
    {
      'name': 'Latte',
      'description': 'A coffee drink made with espresso and steamed milk.',
      'imageUrl': 'https://images.unsplash.com/photo-1556742059-4f95c5f4f5a3',
    },
    {
      'name': 'Cappuccino',
      'description': 'An espresso-based coffee drink that originated in Italy, and is traditionally prepared with steamed milk foam.',
      'imageUrl': 'https://images.unsplash.com/photo-1517244493436-b0ae513027a8',
    },
    {
      'name': 'Americano',
      'description': 'A type of coffee drink prepared by diluting an espresso with hot water, giving it a similar strength to, but different flavor from, traditionally brewed coffee.',
      'imageUrl': 'https://images.unsplash.com/photo-1517701559448-347a8a2a89c9',
    },
    {
      'name': 'Macchiato',
      'description': 'An espresso coffee drink with a small amount of milk, usually foamed.',
      'imageUrl': 'https://images.unsplash.com/photo-1572442345532-6804a80a259c',
    },
  ];

  for (final coffee in coffees) {
    await firestore.collection('coffees').add(coffee);
  }

  print('Data added successfully!');
}
