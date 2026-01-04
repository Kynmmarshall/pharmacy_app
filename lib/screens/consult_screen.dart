import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pharmacy_app/themes/app_theme.dart';
import 'package:pharmacy_app/providers/auth_provider.dart';

class ConsultScreen extends ConsumerStatefulWidget {
  const ConsultScreen({super.key});

  @override
  ConsumerState<ConsultScreen> createState() => _ConsultScreenState();
}

class _ConsultScreenState extends ConsumerState<ConsultScreen> {
  int _selectedCategory = 0;
  final List<String> _categories = [
    'General Physician',
    'Pediatrician',
    'Dermatologist',
    'Cardiologist',
    'Gynecologist',
    'Psychiatrist',
    'ENT Specialist',
    'Dentist',
  ];

  final List<Map<String, dynamic>> _doctors = [
    {
      'name': 'Dr. Sarah Johnson',
      'specialization': 'General Physician',
      'experience': '10 years',
      'rating': 4.8,
      'patients': '2.5k+',
      'fee': '3000 Fcfa',
      'available': true,
      'image': 'assets/doctors/doctor1.jpg',
      'nextSlot': '10:30 AM',
    },
    {
      'name': 'Dr. Michael Chen',
      'specialization': 'Pediatrician',
      'experience': '8 years',
      'rating': 4.9,
      'patients': '1.8k+',
      'fee': '3500 Fcfa',
      'available': true,
      'image': 'assets/doctors/doctor2.jpg',
      'nextSlot': '11:15 AM',
    },
    {
      'name': 'Dr. Priya Sharma',
      'specialization': 'Dermatologist',
      'experience': '12 years',
      'rating': 4.7,
      'patients': '3.2k+',
      'fee': '4000 Fcfa',
      'available': false,
      'image': 'assets/doctors/doctor3.jpg',
      'nextSlot': 'Tomorrow',
    },
    {
      'name': 'Dr. Robert Kim',
      'specialization': 'Cardiologist',
      'experience': '15 years',
      'rating': 4.9,
      'patients': '4.1k+',
      'fee': '5000 Fcfa',
      'available': true,
      'image': 'assets/doctors/doctor4.jpg',
      'nextSlot': '2:00 PM',
    },
    {
      'name': 'Dr. Lisa Wang',
      'specialization': 'Gynecologist',
      'experience': '9 years',
      'rating': 4.8,
      'patients': '2.3k+',
      'fee': '3800 Fcfa',
      'available': true,
      'image': 'assets/doctors/doctor5.jpg',
      'nextSlot': '1:30 PM',
    },
  ];

  final List<Map<String, dynamic>> _symptoms = [
    {'icon': Icons.coronavirus, 'label': 'Fever & Cold'},
    {'icon': Icons.favorite, 'label': 'Heart'},
    {'icon': Icons.air, 'label': 'Allergy'},
    {'icon': Icons.psychology, 'label': 'Mental Health'},
    {'icon': Icons.sick, 'label': 'Stomach'},
    {'icon': Icons.boy, 'label': 'Child Care'},
    {'icon': Icons.face, 'label': 'Skin'},
    {'icon': Icons.self_improvement, 'label': 'General'},
  ];

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoggedIn = authState.isAuthenticated;
    final userName = authState.user?['name'] ?? 'Guest';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Teleconsultation'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.video_call),
            onPressed: () => _showMyAppointments(context),
          ),
        ],
      ),
      body: !isLoggedIn
          ? _buildLoginRequired()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Section
                  _buildWelcomeSection(userName),
                  
                  const SizedBox(height: 24),
                  
                  // Quick Symptoms
                  _buildSymptomsSection(),
                  
                  const SizedBox(height: 24),
                  
                  // Doctor Categories
                  _buildCategoriesSection(),
                  
                  const SizedBox(height: 24),
                  
                  // Available Doctors
                  _buildDoctorsSection(),
                  
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildLoginRequired() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.medical_services,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 20),
          const Text(
            'Login Required',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const Text(
            'Please login to access teleconsultation services',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () => context.go('/'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
            ),
            child: const Text(
              'Login Now',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection(String userName) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryColor.withOpacity(0.8),
            AppTheme.primaryColor.withOpacity(0.4),
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
                Text(
                  'Hello, $userName!',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Consult with certified doctors from the comfort of your home',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _searchDoctors,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.primaryColor,
                  ),
                  child: const Text('Find a Doctor'),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          const Icon(
            Icons.medical_services,
            size: 80,
            color: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildSymptomsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'What are your symptoms?',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Select your symptoms to find the right specialist',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _symptoms.length,
            itemBuilder: (context, index) {
              final symptom = _symptoms[index];
              return GestureDetector(
                onTap: () => _selectSymptom(symptom['label']),
                child: Container(
                  width: 90,
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        symptom['icon'],
                        size: 30,
                        color: AppTheme.primaryColor,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        symptom['label'],
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoriesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Specialties',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Choose from various medical specialties',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: ChoiceChip(
                  label: Text(_categories[index]),
                  selected: _selectedCategory == index,
                  selectedColor: AppTheme.primaryColor,
                  labelStyle: TextStyle(
                    color: _selectedCategory == index ? Colors.white : Colors.black,
                  ),
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategory = selected ? index : 0;
                    });
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDoctorsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Available Doctors',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: _viewAllDoctors,
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Text(
          'Certified doctors available for consultation',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _doctors.length,
          itemBuilder: (context, index) {
            final doctor = _doctors[index];
            return _buildDoctorCard(doctor, context);
          },
        ),
      ],
    );
  }

  Widget _buildDoctorCard(Map<String, dynamic> doctor, BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                // Doctor Image
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(35),
                  ),
                  child: Icon(
                    Icons.person,
                    size: 40,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(width: 16),
                
                // Doctor Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doctor['name'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        doctor['specialization'],
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            size: 16,
                            color: Colors.amber,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${doctor['rating']}',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.people,
                            size: 16,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            doctor['patients'],
                            style: const TextStyle(fontSize: 12),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.schedule,
                            size: 16,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            doctor['experience'],
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Availability Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: doctor['available'] ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: doctor['available'] ? Colors.green : Colors.red,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    doctor['available'] ? 'Available' : 'Busy',
                    style: TextStyle(
                      color: doctor['available'] ? Colors.green : Colors.red,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Doctor Footer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Consultation Fee',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Text(
                      doctor['fee'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Next Available',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Text(
                      doctor['nextSlot'],
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: doctor['available']
                      ? () => _bookConsultation(doctor, context)
                      : null,
                  icon: const Icon(Icons.video_call, size: 18),
                  label: const Text('Book Now'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _selectSymptom(String symptom) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Searching doctors for: $symptom'),
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {},
        ),
      ),
    );
  }

  void _searchDoctors() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Doctors'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Search by specialty, doctor name',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }

  void _viewAllDoctors() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('View all doctors feature coming soon!'),
      ),
    );
  }

  void _bookConsultation(Map<String, dynamic> doctor, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Book Consultation with ${doctor['name']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select consultation type:'),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.video_call, color: AppTheme.primaryColor),
              title: const Text('Video Call'),
              subtitle: const Text('Face-to-face video consultation'),
              onTap: () => _confirmBooking(doctor, 'Video Call', context),
            ),
            ListTile(
              leading: const Icon(Icons.call, color: AppTheme.primaryColor),
              title: const Text('Audio Call'),
              subtitle: const Text('Voice-only consultation'),
              onTap: () => _confirmBooking(doctor, 'Audio Call', context),
            ),
            ListTile(
              leading: const Icon(Icons.chat, color: AppTheme.primaryColor),
              title: const Text('Chat Consultation'),
              subtitle: const Text('Text-based consultation'),
              onTap: () => _confirmBooking(doctor, 'Chat', context),
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

  void _confirmBooking(Map<String, dynamic> doctor, String type, BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Confirm Booking'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Doctor: ${doctor['name']}'),
          Text('Specialty: ${doctor['specialization']}'),
          Text('Type: $type Consultation'),
          Text('Fee: ${doctor['fee']}'),
          const SizedBox(height: 16),
          const Text(
            'By proceeding, you agree to our consultation terms and privacy policy.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            // Close dialogs FIRST, then show snackbar
            Navigator.of(context)
              ..pop() // Close confirm dialog
              ..pop(); // Close booking dialog
            
            // Use Future.delayed to ensure context is still valid
            Future.delayed(Duration.zero, () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Booking confirmed with ${doctor['name']} feature coming soon!'),
                  backgroundColor: Colors.green,
                ),
              );
            });
          },
          child: const Text('Confirm & Pay'),
        ),
      ],
    ),
  );
}
  void _showMyAppointments(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('My Appointments feature coming soon!'),
      ),
    );
  }

}