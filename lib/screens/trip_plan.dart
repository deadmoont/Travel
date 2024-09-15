import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TripPlansScreen extends StatefulWidget {
  final int serialNumber;

  TripPlansScreen({required this.serialNumber});

  @override
  _TripPlansScreenState createState() => _TripPlansScreenState();
}

class _TripPlansScreenState extends State<TripPlansScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _userName;

  @override
  void initState() {
    super.initState();
    _fetchUserName(); // Fetch user name when the widget is initialized
    _fetchTravellers(); // Fetch travellers' names when the widget is initialized
  }

  Future<void> _fetchUserName() async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId != null) {
      // Get the user's name from Firestore (assuming users collection has name field)
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();
      setState(() {
        _userName = userDoc['name'] ?? 'Traveler'; // Fallback to 'Traveler' if name is not found
      });
    }
  }
  // Future<void> _fetchTravellers() async {
  //   String? userId = FirebaseAuth.instance.currentUser?.uid;
  //
  //   if (userId != null) {
  //     CollectionReference tripTravellersCollection = _firestore
  //         .collection('users')
  //         .doc(userId)
  //         .collection('trips')
  //         .doc(widget.serialNumber.toString())
  //         .collection('travellers');
  //
  //     QuerySnapshot travellersSnapshot = await tripTravellersCollection.get();
  //     setState(() {
  //       _travellers = travellersSnapshot.docs
  //           .map((doc) => doc['name'] as String)
  //           .toList();
  //     });
  //   }
  // }

  void _showAddPlanDialog() {
    final TextEditingController planController = TextEditingController();
    final TextEditingController timeController = TextEditingController();
    final TextEditingController dateController = TextEditingController();
    final TextEditingController venueController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text(
            'Add New Plan',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _buildTextField(planController, 'Plan', Icons.edit),
                SizedBox(height: 12),
                _buildTextField(timeController, 'Time', Icons.access_time, isTime: true),
                SizedBox(height: 12),
                _buildTextField(dateController, 'Date', Icons.calendar_today, isDate: true),
                SizedBox(height: 12),
                _buildTextField(venueController, 'Venue', Icons.location_on),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Add Plan', style: TextStyle(color: Colors.teal)),
              onPressed: () async {
                if (planController.text.isNotEmpty &&
                    timeController.text.isNotEmpty &&
                    dateController.text.isNotEmpty &&
                    venueController.text.isNotEmpty) {
                  await _addPlan(
                    planController.text,
                    timeController.text,
                    dateController.text,
                    venueController.text,
                  );
                  Navigator.of(context).pop(); // Close dialog after adding
                }
              },
            ),
            TextButton(
              child: Text('Cancel', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isTime = false, bool isDate = false}) {
    return TextField(
      controller: controller,
      readOnly: isTime || isDate,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.teal),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        suffixIcon: isTime || isDate
            ? IconButton(
          icon: Icon(Icons.arrow_drop_down, color: Colors.teal),
          onPressed: () {
            if (isTime) {
              _selectTime(context, controller);
            } else if (isDate) {
              _selectDate(context, controller);
            }
          },
        )
            : null,
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    DateTime currentDate = DateTime.now();
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (selectedDate != null && selectedDate != currentDate) {
      controller.text = "${selectedDate.toLocal()}".split(' ')[0];
    }
  }

  Future<void> _selectTime(BuildContext context, TextEditingController controller) async {
    TimeOfDay currentTime = TimeOfDay.now();
    TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: currentTime,
    );
    if (selectedTime != null && selectedTime != currentTime) {
      controller.text = "${selectedTime.format(context)}";
    }
  }

  Future<void> _addPlan(String newPlan, String newTime, String newDate, String newVenue) async {
    try {
      String? userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        print('User not authenticated');
        return;
      }

      CollectionReference plansCollection = _firestore
          .collection('users')
          .doc(userId)
          .collection('trips')
          .doc(widget.serialNumber.toString())
          .collection('plans');

      await plansCollection.add({
        'plan': newPlan,
        'time': newTime,
        'date': newDate,
        'venue': newVenue,
      });
    } catch (e) {
      print('Error adding plan: $e');
    }
  }

  Future<void> _deletePlan(String planId) async {
    try {
      String? userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        print('User not authenticated');
        return;
      }

      CollectionReference plansCollection = _firestore
          .collection('users')
          .doc(userId)
          .collection('trips')
          .doc(widget.serialNumber.toString())
          .collection('plans');

      await plansCollection.doc(planId).delete();
    } catch (e) {
      print('Error deleting plan: $e');
    }
  }

  List<String> _travellers = []; // List to store added travellers

  void _showSearchDialog() {
    final TextEditingController searchController = TextEditingController();
    List<Map<String, dynamic>> searchResults = [];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              title: Text(
                'Search and Add Traveller',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        labelText: 'Search by Name',
                        prefixIcon: Icon(Icons.search, color: Colors.teal),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          _searchUsersByName(value).then((results) {
                            setState(() {
                              searchResults = results;
                            });
                          });
                        } else {
                          setState(() {
                            searchResults = [];
                          });
                        }
                      },
                    ),
                    SizedBox(height: 12),
                    // Display search results
                    Column(
                      children: searchResults.map((result) {
                        return ListTile(
                          title: Text(result['name']),
                          trailing: IconButton(
                            icon: Icon(Icons.add, color: Colors.teal),
                            onPressed: () async {
                              await _addTravellerToTrip(result['name']);
                              Navigator.of(context).pop(); // Close dialog
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Cancel', style: TextStyle(color: Colors.red)),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<List<Map<String, dynamic>>> _searchUsersByName(String query) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: query + '\uf8ff')
          .get();

      return querySnapshot.docs
          .map((doc) => {'name': doc['name'], 'id': doc.id})
          .toList();
    } catch (e) {
      print('Error searching users: $e');
      return [];
    }
  }
  Future<void> _fetchTravellers() async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId != null) {
      CollectionReference tripTravellersCollection = _firestore
          .collection('users')
          .doc(userId)
          .collection('trips')
          .doc(widget.serialNumber.toString())
          .collection('travellers');

      try {
        QuerySnapshot travellersSnapshot = await tripTravellersCollection.get();
        print('Fetched travellers snapshot: ${travellersSnapshot.docs.length}');
        setState(() {
          _travellers = travellersSnapshot.docs
              .map((doc) => doc['name'] as String)
              .toList();
          print('Travellers names: $_travellers');
        });
      } catch (e) {
        print('Error fetching travellers: $e');
      }
    } else {
      print('User ID is null');
    }
  }


  Future<List<String>> _fetchUserNames(List<String> uids) async {
    List<String> names = [];

    for (String uid in uids) {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(uid).get();
      if (userDoc.exists) {
        names.add(userDoc['name'] ?? 'Unknown');
      }
    }

    return names;
  }


  Future<void> _addTravellerToTrip(String travellerName) async {
    try {
      // Get the current user's ID
      String? userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        print('User not authenticated');
        return;
      }

      // Reference to the travellers collection for the current trip
      CollectionReference tripTravellersCollection = _firestore
          .collection('users')
          .doc(userId)
          .collection('trips')
          .doc(widget.serialNumber.toString())
          .collection('travellers');

      // Check if the traveller already exists
      QuerySnapshot existingTraveller = await tripTravellersCollection
          .where('name', isEqualTo: travellerName)
          .get();

      if (existingTraveller.docs.isNotEmpty) {
        print('Traveller already exists');
        return;
      }

      // Add traveller to Firestore
      await tripTravellersCollection.add({
        'name': travellerName,
        'addedAt': FieldValue.serverTimestamp(), // Optional: Timestamp for when the traveller was added
      });

      // Update the state to show the added traveller
      setState(() {
        _travellers.add(travellerName);
      });
    } catch (e) {
      print('Error adding traveller: $e');
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Plans for Trip ${widget.serialNumber}'),
        backgroundColor: Colors.teal,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser?.uid)
            .collection('trips')
            .doc(widget.serialNumber.toString())
            .collection('plans')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          List<QueryDocumentSnapshot> planDocs = snapshot.data!.docs;
          List<Map<String, dynamic>> _plans = planDocs.map((doc) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            return {
              'id': doc.id,
              'plan': data['plan'].toString(),
              'time': data['time'].toString(),
              'date': data['date'].toString(),
              'venue': data['venue'].toString(),
            };
          }).toList();

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                ElevatedButton(
                  onPressed: _showAddPlanDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  ),
                  child: Text('Add New Plan', style: TextStyle(fontSize: 16)),
                ),
                SizedBox(height: 20),

                SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    itemCount: _plans.length,
                    itemBuilder: (context, index) {
                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 8),
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.all(16),
                          title: Text(
                            _plans[index]['plan']!,
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          subtitle: Text(
                            'Time: ${_plans[index]['time']} | Date: ${_plans[index]['date']} | Venue: ${_plans[index]['venue']}',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    title: Text(
                                      'Delete Plan',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    content: Text('Are you sure you want to delete this plan?'),
                                    actions: <Widget>[
                                      TextButton(
                                        child: Text('Delete', style: TextStyle(color: Colors.red)),
                                        onPressed: () {
                                          _deletePlan(_plans[index]['id']);
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                      TextButton(
                                        child: Text('Cancel', style: TextStyle(color: Colors.teal)),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 20),
                _userName != null
                    ? Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: Offset(0, 3),
                      ),
                    ],
                    border: Border.all(color: Colors.teal, width: 2),
                  ),
                  padding: EdgeInsets.all(16),
                  margin: EdgeInsets.only(top: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Travellers:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        _userName!,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 12),
                      ..._travellers.map((traveller) => Text(
                        traveller,
                        style: TextStyle(fontSize: 16, color: Colors.black87),
                      )),
                      SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _showSearchDialog,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                        ),
                        child: Text('Add Traveller', style: TextStyle(fontSize: 16)),
                      ),
                    ],
                  ),
                )
                    : SizedBox(),
              ],
            ),
          );
        },
      ),
    );
  }


}

