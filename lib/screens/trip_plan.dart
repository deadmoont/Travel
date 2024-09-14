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
              'id': doc.id, // Include the document ID
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
                                    title: Text('Delete Plan', style: TextStyle(fontSize: 18)),
                                    content: Text('Are you sure you want to delete this plan?'),
                                    actions: <Widget>[
                                      TextButton(
                                        child: Text('Cancel', style: TextStyle(color: Colors.teal)),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                      TextButton(
                                        child: Text('Delete', style: TextStyle(color: Colors.red)),
                                        onPressed: () async {
                                          await _deletePlan(_plans[index]['id']!);
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
              ],
            ),
          );
        },
      ),
    );
  }
}
