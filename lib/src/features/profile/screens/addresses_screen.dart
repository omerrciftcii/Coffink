import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'add_address_map_screen.dart';

class AddressesScreen extends StatefulWidget {
  const AddressesScreen({super.key});

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Adreslerim'),
      ),
      body: user == null
          ? Center(
              child: Text(
                'Adresleri görmek için giriş yapın',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
              ),
            )
          : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _firestore
                  .collection('users')
                  .doc(user.uid)
                  .collection('addresses')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Adresler yüklenemedi'));
                }
                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) {
                  return _buildEmptyState(context);
                }
                return ListView.separated(
                  itemCount: docs.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final d = docs[index].data();
                    final id = docs[index].id;
                    final label = d['label'] as String? ?? 'Adres';
                    final full = d['fullAddress'] as String? ?? '';
                    final phone = d['phone'] as String?;
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        child: Icon(Icons.location_on, color: Theme.of(context).colorScheme.primary),
                      ),
                      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (full.isNotEmpty) Text(full),
                          if (phone != null && phone.isNotEmpty)
                            Text(phone, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7))),
                        ],
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'edit') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AddAddressMapScreen(
                                  docId: id,
                                  initialLabel: d['label'] as String?,
                                  initialType: (d['type'] as String?) ?? 'Ev',
                                  initialFullAddress: d['fullAddress'] as String?,
                                  initialGeoPoint: d['location'] as GeoPoint?,
                                ),
                              ),
                            );
                          } else if (value == 'delete') {
                            _deleteAddress(user.uid, id);
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(value: 'edit', child: Text('Düzenle')),
                          const PopupMenuItem(value: 'delete', child: Text('Sil')),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
      floatingActionButton: user == null
          ? null
          : FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddAddressMapScreen()),
                );
              },
              child: const Icon(Icons.add_location_alt),
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_on_outlined, size: 72, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 12),
          const Text('Kayıtlı adres bulunmuyor', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text('Teslimat adresi eklemek için + butonuna dokunun',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7))),
        ],
      ),
    );
  }

  Future<void> _deleteAddress(String uid, String docId) async {
    await _firestore.collection('users').doc(uid).collection('addresses').doc(docId).delete();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Adres silindi')));
    }
  }

  Future<void> _openAddressForm(BuildContext context, {String? docId, Map<String, dynamic>? initial}) async {
    final user = _auth.currentUser!;
    final formKey = GlobalKey<FormState>();
    final labelCtrl = TextEditingController(text: initial?['label'] ?? 'Ev');
    final addressCtrl = TextEditingController(text: initial?['fullAddress'] ?? '');
    final phoneCtrl = TextEditingController(text: initial?['phone'] ?? '');

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(docId == null ? 'Yeni Adres' : 'Adresi Düzenle',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: labelCtrl,
                    decoration: const InputDecoration(labelText: 'Etiket (Ev, İş vb.)'),
                    validator: (v) => (v == null || v.isEmpty) ? 'Etiket gerekli' : null,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: addressCtrl,
                    decoration: const InputDecoration(labelText: 'Adres'),
                    maxLines: 3,
                    validator: (v) => (v == null || v.isEmpty) ? 'Adres gerekli' : null,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: phoneCtrl,
                    decoration: const InputDecoration(labelText: 'Telefon (opsiyonel)'),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Vazgeç'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            if (formKey.currentState?.validate() != true) return;
                            final data = {
                              'label': labelCtrl.text.trim(),
                              'fullAddress': addressCtrl.text.trim(),
                              'phone': phoneCtrl.text.trim(),
                              'createdAt': FieldValue.serverTimestamp(),
                            };
                            if (docId == null) {
                              await _firestore.collection('users').doc(user.uid).collection('addresses').add(data);
                              if (mounted) Navigator.pop(ctx);
                              if (mounted) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(content: Text('Adres eklendi')));
                              }
                            } else {
                              await _firestore
                                  .collection('users')
                                  .doc(user.uid)
                                  .collection('addresses')
                                  .doc(docId)
                                  .update(data);
                              if (mounted) Navigator.pop(ctx);
                              if (mounted) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(content: Text('Adres güncellendi')));
                              }
                            }
                          },
                          child: const Text('Kaydet'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
