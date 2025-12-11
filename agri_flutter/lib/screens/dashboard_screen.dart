import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'crop_recommend_screen.dart';
import 'market_finder_screen.dart';
import 'history_screen.dart';
import 'profile_screen.dart';
import 'admin_crops_screen.dart';
import 'admin_markets_screen.dart';
import 'admin_users_screen.dart';
import 'login_screen.dart';

// Simple Dashboard Screen
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        title: const Text('AgriNova Dashboard'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              // Show confirmation dialog
              final shouldLogout = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Do you want to logout?'),
                  actions: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[400]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text(
                          'No',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.green[700],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text(
                          'Yes',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              );

              if (shouldLogout == true && context.mounted) {
                await authProvider.logout();
                if (context.mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome message
              Text(
                'Welcome, ${user?.firstName ?? user?.username ?? "User"}!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'What would you like to do today?',
                style: TextStyle(fontSize: 16, color: Colors.green[600]),
              ),
              const SizedBox(height: 30),

              // Main features
              _buildMenuCard(
                context,
                'Crop Recommendation',
                'Get personalized crop suggestions',
                Icons.agriculture,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CropRecommendScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              _buildMenuCard(
                context,
                'Market Finder',
                'Find nearby agricultural markets',
                Icons.store,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MarketFinderScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              _buildMenuCard(
                context,
                'History',
                'View your recommendation history',
                Icons.history,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HistoryScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              _buildMenuCard(
                context,
                'Profile',
                'View and edit your profile',
                Icons.person,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfileScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 30),

              // Admin section (only show if user is staff)
              if (user?.isStaff == true) ...[
                Text(
                  'Admin Panel',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
                const SizedBox(height: 16),

                _buildMenuCard(
                  context,
                  'Manage Crops',
                  'Add or remove crops from database',
                  Icons.grass,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AdminCropsScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),

                _buildMenuCard(
                  context,
                  'Manage Markets',
                  'Add or remove markets from database',
                  Icons.storefront,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AdminMarketsScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),

                _buildMenuCard(
                  context,
                  'Manage Users',
                  'View and manage user accounts',
                  Icons.people,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AdminUsersScreen(),
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: Icon(icon, size: 40, color: Colors.green[700]),
        title: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}
