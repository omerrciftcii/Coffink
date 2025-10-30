import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../models/review_model.dart';
import '../services/review_service.dart';
import 'write_review_screen.dart';

class ReviewsListScreen extends StatefulWidget {
  final String targetId;
  final String targetType;
  final String targetName;

  const ReviewsListScreen({
    super.key,
    required this.targetId,
    required this.targetType,
    required this.targetName,
  });

  @override
  State<ReviewsListScreen> createState() => _ReviewsListScreenState();
}

class _ReviewsListScreenState extends State<ReviewsListScreen> {
  String _sortBy = 'newest'; // newest, oldest, highest, lowest

  @override
  void initState() {
    super.initState();
    // Configure Turkish locale for timeago
    timeago.setLocaleMessages('tr', timeago.TrMessages());
    
    dev.log('ReviewsListScreen initialized for ${widget.targetType}: ${widget.targetName}', 
             name: 'ReviewsListScreen', level: 800);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Değerlendirmeler'),
        backgroundColor: Colors.brown[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: _showSortOptions,
          ),
        ],
      ),
      body: Column(
        children: [
          // Review Summary
          StreamBuilder<ReviewSummary>(
            stream: context.read<ReviewService>().getReviewSummary(widget.targetId, widget.targetType),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  child: Text('Error: ${snapshot.error}'),
                );
              }

              final summary = snapshot.data ?? ReviewSummary(
                averageRating: 0.0,
                totalReviews: 0,
                ratingDistribution: {5: 0, 4: 0, 3: 0, 2: 0, 1: 0},
              );

              return _buildReviewSummary(summary);
            },
          ),

          const Divider(),

          // Reviews List
          Expanded(
            child: StreamBuilder<List<Review>>(
              stream: context.read<ReviewService>().getReviewsForTarget(widget.targetId, widget.targetType),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final reviews = snapshot.data ?? [];
                
                if (reviews.isEmpty) {
                  return _buildEmptyReviews();
                }

                final sortedReviews = _sortReviews(reviews);

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: sortedReviews.length,
                  itemBuilder: (context, index) {
                    return _buildReviewItem(sortedReviews[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _writeReview,
        backgroundColor: Colors.brown[700],
        foregroundColor: Colors.white,
        icon: const Icon(Icons.edit),
        label: const Text('Yorum Yaz'),
      ),
    );
  }

  Widget _buildReviewSummary(ReviewSummary summary) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Average Rating Display
          Column(
            children: [
              Text(
                summary.averageRating.toStringAsFixed(1),
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown[700],
                ),
              ),
              RatingBarIndicator(
                rating: summary.averageRating,
                itemBuilder: (context, index) => Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                itemCount: 5,
                itemSize: 24.0,
              ),
              const SizedBox(height: 4),
              Text(
                '${summary.totalReviews} değerlendirme',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
          
          const SizedBox(width: 32),
          
          // Rating Distribution
          Expanded(
            child: Column(
              children: List.generate(5, (index) {
                final stars = 5 - index;
                final count = summary.ratingDistribution[stars] ?? 0;
                final percentage = summary.getRatingPercentage(stars);
                
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Text('$stars'),
                      const SizedBox(width: 4),
                      Icon(Icons.star, size: 16, color: Colors.amber),
                      const SizedBox(width: 8),
                      Expanded(
                        child: LinearProgressIndicator(
                          value: percentage,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.brown[700]!,
                          ),
                          minHeight: 8,
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 30,
                        child: Text(
                          '$count',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyReviews() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.rate_review_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Henüz değerlendirme yok',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'İlk değerlendirmeyi siz yapın!',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewItem(Review review) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Info and Rating
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.brown[700],
                  backgroundImage: review.userAvatar.isNotEmpty 
                      ? NetworkImage(review.userAvatar) 
                      : null,
                  child: review.userAvatar.isEmpty 
                      ? Text(
                          review.userName.isNotEmpty ? review.userName[0].toUpperCase() : 'A',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.userName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        timeago.format(review.createdAt, locale: 'tr'),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                RatingBarIndicator(
                  rating: review.rating,
                  itemBuilder: (context, index) => Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  itemCount: 5,
                  itemSize: 18.0,
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Review Comment
            Text(
              review.comment,
              style: const TextStyle(fontSize: 15, height: 1.4),
            ),
            
            // Review Photos (if any)
            if (review.photos.isNotEmpty) ...[
              const SizedBox(height: 12),
              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: review.photos.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.only(right: 8),
                      width: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          review.photos[index],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[200],
                              child: const Icon(Icons.image_not_supported),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
            
            // Review Metadata (order info, etc.)
            if (review.metadata.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: review.metadata.entries.map((entry) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.brown[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.brown[200]!),
                    ),
                    child: Text(
                      '${entry.key}: ${entry.value}',
                      style: TextStyle(
                        color: Colors.brown[800],
                        fontSize: 12,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  List<Review> _sortReviews(List<Review> reviews) {
    final sorted = List<Review>.from(reviews);
    
    switch (_sortBy) {
      case 'newest':
        sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'oldest':
        sorted.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case 'highest':
        sorted.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'lowest':
        sorted.sort((a, b) => a.rating.compareTo(b.rating));
        break;
    }
    
    return sorted;
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Sıralama',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildSortOption('newest', 'En Yeni', Icons.schedule),
              _buildSortOption('oldest', 'En Eski', Icons.history),
              _buildSortOption('highest', 'En Yüksek Puan', Icons.arrow_upward),
              _buildSortOption('lowest', 'En Düşük Puan', Icons.arrow_downward),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSortOption(String value, String label, IconData icon) {
    final isSelected = _sortBy == value;
    
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? Colors.brown[700] : Colors.grey[600],
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.brown[700] : Colors.black,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: isSelected ? Icon(Icons.check, color: Colors.brown[700]) : null,
      onTap: () {
        setState(() {
          _sortBy = value;
        });
        Navigator.pop(context);
        dev.log('Sort option changed to: $value', name: 'ReviewsListScreen', level: 800);
      },
    );
  }

  Future<void> _writeReview() async {
    try {
      // Check if user already has a review for this target
      final reviewService = context.read<ReviewService>();
      final existingReview = await reviewService.getUserReviewForTarget(
        widget.targetId, 
        widget.targetType
      );
      
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WriteReviewScreen(
              targetId: widget.targetId,
              targetType: widget.targetType,
              targetName: widget.targetName,
              existingReview: existingReview,
            ),
          ),
        );
      }
    } catch (e) {
      dev.log('Error checking existing review', name: 'ReviewsListScreen', error: e, level: 1000);
      // Continue to write review screen anyway
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WriteReviewScreen(
              targetId: widget.targetId,
              targetType: widget.targetType,
              targetName: widget.targetName,
            ),
          ),
        );
      }
    }
  }
}