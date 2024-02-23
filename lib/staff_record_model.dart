import 'package:cloud_firestore/cloud_firestore.dart';

class Staff {
  final String id;
  final String firstName;
  final String lastName;
  final String date;
  final String address;
  final String city;
  final String district;
  final String ward;

  Staff({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.date,
    required this.address,
    required this.city,
    required this.district,
    required this.ward,
  });

  factory Staff.fromDocumentSnapshot(DocumentSnapshot doc) {
    return Staff(
      id: doc['Id'],
      firstName: doc['First_Name'],
      lastName: doc['Last_Name'],
      date: doc['Date'],
      address: doc['Address'],
      city: doc['City'],
      district: doc['District'],
      ward: doc['Ward'],
    );
  }
}
