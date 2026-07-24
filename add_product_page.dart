import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'api_config.dart';
import 'translated_text.dart';

class AddProductPage extends StatefulWidget {
  final Map<String, dynamic>? product;

  const AddProductPage({super.key, this.product});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final brandController = TextEditingController();
  final typeController = TextEditingController();
  final descController = TextEditingController();
  final priceController = TextEditingController();
  final stockController = TextEditingController();

  XFile? pickedImage;
  bool _isSaving = false;

  bool get isEdit => widget.product != null;

  @override
  void initState() {
    super.initState();
    if (isEdit) {
      nameController.text = widget.product!["name"].toString();
      brandController.text = widget.product!["Brand"].toString();
      typeController.text = widget.product!["type"].toString();
      descController.text = widget.product!["description"].toString();
      priceController.text = widget.product!["price"].toString();
      stockController.text = widget.product!["stock_quantity"].toString();
    }
  }


  Future<void> uploadBulkCSV() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result != null) {
        setState(() => _isSaving = true);
        var uri = Uri.parse("${ApiConfig.baseUrl}bulk_upload.php");
        var request = http.MultipartRequest("POST", uri);

        if (kIsWeb) {
          request.files.add(http.MultipartFile.fromBytes(
            'csv_file',
            result.files.first.bytes!,
            filename: result.files.first.name,
          ));
        } else {
          request.files.add(await http.MultipartFile.fromPath(
            'csv_file',
            result.files.first.path!,
          ));
        }

        var response = await request.send();
        if (response.statusCode == 200 && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: TText("Bulk Upload Successful")),
          );
          Navigator.pop(context, true);
        } else {
          _showError("Bulk Upload Failed");
        }
      }
    } catch (e) {
      _showError("Error: $e");
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => pickedImage = picked);
    }
  }

  Future<void> saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final uri = Uri.parse(
        isEdit
            ? "${ApiConfig.baseUrl}update_admin_product.php"
            : "${ApiConfig.baseUrl}add_product.php",
      );

      var request = http.MultipartRequest("POST", uri);

      request.fields["name"] = nameController.text.trim();
      request.fields["Brand"] = brandController.text.trim();
      request.fields["type"] = typeController.text.trim();
      request.fields["description"] = descController.text.trim();
      request.fields["price"] = priceController.text.trim();
      request.fields["stock_quantity"] = stockController.text.trim();

      if (isEdit) {
        request.fields["p_id"] = widget.product!["p_id"].toString();
      }

      if (pickedImage != null) {
        if (kIsWeb) {
          var bytes = await pickedImage!.readAsBytes();
          request.files.add(http.MultipartFile.fromBytes(
            "image_url",
            bytes,
            filename: pickedImage!.name,
          ));
        } else {
          request.files.add(await http.MultipartFile.fromPath("image_url", pickedImage!.path));
        }
      }

      final res = await request.send();

      if (res.statusCode == 200 && mounted) {
        Navigator.pop(context, true);
      } else {
        _showError("Failed to save product");
      }
    } catch (e) {
      _showError("Error: $e");
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: TText(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: TText(isEdit ? "Update Product" : "Add Product",
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.green[700],
        elevation: 0,

        actions: [
          if (!isEdit)
            IconButton(
              icon: const Icon(Icons.upload_file, color: Colors.white),
              onPressed: _isSaving ? null : uploadBulkCSV,
              tooltip: "Bulk Upload CSV",
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: pickImage,
                child: Container(
                  height: 160,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: pickedImage != null
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: kIsWeb
                        ? Image.network(pickedImage!.path, fit: BoxFit.cover)
                        : Image.file(File(pickedImage!.path), fit: BoxFit.cover),
                  )
                      : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_a_photo, size: 40, color: Colors.green[700]),
                      const SizedBox(height: 8),
                      const TText("Pick Image", style: TextStyle(color: Colors.green, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildField(nameController, "Name", Icons.inventory_2_outlined),
              _buildField(brandController, "Brand", Icons.branding_watermark_outlined),
              _buildField(typeController, "Type", Icons.category_outlined),
              _buildField(descController, "Description", Icons.description_outlined, maxLines: 3),
              _buildField(priceController, "Price", Icons.currency_rupee, keyboard: TextInputType.number),
              _buildField(stockController, "Stock", Icons.storage_outlined, keyboard: TextInputType.number),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _isSaving ? null : saveProduct,
                  child: _isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : TText(isEdit ? "Update" : "Save",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController controller, String label, IconData icon, {int maxLines = 1, TextInputType keyboard = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: FutureBuilder<String>(
          future: TranslationService.translate(label),
          builder: (context, snapshot) {
            return TextFormField(
              controller: controller,
              maxLines: maxLines,
              keyboardType: keyboard,
              decoration: InputDecoration(
                labelText: snapshot.data ?? label,
                prefixIcon: Icon(icon, color: Colors.green[700]),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              validator: (v) => v!.isEmpty ? "Required" : null,
            );
          }
      ),
    );
  }
}
