import 'package:flutter/material.dart';
import 'package:Ecommerce_app/models/user_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../services/file_upload.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/global_ui_viewmodel.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _usernameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;

  String? imagePath;
  String? imageUrl;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _usernameController = TextEditingController();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();

    // Populate the text controllers with existing user data
    UserModel user = Provider.of<AuthViewModel>(context, listen: false).loggedInUser!;
    _nameController.text = user.name ?? '';
    _usernameController.text = user.username ?? '';
    _phoneController.text = user.phone ?? '';
    _emailController.text = user.email ?? '';
    imageUrl = user.imageUrl;
    imagePath = user.imagePath;
  }

  Future<void> _pickImage(ImageSource source) async {
    var selected = await _picker.pickImage(source: source, imageQuality: 100);
    if (selected != null) {
      setState(() {
        imageUrl = null;
        imagePath = null;
      });

      try {
        ImagePath? image = await FileUpload().uploadImage(selectedPath: selected.path);
        if (image != null) {
          setState(() {
            imageUrl = image.imageUrl;
            imagePath = image.imagePath;
          });
        }
      } catch (e) {
        print(e);
      }
    }
  }

  void _saveProfile() async {
    AuthViewModel authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    GlobalUIViewModel uiViewModel = Provider.of<GlobalUIViewModel>(context, listen: false);

    uiViewModel.loadState(true);

    try {
      UserModel updatedUser = UserModel(
        userId: authViewModel.loggedInUser!.userId,
        name: _nameController.text,
        username: _usernameController.text,
        phone: _phoneController.text,
        email: _emailController.text,
        imageUrl: imageUrl,
        imagePath: imagePath,
      );
      await authViewModel.updateUserProfile(updatedUser);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Profile updated successfully")));
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to update profile")));
    }

    uiViewModel.loadState(false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
              onTap: () => _pickImage(ImageSource.gallery),
              child: CircleAvatar(
                radius: 80,
                backgroundColor: Colors.grey[200],
                backgroundImage: imageUrl != null ? NetworkImage(imageUrl!) : null,
                child: imageUrl == null
                    ? Icon(
                  Icons.person,
                  size: 80,
                  color: Colors.grey[500],
                )
                    : null,
              ),
            ),
            SizedBox(height: 40),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name', icon: Icon(Icons.person)),
            ),
            TextFormField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username', icon: Icon(Icons.account_circle)),
            ),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email', icon: Icon(Icons.email)),
            ),
            SizedBox(height: 60),
            ElevatedButton(
              onPressed: _saveProfile,
              child: Text(
                'Save Profile',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: EdgeInsets.symmetric(vertical: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
