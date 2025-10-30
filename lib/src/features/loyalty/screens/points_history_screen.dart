import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/loyalty_models.dart';
import '../services/loyalty_service.dart';

class PointsHistoryScreen extends StatelessWidget {
  const PointsHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    dev.log('PointsHistoryScreen opened', name: 'PointsHistoryScreen', level: 800);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Puan Geçmişi'),
        backgroundColor: Colors.brown[700],
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<PointsTransaction>>(
        stream: context.read<LoyaltyService>().getTransactionHistory(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _buildErrorWidget();
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final transactions = snapshot.data ?? [];
          
          if (transactions.isEmpty) {
            return _buildEmptyHistory();
          }

          // Group transactions by date
          final groupedTransactions = _groupTransactionsByDate(transactions);

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: groupedTransactions.length,
            itemBuilder: (context, index) {
              final entry = groupedTransactions.entries.elementAt(index);
              return _buildDateGroup(entry.key, entry.value);
            },
          );
        },
      ),
    );
  }

  Widget _buildDateGroup(String date, List<PointsTransaction> transactions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            date,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.brown[700],
            ),
          ),
        ),
        ...transactions.map((transaction) => _buildTransactionCard(transaction)),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildTransactionCard(PointsTransaction transaction) {
    final isEarned = transaction.points > 0;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Transaction Icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (isEarned ? Colors.green : Colors.orange).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getTransactionIcon(transaction.type),
                color: isEarned ? Colors.green : Colors.orange,
                size: 24,
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Transaction Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.description,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDateTime(transaction.createdAt),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  if (transaction.metadata.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    _buildMetadataChips(transaction.metadata),
                  ],
                ],
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Points Display
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${isEarned ? '+' : '-'}${transaction.points.abs()}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isEarned ? Colors.green : Colors.orange,
                  ),
                ),
                Text(
                  'puan',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetadataChips(Map<String, dynamic> metadata) {
    return Wrap(
      spacing: 4,
      runSpacing: 2,
      children: metadata.entries.map((entry) {
        if (entry.key == 'source' || entry.key == 'orderId' || entry.key == 'cafeId') {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _formatMetadataValue(entry.key, entry.value),
              style: TextStyle(
                fontSize: 10,
                color: Colors.blue[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      }).toList(),
    );
  }

  Widget _buildEmptyHistory() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Henüz puan geçmişiniz yok',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Kahve sipariş etmeye başlayın\nve puan kazanmaya başlayın!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Geçmiş yüklenemedi',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Lütfen tekrar deneyin',
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Map<String, List<PointsTransaction>> _groupTransactionsByDate(List<PointsTransaction> transactions) {
    final Map<String, List<PointsTransaction>> grouped = {};
    
    for (final transaction in transactions) {
      final dateKey = _formatGroupDate(transaction.createdAt);
      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(transaction);
    }
    
    return grouped;
  }

  String _formatGroupDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final transactionDate = DateTime(date.year, date.month, date.day);
    
    if (transactionDate == today) {
      return 'Bugün';
    } else if (transactionDate == yesterday) {
      return 'Dün';
    } else if (now.difference(date).inDays < 7) {
      const weekdays = ['Pazartesi', 'Salı', 'Çarşamba', 'Perşembe', 'Cuma', 'Cumartesi', 'Pazar'];
      return weekdays[date.weekday - 1];
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _formatDateTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  IconData _getTransactionIcon(String type) {
    switch (type) {
      case 'earned':
        return Icons.add_circle_outline;
      case 'redeemed':
        return Icons.redeem;
      case 'bonus':
        return Icons.card_giftcard;
      case 'expired':
        return Icons.schedule;
      default:
        return Icons.swap_horiz;
    }
  }

  String _formatMetadataValue(String key, dynamic value) {
    switch (key) {
      case 'source':
        switch (value) {
          case 'qr_scan':
            return 'QR Kod';
          case 'order':
            return 'Sipariş';
          case 'review':
            return 'Değerlendirme';
          default:
            return value.toString();
        }
      case 'orderId':
        return 'Sipariş';
      case 'cafeId':
        return 'Kafe';
      default:
        return value.toString();
    }
  }
}