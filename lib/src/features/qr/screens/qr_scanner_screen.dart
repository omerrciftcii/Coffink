

// import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../profile/services/user_profile_service.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  MobileScannerController? controller;
  String? scannedData;
  bool isProcessing = false;

  @override
  void initState() {
    super.initState();
    controller = MobileScannerController();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Custom header section for QR Scanner
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.primaryContainer,
                Theme.of(context).colorScheme.secondaryContainer,
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.qr_code_scanner_rounded,
                      color: Theme.of(context).colorScheme.onPrimary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'QR Tarayıcı',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.flash_on_rounded),
                      color: Theme.of(context).colorScheme.onPrimary,
                      onPressed: () async {
                        await controller?.toggleTorch();
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.flip_camera_ios_rounded),
                      color: Theme.of(context).colorScheme.onPrimary,
                      onPressed: () async {
                        await controller?.switchCamera();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: kIsWeb ? _buildWebView() : _buildMobileView(),
        ),
      ],
    );
  }

  Widget _buildWebView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.qr_code_scanner,
            size: 100,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
          ),
          const SizedBox(height: 24),
          const Text(
            'QR Tarayıcı Web\'de Desteklenmiyor',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            'QR kod taramak için mobil cihazınızı kullanın',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => _simulateQRScan(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
            child: const Text('Test QR Tarama (Demo)'),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileView() {
    return Column(
      children: [
        Expanded(
          flex: 4,
          child: MobileScanner(
            controller: controller,
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (!isProcessing && barcode.rawValue != null) {
                  _processQRCode(barcode.rawValue!);
                  break;
                }
              }
            },
          ),
        ),
        Expanded(
          flex: 1,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.surface,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isProcessing) ...[
                  const CircularProgressIndicator(),
                  const SizedBox(height: 12),
                  const Text('QR kod işleniyor...'),
                ] else ...[
                  Icon(
                    Icons.qr_code_scanner,
                    size: 40,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Partner kafe QR kodunu tarayın',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Kahve puanları kazanmak için QR kodu kameranın içine yerleştirin',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _simulateQRScan() {
    // Simulate a partner café QR code for web testing
    _processQRCode('COFFINK_PARTNER_CAFE_12345_POINTS_50');
  }

  Future<void> _processQRCode(String qrData) async {
    if (isProcessing) return;
    
    setState(() {
      isProcessing = true;
      scannedData = qrData;
    });

    try {
      // Parse QR code data
      final qrResult = _parseQRCode(qrData);
      
      if (qrResult != null) {
        // Award points to user
        final userProfileService = Provider.of<UserProfileService>(context, listen: false);
        await userProfileService.addCoffeePoints(qrResult['points']);
        
        // Show success dialog
        if (mounted) {
          await _showSuccessDialog(qrResult);
        }
      } else {
        // Invalid QR code
        if (mounted) {
          _showErrorDialog('Geçersiz QR kod', 'Bu QR kod Coffink partner kafesi QR kodu değil.');
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Hata', 'QR kod işlenirken bir hata oluştu: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          isProcessing = false;
        });
      }
    }
  }

  Map<String, dynamic>? _parseQRCode(String qrData) {
    try {
      // Expected format: COFFINK_PARTNER_CAFE_{CAFE_ID}_POINTS_{POINTS}
      if (qrData.startsWith('COFFINK_PARTNER_CAFE_')) {
        final parts = qrData.split('_');
        if (parts.length >= 6 && parts[4] == 'POINTS') {
          final cafeId = parts[3];
          final points = int.tryParse(parts[5]);
          
          if (points != null && points > 0) {
            return {
              'cafeId': cafeId,
              'points': points,
              'timestamp': DateTime.now().toIso8601String(),
            };
          }
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> _showSuccessDialog(Map<String, dynamic> qrResult) async {
    final points = qrResult['points'];
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  color: Colors.green[700],
                  size: 48,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Tebrikler!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$points Coffi Puanı Kazandınız!',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '+ $points Puan',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Bu puanları bir sonraki siparişinizde kullanabilirsiniz.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
              ),
            ],
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      // Continue scanning
                    },
                    child: const Text('Taramaya Devam'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop(); // Go back to main screen
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    ),
                    child: const Text('Tamamla'),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.error, color: Theme.of(context).colorScheme.error),
              const SizedBox(width: 8),
              Text(title),
            ],
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Tamam'),
            ),
          ],
        );
      },
    );
  }
}
