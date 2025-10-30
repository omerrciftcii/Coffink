import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../models/loyalty_models.dart';
import '../services/loyalty_service.dart';

class RewardsScreen extends StatefulWidget {
  const RewardsScreen({super.key});

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> {
  UserPointsStats? _userStats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserStats();
    dev.log('RewardsScreen initialized', name: 'RewardsScreen', level: 800);
  }

  Future<void> _loadUserStats() async {
    try {
      final loyaltyService = context.read<LoyaltyService>();
      final stats = await loyaltyService.getUserPointsStats();
      
      setState(() {
        _userStats = stats;
        _isLoading = false;
      });
    } catch (e) {
      dev.log('Error loading user stats', name: 'RewardsScreen', error: e, level: 1000);
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ödüller'),
        backgroundColor: Colors.brown[700],
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Points Display
          if (!_isLoading && _userStats != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.brown[700],
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.stars,
                    color: Colors.amber[300],
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${_userStats!.totalPoints} Puan',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          
          // Rewards List
          Expanded(
            child: StreamBuilder<List<PointsReward>>(
              stream: context.read<LoyaltyService>().getAvailableRewards(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return _buildErrorWidget();
                }

                if (snapshot.connectionState == ConnectionState.waiting || _isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final rewards = snapshot.data ?? [];
                
                if (rewards.isEmpty) {
                  return _buildEmptyRewards();
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: rewards.length,
                  itemBuilder: (context, index) {
                    return _buildRewardCard(rewards[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardCard(PointsReward reward) {
    final canAfford = _userStats != null && _userStats!.totalPoints >= reward.requiredPoints;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: canAfford ? () => _showRewardDialog(reward) : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Reward Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: reward.imageUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey[200],
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.brown[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.card_giftcard,
                      color: Colors.brown,
                      size: 40,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Reward Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reward.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      reward.description,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getRewardTypeColor(reward.type).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _getRewardTypeLabel(reward.type),
                            style: TextStyle(
                              color: _getRewardTypeColor(reward.type),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        if (reward.expiresAt != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.orange.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Son: ${_formatExpiryDate(reward.expiresAt!)}',
                              style: const TextStyle(
                                color: Colors.orange,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Points and Action
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.stars,
                        color: canAfford ? Colors.amber[600] : Colors.grey[400],
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        reward.requiredPoints.toString(),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: canAfford ? Colors.brown[700] : Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (canAfford)
                    ElevatedButton(
                      onPressed: () => _showRewardDialog(reward),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.brown[700],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      child: const Text(
                        'Kullan',
                        style: TextStyle(fontSize: 12),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Yetersiz Puan',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyRewards() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.card_giftcard_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Henüz ödül bulunmuyor',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Yeni ödüller için geri dönün!',
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
            'Ödüller yüklenemedi',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              setState(() {}); // Trigger rebuild
            },
            child: const Text('Tekrar Dene'),
          ),
        ],
      ),
    );
  }

  Future<void> _showRewardDialog(PointsReward reward) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(reward.name),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (reward.imageUrl.isNotEmpty) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: reward.imageUrl,
                    width: double.infinity,
                    height: 120,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) => Container(
                      height: 120,
                      color: Colors.grey[200],
                      child: const Icon(Icons.card_giftcard, size: 60),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              Text(
                reward.description,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.stars, color: Colors.amber[600], size: 20),
                  const SizedBox(width: 4),
                  Text(
                    '${reward.requiredPoints} puan harcanacak',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Kalan puanınız: ${(_userStats!.totalPoints - reward.requiredPoints)} puan',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown[700],
                foregroundColor: Colors.white,
              ),
              child: const Text('Kullan'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      await _redeemReward(reward);
    }
  }

  Future<void> _redeemReward(PointsReward reward) async {
    try {
      final loyaltyService = context.read<LoyaltyService>();
      await loyaltyService.redeemReward(reward.id);
      
      // Reload user stats
      await _loadUserStats();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${reward.name} başarıyla kullanıldı!'),
            backgroundColor: Colors.green,
          ),
        );
      }
      
      dev.log('Reward redeemed successfully: ${reward.name}', 
               name: 'RewardsScreen', level: 800);
    } catch (e) {
      dev.log('Error redeeming reward', name: 'RewardsScreen', error: e, level: 1000);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Color _getRewardTypeColor(String type) {
    switch (type) {
      case 'discount':
        return Colors.blue;
      case 'freeItem':
        return Colors.green;
      case 'special':
        return Colors.purple;
      default:
        return Colors.brown;
    }
  }

  String _getRewardTypeLabel(String type) {
    switch (type) {
      case 'discount':
        return 'İndirim';
      case 'freeItem':
        return 'Bedava Ürün';
      case 'special':
        return 'Özel';
      default:
        return 'Diğer';
    }
  }

  String _formatExpiryDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} gün';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} saat';
    } else {
      return 'Süresi doldu';
    }
  }
}