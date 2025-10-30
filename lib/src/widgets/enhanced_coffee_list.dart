import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/data_service.dart';
import '../features/home/models/coffee_model.dart';
import '../utils/logger.dart';

/// Example widget demonstrating enhanced error handling with DataService
class EnhancedCoffeeList extends StatefulWidget {
  final String? category;
  
  const EnhancedCoffeeList({super.key, this.category});

  @override
  State<EnhancedCoffeeList> createState() => _EnhancedCoffeeListState();
}

class _EnhancedCoffeeListState extends State<EnhancedCoffeeList> {
  List<Coffee> _coffees = [];
  bool _isLoading = false;
  String? _errorMessage;
  int _retryCount = 0;

  @override
  void initState() {
    super.initState();
    _loadCoffees();
  }

  @override
  void didUpdateWidget(EnhancedCoffeeList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.category != widget.category) {
      _loadCoffees();
    }
  }

  Future<void> _loadCoffees() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final dataService = Provider.of<DataService>(context, listen: false);
      Logger.info('Loading coffees with enhanced error handling', name: 'EnhancedCoffeeList');
      
      final coffees = await dataService.getCoffees(category: widget.category);
      
      if (mounted) {
        setState(() {
          _coffees = coffees;
          _isLoading = false;
          _retryCount = 0;
        });
        
        Logger.info('Successfully loaded ${coffees.length} coffees', name: 'EnhancedCoffeeList');
      }
    } catch (e) {
      Logger.error('Error loading coffees: $e', name: 'EnhancedCoffeeList');
      
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = _getErrorMessage(e);
          _retryCount++;
        });
      }
    }
  }

  String _getErrorMessage(dynamic error) {
    if (error is DataServiceException) {
      return 'Veri yüklenirken hata oluştu: ${error.message}';
    } else if (error is NetworkException) {
      return 'İnternet bağlantısı sorunu: ${error.message}';
    } else if (error is DataParsingException) {
      return 'Veri işlenirken hata oluştu: ${error.message}';
    } else {
      return 'Beklenmeyen bir hata oluştu. Lütfen tekrar deneyin.';
    }
  }

  Future<void> _refreshData() async {
    try {
      final dataService = Provider.of<DataService>(context, listen: false);
      await dataService.refreshData();
      await _loadCoffees();
    } catch (e) {
      Logger.error('Error refreshing data: $e', name: 'EnhancedCoffeeList');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Veri yenilenemedi: ${_getErrorMessage(e)}'),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'Tekrar Dene',
            textColor: Colors.white,
            onPressed: _refreshData,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_isLoading && _coffees.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Kahveler yükleniyor...'),
          ],
        ),
      );
    }

    if (_errorMessage != null && _coffees.isEmpty) {
      return _buildErrorWidget();
    }

    if (_coffees.isEmpty) {
      return _buildEmptyWidget();
    }

    return Column(
      children: [
        if (_errorMessage != null) _buildErrorBanner(),
        Expanded(
          child: ListView.builder(
            itemCount: _coffees.length,
            itemBuilder: (context, index) {
              final coffee = _coffees[index];
              return _buildCoffeeItem(coffee);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Hata Oluştu',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _loadCoffees,
                  icon: const Icon(Icons.refresh),
                  label: Text('Tekrar Dene${_retryCount > 0 ? ' ($_retryCount)' : ''}'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: _refreshData,
                  icon: const Icon(Icons.sync),
                  label: const Text('Yenile'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      color: Colors.orange[100],
      child: Row(
        children: [
          Icon(Icons.warning, color: Colors.orange[700], size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorMessage!,
              style: TextStyle(
                color: Colors.orange[700],
                fontSize: 14,
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _errorMessage = null;
              });
            },
            icon: Icon(Icons.close, color: Colors.orange[700], size: 20),
            constraints: const BoxConstraints(),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.coffee_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Kahve Bulunamadı',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.category != null 
                ? '${widget.category} kategorisinde kahve bulunmuyor'
                : 'Henüz kahve eklenmemiş',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadCoffees,
            icon: const Icon(Icons.refresh),
            label: const Text('Yenile'),
          ),
        ],
      ),
    );
  }

  Widget _buildCoffeeItem(Coffee coffee) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            coffee.photoUrl,
            width: 60,
            height: 60,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 60,
                height: 60,
                color: Colors.grey[300],
                child: const Icon(Icons.coffee, size: 30),
              );
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                width: 60,
                height: 60,
                color: Colors.grey[100],
                child: const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              );
            },
          ),
        ),
        title: Text(
          coffee.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              coffee.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  '${coffee.basePrice.toStringAsFixed(2)} ₺',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: coffee.isAvailable 
                        ? Colors.green[100] 
                        : Colors.red[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    coffee.isAvailable ? 'Mevcut' : 'Tükendi',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: coffee.isAvailable 
                          ? Colors.green[700] 
                          : Colors.red[700],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: coffee.isAvailable 
            ? Icon(
                Icons.arrow_forward_ios,
                color: Theme.of(context).colorScheme.primary,
              )
            : null,
        onTap: coffee.isAvailable 
            ? () {
                // Navigate to coffee detail
                Logger.info('Coffee selected: ${coffee.name}', name: 'EnhancedCoffeeList');
              }
            : null,
      ),
    );
  }
}