import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

// Simple Admin Users Screen
class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => Provider.of<UserProvider>(context, listen: false).loadUsers(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final users = userProvider.users;

    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        title: const Text('Manage Users'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: userProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : users.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.people, size: 80, color: Colors.green[300]),
                    const SizedBox(height: 16),
                    Text(
                      'No users in database',
                      style: TextStyle(fontSize: 18, color: Colors.green[600]),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 16),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.green[700],
                        child: Text(
                          user.username[0].toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        user.username,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      subtitle: Text(user.email),
                      trailing: user.isStaff
                          ? Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green[700],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'ADMIN',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            )
                          : IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Delete User'),
                                    content: Text(
                                      'Are you sure you want to delete ${user.username}?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: const Text('Cancel'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                        ),
                                        child: const Text('Delete'),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirm == true && mounted) {
                                  await userProvider.deleteUser(user.id);
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'User deleted successfully!',
                                        ),
                                      ),
                                    );
                                  }
                                }
                              },
                            ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
