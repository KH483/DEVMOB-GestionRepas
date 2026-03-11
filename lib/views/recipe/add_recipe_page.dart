import 'dart:typed_data';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/ingredient.dart';
import '../../models/recipe.dart';
import '../../providers/recipe_provider.dart';
import '../../services/cloudinary_service.dart';

class AddRecipePage extends StatefulWidget {
  final Recipe? recipe;
  const AddRecipePage({super.key, this.recipe});

  @override
  State<AddRecipePage> createState() => _AddRecipePageState();
}

class _AddRecipePageState extends State<AddRecipePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _descCtrl;
  late MealCategory _category;
  late List<Ingredient> _ingredients;
  late List<String> _steps;

  // imageUrl = Cloudinary URL (saved in Firestore)
  String? _imageUrl;
  // preview bytes for display before upload
  Uint8List? _imageBytes;
  bool _uploadingImage = false;

  final _ingNameCtrl = TextEditingController();
  final _ingQtyCtrl = TextEditingController();
  final _ingUnitCtrl = TextEditingController();
  final _stepCtrl = TextEditingController();
  final _cloudinary = CloudinaryService();

  @override
  void initState() {
    super.initState();
    final r = widget.recipe;
    _nameCtrl = TextEditingController(text: r?.name ?? '');
    _descCtrl = TextEditingController(text: r?.description ?? '');
    _category = r?.category ?? MealCategory.lunch;
    _ingredients = r?.ingredients
            .map((i) => Ingredient(
                name: i.name, quantity: i.quantity, unit: i.unit))
            .toList() ??
        [];
    _steps = List.from(r?.steps ?? []);
    _imageUrl = r?.imagePath; // imagePath now stores Cloudinary URL
  }

  Future<void> _pickAndUploadImage() async {
    Uint8List? bytes;
    String fileName = 'recipe_${DateTime.now().millisecondsSinceEpoch}.jpg';

    if (kIsWeb) {
      // Use native HTML file input on Web
      final completer = html.FileUploadInputElement();
      completer.accept = 'image/*';
      completer.click();

      await completer.onChange.first;
      if (completer.files == null || completer.files!.isEmpty) return;

      final file = completer.files!.first;
      fileName = file.name;

      final reader = html.FileReader();
      reader.readAsArrayBuffer(file);
      await reader.onLoad.first;
      bytes = Uint8List.fromList(reader.result as List<int>);
    } else {
      // Use image_picker on mobile
      final picker = ImagePicker();
      final file = await picker.pickImage(
          source: ImageSource.gallery, imageQuality: 80);
      if (file == null) return;
      bytes = await file.readAsBytes();
      fileName = file.name;
    }

    if (bytes == null) return;

    setState(() {
      _imageBytes = bytes;
      _uploadingImage = true;
    });

    final url = await _cloudinary.uploadImage(bytes!, fileName);

    setState(() {
      _uploadingImage = false;
      if (url != null) _imageUrl = url;
    });

    if (url == null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Échec de l\'upload. Vérifiez Cloudinary.')),
      );
    }
  }

  void _addIngredient() {
    if (_ingNameCtrl.text.trim().isEmpty) return;
    setState(() {
      _ingredients.add(Ingredient(
        name: _ingNameCtrl.text.trim(),
        quantity: _ingQtyCtrl.text.trim(),
        unit: _ingUnitCtrl.text.trim(),
      ));
      _ingNameCtrl.clear();
      _ingQtyCtrl.clear();
      _ingUnitCtrl.clear();
    });
  }

  void _addStep() {
    if (_stepCtrl.text.trim().isEmpty) return;
    setState(() {
      _steps.add(_stepCtrl.text.trim());
      _stepCtrl.clear();
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_uploadingImage) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image en cours d\'upload, patientez...')),
      );
      return;
    }

    final provider = context.read<RecipeProvider>();
    final recipe = Recipe(
      id: widget.recipe?.id ?? const Uuid().v4(),
      name: _nameCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      ingredients: _ingredients,
      steps: _steps,
      category: _category,
      imagePath: _imageUrl, // Cloudinary URL
      isFavorite: widget.recipe?.isFavorite ?? false,
    );

    if (widget.recipe == null) {
      await provider.addRecipe(recipe);
    } else {
      await provider.updateRecipe(recipe);
    }

    if (!mounted) return;
    Navigator.pop(context);
  }

  Widget _buildImagePreview() {
    return GestureDetector(
      onTap: _pickAndUploadImage,
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior: Clip.hardEdge,
        child: _uploadingImage
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.green),
                    SizedBox(height: 8),
                    Text('Upload en cours...', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              )
            : _imageBytes != null
                ? Image.memory(_imageBytes!, fit: BoxFit.cover,
                    width: double.infinity)
                : _imageUrl != null
                    ? Image.network(_imageUrl!, fit: BoxFit.cover,
                        width: double.infinity)
                    : const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo, size: 40, color: Colors.grey),
                          SizedBox(height: 8),
                          Text('Ajouter une photo',
                              style: TextStyle(color: Colors.grey)),
                        ],
                      ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.recipe != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Modifier la recette' : 'Nouvelle recette'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('Enregistrer',
                style: TextStyle(color: Colors.white)),
          )
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildImagePreview(),
            const SizedBox(height: 16),

            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                  labelText: 'Nom de la recette',
                  border: OutlineInputBorder()),
              validator: (v) =>
                  v == null || v.isEmpty ? 'Champ requis' : null,
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _descCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                  labelText: 'Description', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),

            DropdownButtonFormField<MealCategory>(
              initialValue: _category,
              decoration: const InputDecoration(
                  labelText: 'Catégorie', border: OutlineInputBorder()),
              items: MealCategory.values
                  .map((c) => DropdownMenuItem<MealCategory>(
                      value: c, child: Text(c.label)))
                  .toList(),
              onChanged: (v) => setState(() => _category = v!),
            ),
            const SizedBox(height: 20),

            const Text('Ingrédients',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: _ingNameCtrl,
                    decoration: const InputDecoration(
                        hintText: 'Ingrédient',
                        border: OutlineInputBorder(),
                        isDense: true),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _ingQtyCtrl,
                    decoration: const InputDecoration(
                        hintText: 'Qté',
                        border: OutlineInputBorder(),
                        isDense: true),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _ingUnitCtrl,
                    decoration: const InputDecoration(
                        hintText: 'Unité',
                        border: OutlineInputBorder(),
                        isDense: true),
                  ),
                ),
                IconButton(
                    onPressed: _addIngredient,
                    icon: const Icon(Icons.add_circle, color: Colors.green)),
              ],
            ),
            const SizedBox(height: 8),
            ..._ingredients.asMap().entries.map((e) => ListTile(
                  dense: true,
                  leading: const Icon(Icons.circle, size: 8),
                  title: Text(
                      '${e.value.name} ${e.value.quantity} ${e.value.unit}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, size: 18),
                    onPressed: () =>
                        setState(() => _ingredients.removeAt(e.key)),
                  ),
                )),
            const SizedBox(height: 20),

            const Text('Étapes de préparation',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _stepCtrl,
                    decoration: const InputDecoration(
                        hintText: 'Ajouter une étape',
                        border: OutlineInputBorder(),
                        isDense: true),
                  ),
                ),
                IconButton(
                    onPressed: _addStep,
                    icon: const Icon(Icons.add_circle, color: Colors.green)),
              ],
            ),
            const SizedBox(height: 8),
            ..._steps.asMap().entries.map((e) => ListTile(
                  dense: true,
                  leading: CircleAvatar(
                    radius: 12,
                    backgroundColor: Colors.green,
                    child: Text('${e.key + 1}',
                        style: const TextStyle(
                            color: Colors.white, fontSize: 11)),
                  ),
                  title: Text(e.value),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, size: 18),
                    onPressed: () =>
                        setState(() => _steps.removeAt(e.key)),
                  ),
                )),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
