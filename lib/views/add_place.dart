import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import '../models/place_model.dart';

class AddPlaceScreen extends StatefulWidget {
  const AddPlaceScreen({Key? key}) : super(key: key);

  @override
  State<AddPlaceScreen> createState() => _AddPlaceScreenState();
}

class _AddPlaceScreenState extends State<AddPlaceScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController categoriesController = TextEditingController();
  final TextEditingController ratingController = TextEditingController();
  final TextEditingController entryFeeController = TextEditingController();
  final TextEditingController openingHoursController = TextEditingController();

  final TextEditingController latitudeController = TextEditingController();
  final TextEditingController longitudeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // No need to call _getCurrentLocation since we aren't fetching the location
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      // Parse latitude and longitude entered manually
      final latitude = double.tryParse(latitudeController.text);
      final longitude = double.tryParse(longitudeController.text);

      if (latitude == null || longitude == null) {
        Get.snackbar('Location Error', 'Please enter valid latitude and longitude.');
        return;
      }

      try {
        final rating = double.tryParse(ratingController.text);

        if (rating == null) {
          Get.snackbar('Format Error', 'Please enter a valid number for rating');
          return;
        }

        final place = PlaceModel(
          id: '',
          name: nameController.text,
          description: descriptionController.text,
          imageUrl: '',
          location: GeoPoint(latitude, longitude),
          categories: categoriesController.text.split(',').map((e) => e.trim()).toList(),
          rating: rating,
          additionalInfo: {
            'entryFee': entryFeeController.text,
            'openingHours': openingHoursController.text,
          },
        );

        await FirebaseFirestore.instance.collection('places').add(place.toMap());

        Get.back();
        Get.snackbar('Success', 'Place added successfully');
      } catch (e) {
        Get.snackbar('Error', 'Failed to add place');
        print('Add place error: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add New Place')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              // Manual latitude and longitude input fields
              TextFormField(
                controller: latitudeController,
                decoration: const InputDecoration(labelText: 'Latitude'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Latitude is required' : null,
              ),
              TextFormField(
                controller: longitudeController,
                decoration: const InputDecoration(labelText: 'Longitude'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Longitude is required' : null,
              ),
              TextFormField(
                controller: categoriesController,
                decoration: const InputDecoration(labelText: 'Categories (comma separated)'),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: ratingController,
                decoration: const InputDecoration(labelText: 'Rating'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: entryFeeController,
                decoration: const InputDecoration(labelText: 'Entry Fee'),
              ),
              TextFormField(
                controller: openingHoursController,
                decoration: const InputDecoration(labelText: 'Opening Hours'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Add Place'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
