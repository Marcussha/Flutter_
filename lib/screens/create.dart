import 'package:flutter/material.dart';
import 'package:flutter_c/database.dart';
import 'package:flutter_dropdown_search/flutter_dropdown_search.dart';
import 'package:intl/intl.dart';
import 'package:random_string/random_string.dart';

import '../API/google_map_api.dart';
import '../staff_record_model.dart';
import '../widgets/input_field.dart';

class StaffDetailScreen extends StatefulWidget {
  const StaffDetailScreen({super.key, this.staff});

  final Staff? staff;

  @override
  State<StaffDetailScreen> createState() => _StaffDetailScreenState();
}

class _StaffDetailScreenState extends State<StaffDetailScreen> {
  late final TextEditingController firstnameController;
  late final TextEditingController lastnameController;
  late final TextEditingController addressController;
  late final TextEditingController cityController;
  late final TextEditingController districtController;
  late final TextEditingController wardController;
  DateTime? selectedDate;
  late final bool isCreate;

  late List<String> selectItemsCity = [];
  late String? selectedCity;
  //
  late List<String> selectItemsDistrict = [];
  late String? selectedDistrict;

  //
  late List<String> selectItemsWard = [];

  @override
  void initState() {
    super.initState();
    isCreate = widget.staff == null;
    firstnameController = TextEditingController(text: widget.staff?.firstName);
    lastnameController = TextEditingController(text: widget.staff?.lastName);
    addressController = TextEditingController(text: widget.staff?.address);
    cityController = TextEditingController(text: widget.staff?.city);
    districtController = TextEditingController(text: widget.staff?.district);
    wardController = TextEditingController(text: widget.staff?.ward);

    fetchProvinces().then((result) {
      setState(() {
        selectItemsCity = result;
        print('Dữ liệu từ API: $selectItemsCity ');
      });
    }).catchError((error) {
      print('Lỗi khi truy xuất API: $error');
    });

    cityController.addListener(() {
      setState(() {
        selectedCity = cityController.text;
        if (selectedCity != null && selectedCity!.isNotEmpty) {
          // Gọi hàm để lấy danh sách quận huyện khi thành phố được chọn
          fetchDistricts(selectedCity!).then((district) {
            setState(() {
              selectItemsDistrict = district;
              print('Dữ liệu từ API: $selectItemsDistrict ');
            });
          }).catchError((error) {
            print('Lỗi khi truy xuất API: $error');
          });
        }
      });
    });

    districtController.addListener(() {
      setState(() {
        selectedDistrict = districtController.text;
        if (selectItemsDistrict != null && selectItemsDistrict!.isNotEmpty) {
          // Gọi hàm để lấy danh sách quận huyện khi thành phố được chọn
          fetchWards(selectedCity!, selectedDistrict!).then((wards) {
            setState(() {
              selectItemsWard = wards;
              print('Dữ liệu từ API: $selectItemsWard ');
            });
          }).catchError((error) {
            print('Lỗi khi truy xuất API: $error');
          });
        }
      });
    });

    if (widget.staff?.date != null) {
      final currentDate = DateTime.tryParse(widget.staff!.date);
      selectedDate = currentDate;
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void onSubmit() {
    String id = randomAlphaNumeric(10);
    Map<String, dynamic> staffInfoMap = {
      "Id": "G24-W-$id",
      "First_Name": firstnameController.text,
      "Last_Name": lastnameController.text,
      "Date": selectedDate.toString(),
      "Address": addressController.text,
      "City": cityController.text,
      "Ward": wardController.text,
      "District": districtController.text,
    };
    DatabaseMethod().addStaff(staffInfoMap, id).then((value) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Staff added successfully!')),
      );
      Navigator.of(context).pop();
    }).onError((error, stackTrace) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add staff. Error: $error')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isCreate)
              const Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: "Create ",
                      style: TextStyle(color: Colors.orange),
                    ),
                    TextSpan(
                      text: "Staff",
                      style: TextStyle(color: Colors.blue),
                    )
                  ],
                ),
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              )
            else
              const Text(
                "Staff Info",
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              )
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: InputField(
                      label: 'First Name',
                      hintText: "Enter first name",
                      firstnameController: firstnameController,
                      enable: isCreate,
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: InputField(
                      label: 'Last Name',
                      hintText: "Enter last name",
                      firstnameController: lastnameController,
                      enable: isCreate,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              _wDateSelection(context),
              const SizedBox(height: 16.0),
              InputField(
                label: "Address",
                firstnameController: addressController,
                enable: isCreate,
              ),
              const SizedBox(height: 16.0),
              FlutterDropdownSearch(
                disable: !isCreate,
                hintText: 'Select City',
                textController: cityController,
                items: selectItemsCity != null ? selectItemsCity : [],
              ),
              SizedBox(height: 12.0),
              FlutterDropdownSearch(
                disable: !isCreate,
                hintText: 'Select District',
                textController: districtController,
                items: selectItemsDistrict != null ? selectItemsDistrict : [],
              ),
              SizedBox(height: 12.0),
              FlutterDropdownSearch(
                disable: !isCreate,
                hintText: 'Select Ward',
                textController: wardController,
                items: selectItemsWard != null ? selectItemsWard : [],
              ),
              const SizedBox(height: 32.0),
              if (isCreate)
                Center(
                  child: FilledButton(
                    onPressed: onSubmit,
                    child: const Text("Create"),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }

  Column _wDateSelection(BuildContext context) {
    late final String label;
    if (selectedDate == null) {
      label = 'Select Date';
    } else {
      label = DateFormat('dd/MM/yyyy').format(selectedDate!);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Date",
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8.0),
        InkWell(
          onTap: isCreate ? () => _selectDate(context) : null,
          child: Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFEBEBEB),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(color: Theme.of(context).hintColor),
                ),
                const Icon(Icons.calendar_today),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
