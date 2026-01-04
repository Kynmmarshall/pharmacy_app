import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pharmacy_app/themes/app_theme.dart';
import 'package:pharmacy_app/providers/auth_provider.dart';

class AdminDashboard extends ConsumerStatefulWidget {
  const AdminDashboard({super.key});

  @override
  ConsumerState<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends ConsumerState<AdminDashboard> {
  int _selectedIndex = 0;
  final List<Map<String, dynamic>> _systemStats = [
    {'label': 'Total Users', 'value': '1,254', 'change': '+12%', 'icon': Icons.people, 'color': Colors.blue},
    {'label': 'Active Orders', 'value': '89', 'change': '+5%', 'icon': Icons.shopping_cart, 'color': Colors.green},
    {'label': 'Total Revenue', 'value': '245K Fcfa', 'change': '+18%', 'icon': Icons.attach_money, 'color': Colors.purple},
    {'label': 'Pharmacies', 'value': '42', 'change': '+3%', 'icon': Icons.local_pharmacy, 'color': Colors.orange},
  ];

  final List<Map<String, dynamic>> _recentUsers = [
    {'name': 'John Doe', 'email': 'john@email.com', 'role': 'user', 'status': 'active', 'joinDate': '2024-01-15'},
    {'name': 'Sarah Smith', 'email': 'sarah@email.com', 'role': 'pharmacy', 'status': 'active', 'joinDate': '2024-01-14'},
    {'name': 'Mike Johnson', 'email': 'mike@email.com', 'role': 'admin', 'status': 'active', 'joinDate': '2024-01-13'},
    {'name': 'Emma Wilson', 'email': 'emma@email.com', 'role': 'user', 'status': 'inactive', 'joinDate': '2024-01-12'},
    {'name': 'David Brown', 'email': 'david@email.com', 'role': 'pharmacy', 'status': 'pending', 'joinDate': '2024-01-11'},
  ];

  final List<Map<String, dynamic>> _recentActivities = [
    {'action': 'New pharmacy registered', 'user': 'MedPlus Pharmacy', 'time': '10 min ago', 'icon': Icons.add_business},
    {'action': 'User account created', 'user': 'Robert Taylor', 'time': '25 min ago', 'icon': Icons.person_add},
    {'action': 'Order completed', 'user': 'Order #ORD1023', 'time': '1 hour ago', 'icon': Icons.check_circle},
    {'action': 'Prescription approved', 'user': 'RX00456', 'time': '2 hours ago', 'icon': Icons.verified},
    {'action': 'System backup completed', 'user': 'Admin', 'time': '4 hours ago', 'icon': Icons.backup},
  ];

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final userRole = authState.user?['role'];
    final adminName = authState.user?['name'] ?? 'Admin';

    // Check if user is admin
    if (userRole != 'admin') {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Access Denied'),
          leading: IconButton(
            icon: const Icon(Icons.logout_sharp),
            onPressed: () => context.go('/login'),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.admin_panel_settings, size: 80, color: Colors.red),
              const SizedBox(height: 20),
              const Text(
                'Admin Access Required',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                'Only system administrators can access this dashboard',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () => context.go('/home'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                ),
                child: const Text('Go to Home'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard'),
        leading: IconButton(
          icon: const Icon(Icons.login_sharp),
          onPressed: () => context.go('/login'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: _openAdminProfile,
          ),
          IconButton(
            icon: const Icon(Icons.notifications_active),
            onPressed: _showSystemNotifications,
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _openSystemSettings,
          ),
        ],
      ),
      body: _selectedIndex == 0
          ? _buildDashboard()
          : _selectedIndex == 1
              ? _buildUserManagement()
              : _selectedIndex == 2
                  ? _buildSystemManagement()
                  : Container(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Users',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_system_daydream),
            label: 'System',
          ),
        ],
      ),
      floatingActionButton: _selectedIndex == 1
          ? FloatingActionButton(
              onPressed: _createNewUser,
              backgroundColor: AppTheme.primaryColor,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.purple.shade700,
                  Colors.purple.shade400,
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'System Administration',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Monitor and manage the entire pharmacy system',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _viewSystemHealth,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.purple,
                        ),
                        child: const Text('View System Health'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                const Icon(
                  Icons.admin_panel_settings,
                  size: 80,
                  color: Colors.white,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // System Stats
          const Text(
            'System Overview',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.2,
            ),
            itemCount: _systemStats.length,
            itemBuilder: (context, index) {
              return _buildStatCard(_systemStats[index]);
            },
          ),

          const SizedBox(height: 24),

          // Quick Actions
          const Text(
            'Quick Actions',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildAdminActionButton(
                icon: Icons.add_moderator,
                label: 'Add Admin',
                color: Colors.purple,
                onTap: _addNewAdmin,
              ),
              _buildAdminActionButton(
                icon: Icons.business,
                label: 'Manage Pharmacies',
                color: Colors.blue,
                onTap: _managePharmacies,
              ),
              _buildAdminActionButton(
                icon: Icons.medical_services,
                label: 'Medicine Catalog',
                color: Colors.green,
                onTap: _manageMedicineCatalog,
              ),
              _buildAdminActionButton(
                icon: Icons.security,
                label: 'Security Settings',
                color: Colors.orange,
                onTap: _openSecuritySettings,
              ),
              _buildAdminActionButton(
                icon: Icons.backup,
                label: 'System Backup',
                color: Colors.red,
                onTap: _performSystemBackup,
              ),
              _buildAdminActionButton(
                icon: Icons.bug_report,
                label: 'View Logs',
                color: Colors.teal,
                onTap: _viewSystemLogs,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Recent Users
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Users',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: _viewAllUsers,
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: _recentUsers.map((user) => _buildUserRow(user)).toList(),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // System Activities
          const Text(
            'Recent System Activities',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: _recentActivities.map((activity) => _buildActivityRow(activity)).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserManagement() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search users...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              PopupMenuButton<String>(
                icon: const Icon(Icons.filter_list),
                onSelected: (value) => _filterUsers(value),
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'all', child: Text('All Users')),
                  const PopupMenuItem(value: 'active', child: Text('Active')),
                  const PopupMenuItem(value: 'inactive', child: Text('Inactive')),
                  const PopupMenuItem(value: 'pharmacy', child: Text('Pharmacies')),
                  const PopupMenuItem(value: 'admin', child: Text('Admins')),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _recentUsers.length,
            itemBuilder: (context, index) {
              return _buildUserManagementCard(_recentUsers[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSystemManagement() {
    final List<Map<String, dynamic>> _systemSettings = [
      {'title': 'General Settings', 'icon': Icons.settings, 'route': '/system/general'},
      {'title': 'Payment Configuration', 'icon': Icons.payment, 'route': '/system/payment'},
      {'title': 'Notification Settings', 'icon': Icons.notifications, 'route': '/system/notifications'},
      {'title': 'SMS & Email Templates', 'icon': Icons.email, 'route': '/system/templates'},
      {'title': 'API Configuration', 'icon': Icons.api, 'route': '/system/api'},
      {'title': 'Database Management', 'icon': Icons.storage, 'route': '/system/database'},
      {'title': 'Cache Management', 'icon': Icons.cached, 'route': '/system/cache'},
      {'title': 'Server Configuration', 'icon': Icons.dns, 'route': '/system/server'},
    ];

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.2,
      ),
      itemCount: _systemSettings.length,
      itemBuilder: (context, index) {
        return _buildSystemSettingCard(_systemSettings[index]);
      },
    );
  }

 
  Widget _buildStatCard(Map<String, dynamic> stat) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: stat['color'].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(stat['icon'], color: stat['color']),
                ),
                Text(
                  stat['change'],
                  style: TextStyle(
                    color: stat['change'].startsWith('+') ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              stat['value'],
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              stat['label'],
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminActionButton({required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 110,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserRow(Map<String, dynamic> user) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: _getRoleColor(user['role']),
            child: Text(
              user['name'][0],
              style: const TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user['name'],
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  user['email'],
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getStatusColor(user['status']).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              user['role'].toUpperCase(),
              style: TextStyle(
                color: _getRoleColor(user['role']),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityRow(Map<String, dynamic> activity) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(activity['icon'], color: Colors.grey[600], size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(activity['action']),
                Text(
                  activity['user'],
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          Text(
            activity['time'],
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildUserManagementCard(Map<String, dynamic> user) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getRoleColor(user['role']),
          child: Text(
            user['name'][0],
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(user['name']),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user['email']),
            Text('Joined: ${user['joinDate']}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, size: 20),
              onPressed: () => _editUser(user),
            ),
            IconButton(
              icon: const Icon(Icons.delete, size: 20, color: Colors.red),
              onPressed: () => _deleteUser(user),
            ),
          ],
        ),
        onTap: () => _viewUserDetails(user),
      ),
    );
  }

  Widget _buildSystemSettingCard(Map<String, dynamic> setting) {
    return Card(
      child: InkWell(
        onTap: () => _openSystemSetting(setting['route']),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(setting['icon'], size: 40, color: AppTheme.primaryColor),
              const SizedBox(height: 12),
              Text(
                setting['title'],
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return Colors.purple;
      case 'pharmacy':
        return Colors.orange;
      case 'user':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'inactive':
        return Colors.grey;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  // Action Methods
  void _openAdminProfile() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Admin Profile'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 40,
              child: Icon(Icons.person, size: 40),
            ),
            SizedBox(height: 16),
            Text('System Administrator'),
            Text('admin@pharmacy.com'),
            SizedBox(height: 16),
            Text('Last login: Today, 09:30 AM'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/profile');
            },
            child: const Text('View Full Profile'),
          ),
        ],
      ),
    );
  }

  void _showSystemNotifications() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('System Notifications'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildNotificationItem('System Update Available', 'Update to v2.1.0 recommended', Icons.system_update, Colors.blue),
              _buildNotificationItem('Database Backup Failed', 'Check backup configuration', Icons.error, Colors.red),
              _buildNotificationItem('New User Registration', '5 new users today', Icons.person_add, Colors.green),
              _buildNotificationItem('High Server Load', 'CPU usage at 85%', Icons.memory, Colors.orange),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Mark All Read'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(String title, String subtitle, IconData icon, Color color) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
    );
  }

  void _openSystemSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('System Settings'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.language),
                title: const Text('Language & Region'),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.palette),
                title: const Text('Theme & Appearance'),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.privacy_tip),
                title: const Text('Privacy Settings'),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.backup),
                title: const Text('Backup & Restore'),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.developer_mode),
                title: const Text('Developer Options'),
                onTap: () {},
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _viewSystemHealth() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('System Health'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHealthMetric('Server Status', 'Healthy', Icons.check_circle, Colors.green),
              _buildHealthMetric('Database', 'Connected', Icons.storage, Colors.green),
              _buildHealthMetric('API Services', 'Running', Icons.api, Colors.green),
              _buildHealthMetric('Storage', '85% Used', Icons.sd_storage, Colors.orange),
              _buildHealthMetric('Memory Usage', '72%', Icons.memory, Colors.orange),
              _buildHealthMetric('Uptime', '99.8%', Icons.timer, Colors.green),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _runSystemDiagnostics();
            },
            child: const Text('Run Diagnostics'),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthMetric(String label, String value, IconData icon, Color color) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(label),
      trailing: Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
    );
  }

  void _addNewAdmin() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Admin'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(decoration: const InputDecoration(labelText: 'Full Name')),
              TextField(decoration: const InputDecoration(labelText: 'Email')),
              TextField(decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
              DropdownButtonFormField(
                items: const [
                  DropdownMenuItem(value: 'full', child: Text('Full Administrator')),
                  DropdownMenuItem(value: 'limited', child: Text('Limited Administrator')),
                  DropdownMenuItem(value: 'support', child: Text('Support Admin')),
                ],
                decoration: const InputDecoration(labelText: 'Admin Level'),
                onChanged: (value) {},
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('New admin added successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Add Admin'),
          ),
        ],
      ),
    );
  }

  void _managePharmacies() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening pharmacy management...')),
    );
  }

  void _manageMedicineCatalog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening medicine catalog...')),
    );
  }

  void _openSecuritySettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening security settings...')),
    );
  }

  void _performSystemBackup() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('System Backup'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Creating system backup...'),
          ],
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Backup completed successfully'),
          backgroundColor: Colors.green,
        ),
      );
    });
  }

  void _viewSystemLogs() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening system logs...')),
    );
  }

  void _viewAllUsers() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening user management...')),
    );
  }

  void _createNewUser() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New User'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(decoration: const InputDecoration(labelText: 'Full Name')),
              TextField(decoration: const InputDecoration(labelText: 'Email')),
              TextField(decoration: const InputDecoration(labelText: 'Phone')),
              TextField(decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
              DropdownButtonFormField(
                items: const [
                  DropdownMenuItem(value: 'user', child: Text('Regular User')),
                  DropdownMenuItem(value: 'pharmacy', child: Text('Pharmacy Staff')),
                  DropdownMenuItem(value: 'admin', child: Text('Administrator')),
                ],
                decoration: const InputDecoration(labelText: 'User Role'),
                onChanged: (value) {},
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('User created successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Create User'),
          ),
        ],
      ),
    );
  }

  void _filterUsers(String filter) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Filtering users by: $filter')),
    );
  }

  void _editUser(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit User: ${user['name']}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Name', hintText: user['name']),
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Email', hintText: user['email']),
              ),
              DropdownButtonFormField(
                value: user['role'],
                items: const [
                  DropdownMenuItem(value: 'user', child: Text('User')),
                  DropdownMenuItem(value: 'pharmacy', child: Text('Pharmacy')),
                  DropdownMenuItem(value: 'admin', child: Text('Admin')),
                ],
                onChanged: (value) {},
              ),
              DropdownButtonFormField(
                value: user['status'],
                items: const [
                  DropdownMenuItem(value: 'active', child: Text('Active')),
                  DropdownMenuItem(value: 'inactive', child: Text('Inactive')),
                  DropdownMenuItem(value: 'pending', child: Text('Pending')),
                ],
                onChanged: (value) {},
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('User ${user['name']} updated'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }

  void _deleteUser(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text('Are you sure you want to delete ${user['name']}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('User ${user['name']} deleted'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _viewUserDetails(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('User Details: ${user['name']}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getRoleColor(user['role']),
                  child: Text(user['name'][0], style: const TextStyle(color: Colors.white)),
                ),
                title: Text(user['name']),
                subtitle: Text(user['email']),
              ),
              const Divider(),
              Text('Role: ${user['role'].toUpperCase()}'),
              Text('Status: ${user['status'].toUpperCase()}'),
              Text('Joined: ${user['joinDate']}'),
              const SizedBox(height: 16),
              const Text('User Activity:', style: TextStyle(fontWeight: FontWeight.bold)),
              const Text('• Last login: Today, 10:30 AM'),
              const Text('• Orders placed: 12'),
              const Text('• Consultations: 3'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _openSystemSetting(String route) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Opening: $route')),
    );
  }



  void _runSystemDiagnostics() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Running Diagnostics'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            const Text('Checking system components...'),
            const SizedBox(height: 16),
            _buildDiagnosticItem('Database connection', true),
            _buildDiagnosticItem('API endpoints', true),
            _buildDiagnosticItem('File system', true),
            _buildDiagnosticItem('Email service', false),
            _buildDiagnosticItem('Payment gateway', true),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDiagnosticItem(String item, bool status) {
    return Row(
      children: [
        Icon(status ? Icons.check_circle : Icons.error, color: status ? Colors.green : Colors.red, size: 16),
        const SizedBox(width: 8),
        Text(item),
        const Spacer(),
        Text(status ? 'OK' : 'ERROR', style: TextStyle(color: status ? Colors.green : Colors.red)),
      ],
    );
  }
}