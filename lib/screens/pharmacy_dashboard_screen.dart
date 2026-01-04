import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pharmacy_app/themes/app_theme.dart';
import 'package:pharmacy_app/providers/auth_provider.dart';

class PharmacyDashboard extends ConsumerStatefulWidget {
  const PharmacyDashboard({super.key});

  @override
  ConsumerState<PharmacyDashboard> createState() => _PharmacyDashboardState();
}

class _PharmacyDashboardState extends ConsumerState<PharmacyDashboard> {
  int _selectedIndex = 0;
  final List<Map<String, dynamic>> _pendingOrders = [
    {
      'id': 'ORD001',
      'customer': 'John Doe',
      'amount': '8500 Fcfa',
      'items': 3,
      'time': '10 min ago',
      'status': 'pending',
      'prescription': true,
    },
    {
      'id': 'ORD002',
      'customer': 'Sarah Smith',
      'amount': '5200 Fcfa',
      'items': 2,
      'time': '25 min ago',
      'status': 'pending',
      'prescription': false,
    },
    {
      'id': 'ORD003',
      'customer': 'Mike Johnson',
      'amount': '12000 Fcfa',
      'items': 5,
      'time': '45 min ago',
      'status': 'pending',
      'prescription': true,
    },
  ];

  final List<Map<String, dynamic>> _upcomingConsultations = [
    {
      'id': 'CON001',
      'customer': 'Emma Wilson',
      'doctor': 'Dr. Sarah Johnson',
      'type': 'Video Call',
      'time': 'Today, 2:30 PM',
      'status': 'scheduled',
    },
    {
      'id': 'CON002',
      'customer': 'David Brown',
      'doctor': 'Dr. Michael Chen',
      'type': 'Audio Call',
      'time': 'Tomorrow, 10:00 AM',
      'status': 'scheduled',
    },
    {
      'id': 'CON003',
      'customer': 'Lisa Taylor',
      'doctor': 'Dr. Priya Sharma',
      'type': 'Video Call',
      'time': 'Today, 4:15 PM',
      'status': 'scheduled',
    },
  ];

  final List<Map<String, dynamic>> _prescriptions = [
    {
      'id': 'RX001',
      'customer': 'John Doe',
      'doctor': 'Dr. Robert Kim',
      'date': '2024-01-15',
      'status': 'pending',
      'medicines': ['Amoxicillin 500mg', 'Paracetamol 500mg'],
    },
    {
      'id': 'RX002',
      'customer': 'Sarah Smith',
      'doctor': 'Dr. Lisa Wang',
      'date': '2024-01-14',
      'status': 'approved',
      'medicines': ['Vitamin C 1000mg', 'Cetirizine 10mg'],
    },
    {
      'id': 'RX003',
      'customer': 'Mike Johnson',
      'doctor': 'Dr. Sarah Johnson',
      'date': '2024-01-13',
      'status': 'rejected',
      'medicines': ['Metformin 500mg', 'Omeprazole 20mg'],
    },
  ];

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final userRole = authState.user?['role'];
    final pharmacyName = authState.user?['name'] ?? 'Pharmacy';

    // Check if user is pharmacy or admin
    if (userRole != 'pharmacy' && userRole != 'admin') {
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
              const Icon(Icons.warning, size: 80, color: Colors.orange),
              const SizedBox(height: 20),
              const Text(
                'Access Restricted',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                'Only pharmacy and admin staff can access this dashboard',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () => context.go('/pharmacy-dashboard'),
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
        title: Text('$pharmacyName Dashboard'),
        leading: IconButton(
          icon: const Icon(Icons.logout_outlined),
          onPressed: () => context.go('/login'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => context.go('/profile'),
            tooltip: 'Profile',
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: _showNotifications,
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _openSettings,
          ),
        ],
      ),
      body: _selectedIndex == 0
          ? _buildDashboard()
          : _selectedIndex == 1
              ? _buildPrescriptions()
              : _selectedIndex == 2
                  ? _buildConsultations()
                  : _buildInventory(),
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
            icon: Icon(Icons.medical_services),
            label: 'Prescriptions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.video_call),
            label: 'Consultations',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory),
            label: 'Inventory',
          ),
        ],
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: _addNewMedicine,
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
          // Stats Cards
          Row(
            children: [
              _buildStatCard(
                icon: Icons.shopping_cart,
                title: 'Pending Orders',
                value: '12',
                color: Colors.orange,
              ),
              const SizedBox(width: 12),
              _buildStatCard(
                icon: Icons.medical_services,
                title: 'Prescriptions',
                value: '8',
                color: Colors.blue,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildStatCard(
                icon: Icons.video_call,
                title: 'Consultations',
                value: '5',
                color: Colors.green,
              ),
              const SizedBox(width: 12),
              _buildStatCard(
                icon: Icons.warning,
                title: 'Low Stock',
                value: '3',
                color: Colors.red,
              ),
            ],
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
              _buildActionButton(
                icon: Icons.add_circle,
                label: 'Add Medicine',
                color: AppTheme.primaryColor,
                onTap: _addNewMedicine,
              ),
              _buildActionButton(
                icon: Icons.upload_file,
                label: 'Upload Prescription',
                color: Colors.blue,
                onTap: _uploadPrescription,
              ),
              _buildActionButton(
                icon: Icons.schedule,
                label: 'Schedule Consultation',
                color: Colors.green,
                onTap: _scheduleConsultation,
              ),
              _buildActionButton(
                icon: Icons.bar_chart,
                label: 'View Reports',
                color: Colors.purple,
                onTap: _viewReports,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Pending Orders
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Pending Orders',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: _viewAllOrders,
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _pendingOrders.length,
            itemBuilder: (context, index) {
              return _buildOrderCard(_pendingOrders[index]);
            },
          ),

          const SizedBox(height: 24),

          // Recent Activity
          const Text(
            'Recent Activity',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildActivityItem(
                    'Order ORD004 processed',
                    'Just now',
                    Icons.check_circle,
                    Colors.green,
                  ),
                  _buildActivityItem(
                    'Prescription RX002 approved',
                    '30 min ago',
                    Icons.verified,
                    Colors.blue,
                  ),
                  _buildActivityItem(
                    'Consultation CON001 completed',
                    '2 hours ago',
                    Icons.video_call,
                    Colors.purple,
                  ),
                  _buildActivityItem(
                    'Low stock alert: Paracetamol',
                    '5 hours ago',
                    Icons.warning,
                    Colors.orange,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrescriptions() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search prescriptions...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: _uploadPrescription,
                icon: const Icon(Icons.upload),
                label: const Text('Upload'),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _prescriptions.length,
            itemBuilder: (context, index) {
              return _buildPrescriptionCard(_prescriptions[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildConsultations() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search consultations...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: _scheduleConsultation,
                icon: const Icon(Icons.add),
                label: const Text('Schedule'),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _upcomingConsultations.length,
            itemBuilder: (context, index) {
              return _buildConsultationCard(_upcomingConsultations[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildInventory() {
    final List<Map<String, dynamic>> _inventory = [
      {'name': 'Paracetamol 500mg', 'stock': 45, 'category': 'Pain Relief', 'lowStock': false},
      {'name': 'Amoxicillin 500mg', 'stock': 18, 'category': 'Antibiotics', 'lowStock': true},
      {'name': 'Vitamin C 1000mg', 'stock': 28, 'category': 'Vitamins', 'lowStock': false},
      {'name': 'Metformin 500mg', 'stock': 12, 'category': 'Diabetes', 'lowStock': true},
      {'name': 'Omeprazole 20mg', 'stock': 22, 'category': 'Gastrointestinal', 'lowStock': false},
      {'name': 'Cetirizine 10mg', 'stock': 35, 'category': 'Allergy', 'lowStock': false},
    ];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search inventory...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: _addNewMedicine,
                icon: const Icon(Icons.add),
                label: const Text('Add'),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _inventory.length,
            itemBuilder: (context, index) {
              return _buildInventoryItem(_inventory[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({required IconData icon, required String title, required String value, required Color color}) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 30),
              const SizedBox(height: 12),
              Text(
                value,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Text(
                title,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            order['prescription'] ? Icons.medical_services : Icons.shopping_cart,
            color: AppTheme.primaryColor,
          ),
        ),
        title: Text('Order ${order['id']}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Customer: ${order['customer']}'),
            Text('${order['items']} items • ${order['amount']}'),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              order['time'],
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Pending',
                style: TextStyle(color: Colors.orange, fontSize: 12),
              ),
            ),
          ],
        ),
        onTap: () => _viewOrderDetails(order),
      ),
    );
  }

  Widget _buildPrescriptionCard(Map<String, dynamic> prescription) {
    Color statusColor;
    switch (prescription['status']) {
      case 'approved':
        statusColor = Colors.green;
        break;
      case 'rejected':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.orange;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Prescription ${prescription['id']}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor),
                  ),
                  child: Text(
                    prescription['status'].toString().toUpperCase(),
                    style: TextStyle(color: statusColor, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('Patient: ${prescription['customer']}'),
            Text('Doctor: ${prescription['doctor']}'),
            Text('Date: ${prescription['date']}'),
            const SizedBox(height: 8),
            const Text('Medicines:', style: TextStyle(fontWeight: FontWeight.w500)),
            Column(
              children: (prescription['medicines'] as List)
                  .map((medicine) => Padding(
                        padding: const EdgeInsets.only(left: 8, top: 4),
                        child: Text('• $medicine'),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (prescription['status'] == 'pending')
                  TextButton(
                    onPressed: () => _approvePrescription(prescription),
                    child: const Text('Approve'),
                  ),
                if (prescription['status'] == 'pending')
                  TextButton(
                    onPressed: () => _rejectPrescription(prescription),
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    child: const Text('Reject'),
                  ),
                IconButton(
                  icon: const Icon(Icons.visibility),
                  onPressed: () => _viewPrescription(prescription),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConsultationCard(Map<String, dynamic> consultation) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Icon(
            consultation['type'] == 'Video Call' ? Icons.video_call : Icons.call,
            color: Colors.green,
          ),
        ),
        title: Text('Consultation ${consultation['id']}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Patient: ${consultation['customer']}'),
            Text('Doctor: ${consultation['doctor']}'),
            Text('Time: ${consultation['time']}'),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => _startConsultation(consultation),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              ),
              child: const Text('Start', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
        onTap: () => _viewConsultationDetails(consultation),
      ),
    );
  }

  Widget _buildInventoryItem(Map<String, dynamic> item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: item['lowStock'] ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            item['lowStock'] ? Icons.warning : Icons.medication,
            color: item['lowStock'] ? Colors.red : Colors.green,
          ),
        ),
        title: Text(item['name']),
        subtitle: Text(item['category']),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${item['stock']} units',
              style: TextStyle(
                color: item['lowStock'] ? Colors.red : Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (item['lowStock'])
              const Text(
                'Low Stock',
                style: TextStyle(fontSize: 12, color: Colors.red),
              ),
          ],
        ),
        onTap: () => _editInventory(item),
      ),
    );
  }

  Widget _buildActivityItem(String title, String time, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title),
                Text(time, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Action Methods
  void _showNotifications() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notifications'),
        content: const SingleChildScrollView(
          child: Column(
            children: [
              ListTile(
                leading: Icon(Icons.shopping_cart, color: Colors.orange),
                title: Text('New order received'),
                subtitle: Text('Order ORD005 from Jane Doe'),
              ),
              ListTile(
                leading: Icon(Icons.medical_services, color: Colors.blue),
                title: Text('Prescription uploaded'),
                subtitle: Text('RX004 from Dr. Robert Kim'),
              ),
              ListTile(
                leading: Icon(Icons.video_call, color: Colors.green),
                title: Text('Consultation reminder'),
                subtitle: Text('CON001 starts in 30 minutes'),
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

  void _openSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pharmacy Settings'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.business),
                title: Text('Pharmacy Information'),
              ),
              ListTile(
                leading: Icon(Icons.schedule),
                title: Text('Business Hours'),
              ),
              ListTile(
                leading: Icon(Icons.payment),
                title: Text('Payment Settings'),
              ),
              ListTile(
                leading: Icon(Icons.notifications),
                title: Text('Notification Preferences'),
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
            onPressed: () => Navigator.pop(context),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _addNewMedicine() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Medicine'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Medicine Name'),
                onChanged: (value) {},
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Category'),
                onChanged: (value) {},
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Price (Fcfa)'),
                keyboardType: TextInputType.number,
                onChanged: (value) {},
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Stock Quantity'),
                keyboardType: TextInputType.number,
                onChanged: (value) {},
              ),
              CheckboxListTile(
                title: const Text('Requires Prescription'),
                value: false,
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
                  content: Text('Medicine added successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Add Medicine'),
          ),
        ],
      ),
    );
  }

  void _uploadPrescription() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Upload Prescription'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Upload prescription image or PDF'),
            SizedBox(height: 20),
            Icon(Icons.cloud_upload, size: 60, color: Colors.blue),
          ],
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
                  content: Text('Prescription uploaded successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Upload'),
          ),
        ],
      ),
    );
  }

  void _scheduleConsultation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Schedule Consultation'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Select Doctor'),
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Select Patient'),
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Date & Time'),
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
                  content: Text('Consultation scheduled successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Schedule'),
          ),
        ],
      ),
    );
  }

  void _viewReports() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Reports feature coming soon!'),
      ),
    );
  }

  void _viewAllOrders() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('View all orders feature coming soon!'),
      ),
    );
  }

  void _viewOrderDetails(Map<String, dynamic> order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Order ${order['id']} Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Customer: ${order['customer']}'),
              Text('Amount: ${order['amount']}'),
              Text('Items: ${order['items']}'),
              Text('Time: ${order['time']}'),
              Text('Status: ${order['status']}'),
              const SizedBox(height: 16),
              const Text('Order Items:', style: TextStyle(fontWeight: FontWeight.bold)),
              const ListTile(
                leading: Icon(Icons.medication, size: 20),
                title: Text('Paracetamol 500mg'),
                subtitle: Text('2 x 500 Fcfa = 1000 Fcfa'),
              ),
              const ListTile(
                leading: Icon(Icons.medication, size: 20),
                title: Text('Vitamin C 1000mg'),
                subtitle: Text('1 x 1500 Fcfa = 1500 Fcfa'),
              ),
              if (order['prescription'])
                const ListTile(
                  leading: Icon(Icons.medical_services, color: Colors.orange),
                  title: Text('Prescription Required'),
                  subtitle: Text('Awaiting verification'),
                ),
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
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Order ${order['id']} processed'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Process Order'),
          ),
        ],
      ),
    );
  }

  void _approvePrescription(Map<String, dynamic> prescription) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve Prescription'),
        content: const Text('Are you sure you want to approve this prescription?'),
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
                  content: Text('Prescription ${prescription['id']} approved'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Approve'),
          ),
        ],
      ),
    );
  }

  void _rejectPrescription(Map<String, dynamic> prescription) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Prescription'),
        content: const Text('Are you sure you want to reject this prescription?'),
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
                  content: Text('Prescription ${prescription['id']} rejected'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  void _viewPrescription(Map<String, dynamic> prescription) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Prescription ${prescription['id']}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Prescription Image:'),
              const SizedBox(height: 12),
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Icon(Icons.picture_as_pdf, size: 60, color: Colors.blue),
                ),
              ),
              const SizedBox(height: 16),
              Text('Doctor: ${prescription['doctor']}'),
              Text('Patient: ${prescription['customer']}'),
              Text('Date: ${prescription['date']}'),
              Text('Status: ${prescription['status']}'),
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

  void _startConsultation(Map<String, dynamic> consultation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Start Consultation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select consultation mode:'),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _launchVideoCall(consultation);
              },
              icon: const Icon(Icons.video_call),
              label: const Text('Start Video Call'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _launchAudioCall(consultation);
              },
              icon: const Icon(Icons.call),
              label: const Text('Start Audio Call'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _openChat(consultation);
              },
              icon: const Icon(Icons.chat),
              label: const Text('Open Chat'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _viewConsultationDetails(Map<String, dynamic> consultation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Consultation ${consultation['id']}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Patient: ${consultation['customer']}'),
              Text('Doctor: ${consultation['doctor']}'),
              Text('Type: ${consultation['type']}'),
              Text('Time: ${consultation['time']}'),
              Text('Status: ${consultation['status']}'),
              const SizedBox(height: 16),
              const Text('Consultation Notes:', style: TextStyle(fontWeight: FontWeight.bold)),
              const TextField(
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Add consultation notes here...',
                  border: OutlineInputBorder(),
                ),
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
                  content: Text('Notes saved successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Save Notes'),
          ),
        ],
      ),
    );
  }

  void _editInventory(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit ${item['name']}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: 'Stock Quantity',
                  hintText: item['stock'].toString(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Reorder Level',
                  hintText: '10',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Price (Fcfa)',
                  hintText: '500',
                ),
                keyboardType: TextInputType.number,
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
                  content: Text('${item['name']} updated successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _launchVideoCall(Map<String, dynamic> consultation) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Starting video call with ${consultation['customer']}'),
        backgroundColor: Colors.green,
      ),
    );
    // TODO: Integrate with video call API (Agora, Zoom, Jitsi)
  }

  void _launchAudioCall(Map<String, dynamic> consultation) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Starting audio call with ${consultation['customer']}'),
        backgroundColor: Colors.blue,
      ),
    );
    // TODO: Integrate with audio call API
  }

  void _openChat(Map<String, dynamic> consultation) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening chat with ${consultation['customer']}'),
        backgroundColor: Colors.purple,
      ),
    );
    // TODO: Integrate with chat API
  }
}