import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_textfield.dart';
import '../widgets/custom_button.dart';

// Simple Profile Screen
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _districtController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load user data
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;

    _firstNameController.text = user?.firstName ?? '';
    _lastNameController.text = user?.lastName ?? '';
    _emailController.text = user?.email ?? '';
    _phoneController.text = user?.phoneNumber ?? '';
    _districtController.text = user?.district ?? '';
    _addressController.text = user?.address ?? '';
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _districtController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final data = {
      "first_name": _firstNameController.text,
      "last_name": _lastNameController.text,
      "email": _emailController.text,
      "phone_number": _phoneController.text,
      "district": _districtController.text,
      "address": _addressController.text,
    };

    final success = await authProvider.updateProfile(data);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error ?? 'Failed to update profile'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Profile icon
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.green[700],
                child: const Icon(Icons.person, size: 60, color: Colors.white),
              ),
              const SizedBox(height: 16),
              Text(
                user?.username ?? 'User',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700],
                ),
              ),
              const SizedBox(height: 8),
              if (user?.isStaff == true)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green[700],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'ADMIN',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              const SizedBox(height: 30),

              // First Name
              CustomTextField(
                label: 'First Name',
                controller: _firstNameController,
              ),
              const SizedBox(height: 16),

              // Last Name
              CustomTextField(
                label: 'Last Name',
                controller: _lastNameController,
              ),
              const SizedBox(height: 16),

              // Email
              CustomTextField(
                label: 'Email',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              // Phone Number
              CustomTextField(
                label: 'Phone Number',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),

              // District
              CustomTextField(
                label: 'District',
                controller: _districtController,
              ),
              const SizedBox(height: 16),

              // Address
              CustomTextField(
                label: 'Address',
                controller: _addressController,
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              // Update button
              CustomButton(
                text: 'Update Profile',
                onPressed: _updateProfile,
                isLoading: authProvider.isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
