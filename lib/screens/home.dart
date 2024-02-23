import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_c/staff_record_model.dart';

import 'create.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    List<DataColumn> columns = const [
      DataColumn(label: Text('Id')),
      DataColumn(label: Text('First Name')),
      DataColumn(label: Text('Date')),
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Staff Form",
          style: TextStyle(
            color: Colors.blue,
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('Staff').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const CircularProgressIndicator();
          }

          List<DataRow> rows = snapshot.data!.docs.map((doc) {
            Staff staff = Staff.fromDocumentSnapshot(doc);
            return DataRow(
              onSelectChanged: (value) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StaffDetailScreen(staff: staff),
                  ),
                );
              },
              cells: [
                DataCell(Text(staff.id)),
                DataCell(Text(staff.firstName)),
                DataCell(Text(staff.date)),
              ],
            );
          }).toList();

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            // padding: const EdgeInsets.all(16),
            child: DataTable(
              // decoration: BoxDecoration(
              //   borderRadius: BorderRadius.circular(12),
              //   border: Border.all(color: Theme.of(context).dividerColor),
              // ),
              showCheckboxColumn: false,
              columns: columns,
              rows: rows,
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const StaffDetailScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
