import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fikraa/screens/signup_screen.dart'; // Import the SignUpScreen
import 'package:fikraa/screens/home_screen.dart';
import 'package:fikraa/screens/data_screen.dart';

class UserManagementScreen extends StatefulWidget {
  final String userEmail;

  const UserManagementScreen({Key? key, required this.userEmail}) : super(key: key);

  @override
  _UserManagementScreenState createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  List<Map<String, dynamic>> userDocs = []; // To store user data (name, email, phone, docId)
  List<Map<String, dynamic>> filteredDocs = []; // To store filtered user data
  TextEditingController searchController = TextEditingController(); // Controller for the search bar

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
    print('User email: ${widget.userEmail}'); // Use widget.userEmail to access it
  }

  // Fetch all user details (name, email, phone) and their corresponding docIds
  Future<void> _fetchUserDetails() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('users').get();
      setState(() {
        userDocs = querySnapshot.docs.map((doc) {
          return {
            'name': doc['name'],   // Fetch the name
            'email': doc['email'], // Fetch the email
            'phone': doc['phone'], // Fetch the phone number
            'docId': doc.id,       // Fetch the document ID
          };
        }).toList();
        filteredDocs = List.from(userDocs); // Initialize filteredDocs with all users
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching users: $e'))
      );
    }
  }

  // Delete a user by their document ID
  Future<void> _deleteUser(String docId) async {
    bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.indigo.shade50,
          title: Text('Confirmation'),
          content: Text('Are you sure you want to delete this user?'),
          actions: <Widget>[
            TextButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            ElevatedButton(
              child: Text('Yes'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(docId).delete();
        _fetchUserDetails(); // Refresh the user list after deletion
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User deleted successfully.')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting user: $e')),
        );
      }
    }
  }

  // Show dialog to edit user details (name, email, phone)
  Future<void> _showEditDialog(String docId, String currentName, String currentEmail, String currentPhone) async {
    TextEditingController nameController = TextEditingController(text: currentName);
    TextEditingController emailController = TextEditingController(text: currentEmail);
    TextEditingController phoneController = TextEditingController(text: currentPhone);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.indigo.shade50,
          title: Text('Edit User'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: phoneController,
                decoration: InputDecoration(labelText: 'Phone'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('Save'),
              onPressed: () async {
                try {
                  await FirebaseFirestore.instance.collection('users').doc(docId).update({
                    'name': nameController.text,
                    'email': emailController.text,
                    'phone': phoneController.text,
                  });
                  Navigator.of(context).pop();
                  _fetchUserDetails(); // Refresh the list after update
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('User updated successfully.')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error updating user: $e')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  // Filter users based on the search query
  void _filterUsers(String query) {
    final filtered = userDocs.where((user) {
      return user['name'].toLowerCase().contains(query.toLowerCase()) ||
          user['email'].toLowerCase().contains(query.toLowerCase()) ||
          user['phone'].toLowerCase().contains(query.toLowerCase());
    }).toList();

    setState(() {
      filteredDocs = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo.shade50,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50),
        child: AppBar(
          backgroundColor: Colors.indigo.shade50,
          leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: const Icon(
              Icons.arrow_back_ios,
              color: Colors.indigo,
            ),
          ),
          actions: [
            PopupMenuButton<String>(
              icon: const Icon(Icons.menu, color: Colors.indigo),
              onSelected: (value) {
                switch (value) {
                  case 'home':
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HomePage(),
                      ),
                    );
                    break;
                  case 'data':
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DataScreen(),
                      ),
                    );
                    break;
                }
              },
              itemBuilder: (BuildContext context) {
                return [
                  PopupMenuItem<String>(
                    value: 'home',
                    child: Row(
                      children: [
                        const Icon(Icons.home, color: Colors.indigo),
                        const SizedBox(width: 8),
                        const Text('Home'),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'data',
                    child: Row(
                      children: [
                        const Icon(Icons.data_usage, color: Colors.indigo),
                        const SizedBox(width: 8),
                        const Text('Data'),
                      ],
                    ),
                  ),
                ];
              },
            ),
            const SizedBox(width: 16),
          ],
          title: SizedBox(),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: searchController,
              onChanged: _filterUsers,
              decoration: InputDecoration(
                hintText: 'Search for a user...',
                hintStyle: TextStyle(color: Colors.indigo.shade200),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.indigo.shade200),
                ),
                prefixIcon: Icon(Icons.search, color: Colors.indigo),
              ),
            ),
          ),
          Expanded(
            child: filteredDocs.isEmpty
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: filteredDocs.length,
                    itemBuilder: (context, index) {
                      final userName = filteredDocs[index]['name'];
                      final userEmail = filteredDocs[index]['email'];
                      final userPhone = filteredDocs[index]['phone'];
                      final docId = filteredDocs[index]['docId'];
                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                        child: ListTile(
                          contentPadding: EdgeInsets.all(16),
                          title: Text(userName, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Email: $userEmail', style: TextStyle(fontSize: 14, color: Colors.indigo)),
                              Text('Phone: $userPhone', style: TextStyle(fontSize: 14, color: Colors.indigo)),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.indigo),
                                onPressed: () {
                                  _showEditDialog(docId, userName, userEmail, userPhone);
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.indigo),
                                onPressed: () {
                                  _deleteUser(docId);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SignUpScreen()),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.indigo,
      ),
    );
  }
}
