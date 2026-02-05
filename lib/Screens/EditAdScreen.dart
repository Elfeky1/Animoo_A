import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import '../widgets/loading_overlay.dart';

class EditAdScreen extends StatefulWidget {
  const EditAdScreen({super.key});

  @override
  State<EditAdScreen> createState() => _EditAdScreenState();
}

class _EditAdScreenState extends State<EditAdScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final descController = TextEditingController();
  final priceController = TextEditingController();
  final ageController = TextEditingController();
  final healthController = TextEditingController();
  final locationController = TextEditingController();

  bool vaccinated = false;
  String category = 'dogs';

  List<File> newImages = [];
  List oldImages = [];

  File? idCard;
  bool isLoading = false;

  final picker = ImagePicker();
  late Map ad;

 bool initialized = false;

@override
void didChangeDependencies() {
  super.didChangeDependencies();
  if (initialized) return;

  ad = ModalRoute.of(context)!.settings.arguments as Map;

  nameController.text = ad['name'] ?? '';
  descController.text = ad['description'] ?? '';
  priceController.text = ad['price'] ?? '';
  ageController.text = ad['age']?.toString() ?? '';
  healthController.text = ad['healthStatus'] ?? '';
  locationController.text = ad['location'] ?? '';
  vaccinated = ad['vaccinated'] ?? false;
  category = ad['category'];
  oldImages = List.from(ad['images'] ?? []);

  initialized = true;
}


  Future<void> pickImage() async {
    if (newImages.length + oldImages.length >= 4) return;

    final XFile? picked =
        await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        newImages.add(File(picked.path));
      });
    }
  }

  Future<void> submitEdit() async {
  if (!_formKey.currentState!.validate()) return;


  print({
    'name': nameController.text,
    'description': descController.text,
    'price': priceController.text,
    'age': ageController.text,
    'health': healthController.text,
    'location': locationController.text,
    'vaccinated': vaccinated,
  });

  setState(() => isLoading = true);

  final success = await ApiService.updateAd(
    id: ad['_id'],
    name: nameController.text.trim(),
    description: descController.text.trim(),
    price: priceController.text.trim(),
    category: category,
    newImages: newImages,
    age: category == 'food' ? null : ageController.text.trim(),
    vaccinated: category == 'food' ? null : vaccinated,
    healthStatus:
        category == 'food' ? null : healthController.text.trim(),
    location:
        category == 'food' ? null : locationController.text.trim(),
  );

  if (!mounted) return;
  setState(() => isLoading = false);

  if (success) {
    Navigator.pop(context, true);
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Failed to update ad')),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: isLoading,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xff24394a),
          title: const Text('Edit Ad'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _label('Name'),
                _input(nameController),

                _label('Price'),
                _input(priceController),

                _label('Description'),
                _input(descController, maxLines: 4),

                if (category != 'food') ...[
                  _label('Age'),
                  _input(ageController),

                  _label('Location'),
                  _input(locationController),

                  _label('Health Status'),
                  _input(healthController),

                  CheckboxListTile(
                    value: vaccinated,
                    onChanged: (v) => setState(() => vaccinated = v!),
                    title: const Text('Vaccinated'),
                  ),
                ],

                _label('Images'),
                Wrap(
                  spacing: 10,
                  children: [
                    ...oldImages.map(
                      (img) => Stack(
                        children: [
                          Image.network(
                            '${ApiService.baseUrl}/uploads/$img',
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                          Positioned(
                            right: 0,
                            child: IconButton(
                              icon: const Icon(Icons.close,
                                  color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  oldImages.remove(img);
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    ...newImages.map(
                      (img) => Image.file(
                        img,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                    if (oldImages.length + newImages.length < 4)
                      GestureDetector(
                        onTap: pickImage,
                        child: Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey.shade300,
                          child: const Icon(Icons.add),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff24394a),
                    ),
                    onPressed: submitEdit,
                    child: const Text(
                      'Save Changes',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String t) => Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 6),
        child: Text(t, style: const TextStyle(fontWeight: FontWeight.bold)),
      );

  Widget _input(TextEditingController c, {int maxLines = 1}) {
    return TextFormField(
      controller: c,
      maxLines: maxLines,
      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
      decoration: const InputDecoration(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderSide: BorderSide.none),
      ),
    );
  }
}
