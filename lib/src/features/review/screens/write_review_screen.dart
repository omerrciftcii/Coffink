import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import '../models/review_model.dart';
import '../services/review_service.dart';

class WriteReviewScreen extends StatefulWidget {
  final String targetId;
  final String targetType;
  final String targetName;
  final String? existingReviewId;
  final Review? existingReview;

  const WriteReviewScreen({
    super.key,
    required this.targetId,
    required this.targetType,
    required this.targetName,
    this.existingReviewId,
    this.existingReview,
  });

  @override
  State<WriteReviewScreen> createState() => _WriteReviewScreenState();
}

class _WriteReviewScreenState extends State<WriteReviewScreen> {
  final _formKey = GlobalKey<FormState>();
  final _commentController = TextEditingController();
  double _rating = 5.0;
  bool _isSubmitting = false;
  List<String> _photos = [];

  @override
  void initState() {
    super.initState();
    
    // Pre-fill form if editing existing review
    if (widget.existingReview != null) {
      _rating = widget.existingReview!.rating;
      _commentController.text = widget.existingReview!.comment;
      // Safely copy photos list
      try {
        _photos = List<String>.from(widget.existingReview!.photos);
      } catch (e) {
        // If copying fails, start with empty list
        _photos = [];
        dev.log('Error copying photos from existing review: $e', 
                 name: 'WriteReviewScreen', level: 900);
      }
    }
    
    dev.log('WriteReviewScreen initialized for ${widget.targetType}: ${widget.targetName}', 
             name: 'WriteReviewScreen', level: 800);
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingReview != null;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Yorumu Düzenle' : 'Yorum Yaz'),
        backgroundColor: Colors.brown[700],
        foregroundColor: Colors.white,
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _showDeleteConfirmation,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Target Info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      widget.targetType == 'coffee' ? Icons.coffee : Icons.store,
                      size: 40,
                      color: Colors.brown[700],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.targetName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            widget.targetType == 'coffee' ? 'Kahve' : 'Kafe',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Rating Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Puanınız',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: Column(
                        children: [
                          RatingBar.builder(
                            initialRating: _rating,
                            minRating: 1,
                            direction: Axis.horizontal,
                            allowHalfRating: true,
                            itemCount: 5,
                            itemSize: 40,
                            itemBuilder: (context, _) => Icon(
                              Icons.star,
                              color: Colors.amber,
                            ),
                            onRatingUpdate: (rating) {
                              setState(() {
                                _rating = rating;
                              });
                              dev.log('Rating updated: $rating', 
                                       name: 'WriteReviewScreen', level: 800);
                            },
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _getRatingText(_rating),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.brown[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Comment Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Yorumunuz',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _commentController,
                      maxLines: 5,
                      maxLength: 500,
                      decoration: InputDecoration(
                        hintText: 'Deneyiminizi paylaşın...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.brown[700]!),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Lütfen yorumunuzu yazın';
                        }
                        if (value.trim().length < 10) {
                          return 'Yorum en az 10 karakter olmalıdır';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Photo Section (placeholder for future implementation)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Fotoğraflar',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '(İsteğe bağlı)',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      height: 80,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate_outlined,
                              color: Colors.grey[400],
                              size: 32,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Yakında aktif olacak',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitReview,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown[700],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        isEditing ? 'Yorumu Güncelle' : 'Yorumu Gönder',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getRatingText(double rating) {
    if (rating >= 4.5) return 'Mükemmel';
    if (rating >= 3.5) return 'Çok İyi';
    if (rating >= 2.5) return 'İyi';
    if (rating >= 1.5) return 'Orta';
    return 'Kötü';
  }

  Future<void> _submitReview() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final reviewService = context.read<ReviewService>();
      
      if (widget.existingReview != null) {
        // Update existing review
        await reviewService.updateReview(
          reviewId: widget.existingReview!.id,
          rating: _rating,
          comment: _commentController.text.trim(),
          photos: _photos,
        );
        
        dev.log('Review updated successfully', name: 'WriteReviewScreen', level: 800);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Yorumunuz güncellendi!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // Submit new review
        await reviewService.submitReview(
          targetId: widget.targetId,
          targetType: widget.targetType,
          rating: _rating,
          comment: _commentController.text.trim(),
          photos: _photos,
        );
        
        dev.log('Review submitted successfully', name: 'WriteReviewScreen', level: 800);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Yorumunuz gönderildi!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
      
      if (mounted) {
        Navigator.of(context).pop();
      }
    } on TypeError catch (e, stackTrace) {
      // Handle type casting errors specifically
      dev.log('Type error in review submission', name: 'WriteReviewScreen', error: e, level: 1000);
      
      // Report to Crashlytics
      FirebaseCrashlytics.instance.recordError(
        'Type casting error in WriteReviewScreen: $e',
        stackTrace,
        fatal: false,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veri türü hatası oluştu. Lütfen tekrar deneyin.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e, stackTrace) {
      dev.log('Error submitting review', name: 'WriteReviewScreen', error: e, level: 1000);
      
      // Report to Crashlytics
      FirebaseCrashlytics.instance.recordError(
        'Error in WriteReviewScreen: $e',
        stackTrace,
        fatal: false,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<void> _showDeleteConfirmation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Yorumu Sil'),
          content: const Text('Bu yorumu silmek istediğinizden emin misiniz?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('İptal'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Sil'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _deleteReview();
    }
  }

  Future<void> _deleteReview() async {
    if (widget.existingReview == null) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final reviewService = context.read<ReviewService>();
      await reviewService.deleteReview(widget.existingReview!.id);
      
      dev.log('Review deleted successfully', name: 'WriteReviewScreen', level: 800);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Yorumunuz silindi'),
            backgroundColor: Colors.orange,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      dev.log('Error deleting review', name: 'WriteReviewScreen', error: e, level: 1000);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Silme hatası: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}