
import 'package:flutter/material.dart';

import '../../profile/services/user_profile_service.dart';
import '../../home/screens/home_screen.dart';

class TastePreferenceSurvey extends StatefulWidget {
  const TastePreferenceSurvey({super.key});

  @override
  State<TastePreferenceSurvey> createState() => _TastePreferenceSurveyState();
}

class _TastePreferenceSurveyState extends State<TastePreferenceSurvey> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  
  String? _coffeeStrength;
  String? _milkPreference;
  final List<String> _favoriteTypes = [];
  final List<String> _flavorProfile = [];
  double _sweetness = 3.0;
  
  final List<String> _coffeeTypes = [
    'Espresso',
    'Americano',
    'Cappuccino',
    'Latte',
    'Macchiato',
    'Mocha',
    'Soğuk Dem',
    'Frappe'
  ];
  
  final List<String> _flavors = [
    'Meyveli',
    'Cevizli',
    'Çikolatamsı',
    'Çiçeksi',
    'Baharatlı',
    'Karamelli',
    'Vanilyali',
    'Topraklı'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lezzet Tercihleri'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        leading: _currentPage > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _previousPage,
              )
            : null,
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: (_currentPage + 1) / 5,
            backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
            valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) => setState(() => _currentPage = index),
              children: [
                _buildCoffeeStrengthPage(),
                _buildMilkPreferencePage(),
                _buildCoffeeTypesPage(),
                _buildFlavorProfilePage(),
                _buildSweetnessPage(),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentPage > 0)
                  TextButton(
                    onPressed: _previousPage,
                    child: const Text('Önceki'),
                  )
                else
                  const SizedBox.shrink(),
                ElevatedButton(
                  onPressed: _canProceed() ? _nextPage : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                  child: Text(_currentPage == 4 ? 'Tamamla' : 'Sonraki'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoffeeStrengthPage() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Kahvenizi nasıl seversiniz?',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          _buildRadioOption('Hafif', _coffeeStrength, (value) => setState(() => _coffeeStrength = value)),
          _buildRadioOption('Orta', _coffeeStrength, (value) => setState(() => _coffeeStrength = value)),
          _buildRadioOption('Güçlü', _coffeeStrength, (value) => setState(() => _coffeeStrength = value)),
          _buildRadioOption('Çok Güçlü', _coffeeStrength, (value) => setState(() => _coffeeStrength = value)),
        ],
      ),
    );
  }

  Widget _buildMilkPreferencePage() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Süt tercihiniz nedir?',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          _buildRadioOption('Tam Yağlı Süt', _milkPreference, (value) => setState(() => _milkPreference = value)),
          _buildRadioOption('Yulaf Sütü', _milkPreference, (value) => setState(() => _milkPreference = value)),
          _buildRadioOption('Badem Sütü', _milkPreference, (value) => setState(() => _milkPreference = value)),
          _buildRadioOption('Soya Sütü', _milkPreference, (value) => setState(() => _milkPreference = value)),
          _buildRadioOption('Sütsiz', _milkPreference, (value) => setState(() => _milkPreference = value)),
        ],
      ),
    );
  }

  Widget _buildCoffeeTypesPage() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Favori kahve türlerinizi seçin:',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: _coffeeTypes.length,
              itemBuilder: (context, index) {
                final type = _coffeeTypes[index];
                final isSelected = _favoriteTypes.contains(type);
                return FilterChip(
                  label: Text(type),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _favoriteTypes.add(type);
                      } else {
                        _favoriteTypes.remove(type);
                      }
                    });
                  },
                  selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlavorProfilePage() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Hangi lezzetleri seversiniz?',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: _flavors.length,
              itemBuilder: (context, index) {
                final flavor = _flavors[index];
                final isSelected = _flavorProfile.contains(flavor);
                return FilterChip(
                  label: Text(flavor),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _flavorProfile.add(flavor);
                      } else {
                        _flavorProfile.remove(flavor);
                      }
                    });
                  },
                  selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSweetnessPage() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Kahvenizi ne kadar tatlı seversiniz?',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 48),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Tatlı Değil'),
              Text('Çok Tatlı'),
            ],
          ),
          Slider(
            value: _sweetness,
            min: 1.0,
            max: 5.0,
            divisions: 4,
            label: _getSweetnessLabel(_sweetness),
            activeColor: Theme.of(context).colorScheme.primary,
            onChanged: (value) => setState(() => _sweetness = value),
          ),
          Center(
            child: Text(
              _getSweetnessLabel(_sweetness),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRadioOption(String title, String? groupValue, Function(String?) onChanged) {
    return RadioListTile<String>(
      title: Text(title),
      value: title,
      groupValue: groupValue,
      onChanged: onChanged,
      activeColor: Theme.of(context).colorScheme.primary,
      toggleable: true,
    );
  }

  String _getSweetnessLabel(double value) {
    switch (value.round()) {
      case 1: return 'Şekersiz';
      case 2: return 'Az Tatlı';
      case 3: return 'Orta Tatlı';
      case 4: return 'Tatlı';
      case 5: return 'Çok Tatlı';
      default: return 'Orta Tatlı';
    }
  }

  bool _canProceed() {
    switch (_currentPage) {
      case 0: return _coffeeStrength != null;
      case 1: return _milkPreference != null;
      case 2: return _favoriteTypes.isNotEmpty;
      case 3: return _flavorProfile.isNotEmpty;
      case 4: return true;
      default: return false;
    }
  }

  void _previousPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _nextPage() async {
    if (_currentPage == 4) {
      await _savePreferences();
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _savePreferences() async {
    final preferences = {
      'coffeeStrength': _coffeeStrength,
      'milkPreference': _milkPreference,
      'favoriteTypes': _favoriteTypes,
      'flavorProfile': _flavorProfile,
      'sweetness': _sweetness,
      'completedAt': DateTime.now().toIso8601String(),
    };

    try {
      await UserProfileService().updateTastePreferences(preferences);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tercihleri kaydetme hatası: $e')),
        );
      }
    }
  }
}
