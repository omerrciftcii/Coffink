
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../features/auth/services/auth_service.dart';
import '../models/coffee_model.dart';
import '../services/coffee_service.dart';
import '../services/favorites_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _widgetOptions = <Widget>[
    const CoffeeList(),
    const FavoritesScreen(),
    const Center(child: Text('Profile')),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Coffink'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => authService.signOut(),
          ),
        ],
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.coffee),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

class CoffeeList extends StatelessWidget {
  const CoffeeList({super.key});

  @override
  Widget build(BuildContext context) {
    final favoritesService = Provider.of<FavoritesService>(context);
    return StreamProvider<List<Coffee>>.value(
      value: CoffeeService().getCoffees(),
      initialData: const [],
      child: Consumer<List<Coffee>>(
        builder: (context, coffees, child) {
          return ListView.builder(
            itemCount: coffees.length,
            itemBuilder: (context, index) {
              final coffee = coffees[index];
              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  leading: Image.network(
                    coffee.imageUrl,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                  title: Text(coffee.name),
                  subtitle: Text(coffee.description),
                  trailing: StreamBuilder<bool>(
                    stream: favoritesService.isFavorite(coffee.id),
                    builder: (context, snapshot) {
                      final isFavorite = snapshot.data ?? false;
                      return IconButton(
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : null,
                        ),
                        onPressed: () {
                          if (isFavorite) {
                            favoritesService.removeFromFavorites(coffee.id);
                          } else {
                            favoritesService.addToFavorites(coffee.id);
                          }
                        },
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favoritesService = Provider.of<FavoritesService>(context);
    return StreamProvider<List<Coffee>>.value(
      value: favoritesService.getFavorites(),
      initialData: const [],
      child: Consumer<List<Coffee>>(
        builder: (context, favorites, child) {
          if (favorites.isEmpty) {
            return const Center(
              child: Text('You have no favorites yet.'),
            );
          }
          return ListView.builder(
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final coffee = favorites[index];
              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  leading: Image.network(
                    coffee.imageUrl,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                  title: Text(coffee.name),
                  subtitle: Text(coffee.description),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      favoritesService.removeFromFavorites(coffee.id);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
