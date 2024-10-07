import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:gallery/avinya/enrollment/lib/data/person.dart';

class StudentCreate extends StatefulWidget {
  final int? id;
  const StudentCreate({Key? key, this.id}) : super(key: key);

  @override
  State<StudentCreate> createState() => _StudentCreateState();
}

class _StudentCreateState extends State<StudentCreate> {
  late Person userPerson = Person();
  List<District> districts = [];
  List<MainOrganization> organizations = [];
  List<AvinyaType> avinyaTypes = [];
  List<MainOrganization> classes = [];
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? selectedSex;
  int? selectedCityId;
  int? selectedDistrictId;
  int? selectedOrgId;
  int? selectedClassId;
  DateTime? selectedDateOfBirth;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    await fetchDistrictList();
    await fetchOrganizationList();
    await fetchAvinyaTypeList();
  }

  Future<void> fetchDistrictList() async {
    List<District> districtList = await fetchDistricts();
    int? districtId = getDistrictIdByCityId(selectedCityId, districtList);
    if (mounted) {
      setState(() {
        districts = districtList;
        selectedDistrictId = districtId ?? selectedDistrictId;
      });
    }
  }

  Future<void> fetchOrganizationList() async {
    List<MainOrganization> orgList = await fetchOrganizations();
    if (mounted) {
      setState(() {
        organizations = orgList;
      });
    }
  }

  Future<void> fetchAvinyaTypeList() async {
    List<AvinyaType> avinyaTypeList = await fetchAvinyaTypes();
    if (mounted) {
      setState(() {
        avinyaTypes = avinyaTypeList;
      });
    }
  }

  int? getDistrictIdByCityId(int? selectedCityId, List<District> districtList) {
    for (var district in districtList) {
      if (district.cities != null) {
        // Check if cities is not null
        for (var city in district.cities!) {
          // Use the non-null assertion operator
          if (city.id == selectedCityId) {
            return district.id; // Return the district ID if the city ID matches
          }
        }
      }
    }
    return null; // Return null if no matching district is found
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SizedBox(
            width: 800,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // _buildProfileHeader(context),
                  const SizedBox(height: 20),
                  _buildSectionTitle(context, 'Student Information'),
                  _buildEditableField(
                      'Preferred Name', userPerson.preferred_name, (value) {
                    userPerson.preferred_name = value;
                  },
                      validator: (value) =>
                          value!.isEmpty ? 'Preferred name is required' : null),
                  _buildEditableField('Full Name', userPerson.full_name,
                      (value) {
                    userPerson.full_name = value;
                  },
                      validator: (value) =>
                          value!.isEmpty ? 'Full name is required' : null),
                  _buildEditableField('NIC Number', userPerson.nic_no, (value) {
                    userPerson.nic_no = value;
                  }, validator: _validateNIC),
                  _buildDateOfBirthField(context),
                  _buildSexField(),
                  const SizedBox(height: 10),
                  _buildOrganizationField(),
                  _buildStudentClassField(), // Student Class based on organization.description
                  const SizedBox(height: 20),
                  _buildSectionTitle(context, 'Contact Information'),
                  _buildEditableField('Personal Email', userPerson.email,
                      (value) {
                    userPerson.email = value;
                  }), // Email format validation

                  _buildEditableField(
                      'Phone', userPerson.phone?.toString() ?? '', (value) {
                    userPerson.phone = int.tryParse(value);
                  }, validator: _validatePhone),
                  _buildEditableField('Street Address',
                      userPerson.mailing_address?.street_address ?? 'N/A',
                      (value) {
                    if (userPerson.mailing_address == null) {
                      userPerson.mailing_address =
                          Address(street_address: value);
                    } else {
                      userPerson.mailing_address!.street_address = value;
                    }
                  }),
                  _buildDistrictField(),
                  _buildCityField(),
                  const SizedBox(height: 20),
                  _buildSectionTitle(context, 'Digital Information'),
                  _buildEditableField('Digital ID', userPerson.digital_id,
                      (value) {
                    userPerson.digital_id = value;
                  }),
                  _buildAvinyaTypeField(),
                  const SizedBox(height: 20),
                  _buildSectionTitle(context, 'Bank Information'),
                  _buildEditableField('Bank Name', userPerson.bank_name,
                      (value) {
                    userPerson.bank_name = value;
                  }),
                  _buildEditableField('Bank Branch', userPerson.bank_branch,
                      (value) {
                    userPerson.bank_branch = value;
                  }),
                  _buildEditableField(
                      'Bank Account Name', userPerson.bank_account_name,
                      (value) {
                    userPerson.bank_account_name = value;
                  }),
                  _buildEditableField(
                      'Account Number', userPerson.bank_account_number,
                      (value) {
                    userPerson.bank_account_number = value;
                  }),
                  const SizedBox(height: 20),
                  _buildSectionTitle(context, 'Professional Information'),
                  _buildEditableField('Current Job', userPerson.current_job,
                      (value) {
                    userPerson.current_job = value;
                  }),
                  _buildEditableTextArea('Comments', userPerson.notes, (value) {
                    userPerson.notes = value;
                  }),
                  const SizedBox(height: 40),
                  _buildSaveButton(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    final phoneRegex = RegExp(r'^[0-9]+$');
    if (!phoneRegex.hasMatch(value) || value.length < 10) {
      return 'Enter a valid phone number (at least 10 digits)';
    }
    return null;
  }

  String? _validateNIC(String? value) {
    if (value == null || value.isEmpty) {
      return 'NIC Number is required';
    }
    final oldNICRegex = RegExp(r'^\d{9}[vVxX]$');
    final newNICRegex = RegExp(r'^\d{12}$');
    if (!oldNICRegex.hasMatch(value) && !newNICRegex.hasMatch(value)) {
      return 'Enter a valid NIC number (old or new format)';
    }
    return null;
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context)
          .textTheme
          .subtitle1!
          .copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildEditableField(
      String label, String? initialValue, Function(String) onSave,
      {String? Function(String?)? validator}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyText1,
            ),
          ),
          Expanded(
            flex: 6,
            child: TextFormField(
              initialValue: initialValue ?? '',
              decoration: InputDecoration(
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                border: OutlineInputBorder(),
              ),
              onSaved: (value) => onSave(value!),
              validator: validator, // Adding validation here
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableTextArea(
      String label, String? initialValue, Function(String) onSave,
      {int minLines = 1, int maxLines = 5}) {
    // Set maxLines to a desired value for textarea
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyText1,
            ),
          ),
          Expanded(
            flex: 6,
            child: TextFormField(
              initialValue: initialValue ?? '',
              decoration: InputDecoration(
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                border: OutlineInputBorder(),
              ),
              onSaved: (value) => onSave(value!),
              minLines: minLines, // Minimum lines to display
              maxLines: maxLines, // Maximum lines to display
              maxLength: 1000, // Maximum character limit
              buildCounter: (BuildContext context,
                  {required int currentLength,
                  required bool isFocused,
                  required int? maxLength}) {
                return Text(
                  '$currentLength/${maxLength ?? 1000}', // Display character count
                  style: TextStyle(
                    color: currentLength > (maxLength ?? 1000)
                        ? Colors.red
                        : null, // Change color if limit exceeded
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSexField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              'Sex',
              style: Theme.of(context).textTheme.bodyText1,
            ),
          ),
          Expanded(
            flex: 6,
            child: DropdownButtonFormField<String>(
              value: selectedSex,
              items: ['Male', 'Female', 'Other']
                  .map((sex) => DropdownMenuItem(value: sex, child: Text(sex)))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedSex = value;
                  userPerson.sex = value;
                });
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDistrictField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              'District',
              style: Theme.of(context).textTheme.bodyText1,
            ),
          ),
          Expanded(
            flex: 6,
            child: DropdownButtonFormField<int>(
              value: selectedDistrictId,
              items: _getDistrictOptions(),
              onChanged: (value) {
                setState(() {
                  selectedDistrictId = value;
                  userPerson.mailing_address?.district_id = value;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Select District',
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCityField() {
    List<City> cityList = districts
            .firstWhere(
              (district) => district.id == selectedDistrictId,
              orElse: () => District(
                id: 0,
                name: Name(name_en: 'Unknown'),
                cities: [],
              ),
            )
            .cities ??
        [];

    // Ensure selectedCityId is valid or set to null if not found in the current city's list
    if (cityList.isNotEmpty && selectedCityId != null) {
      bool cityExists = cityList.any((city) => city.id == selectedCityId);
      if (!cityExists) {
        selectedCityId = null;
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              'City',
              style: Theme.of(context).textTheme.bodyText1,
            ),
          ),
          Expanded(
            flex: 6,
            child: DropdownButtonFormField<int>(
              value: selectedCityId,
              items: cityList
                  .map((city) => DropdownMenuItem<int>(
                        value: city.id,
                        child: Text(city.name?.name_en ?? 'Unknown City'),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedCityId = value;

                  if (userPerson.mailing_address == null) {
                    // Create a new Address object with city_id set to value
                    userPerson.mailing_address = Address(
                        city_id: value, // Use named parameter for city_id
                        id: null);
                    userPerson.mailing_address!.city = City(
                      id: value, // Use named parameter for city_id
                    );
                  } else {
                    userPerson.mailing_address!.city = City(
                      id: value, // Use named parameter for city_id
                    );
                  }

                  // Debugging: print selected city
                  print("Selected City ID: $selectedCityId");
                });
              },
              decoration: const InputDecoration(
                labelText: 'Select City',
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrganizationField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              'Main Organization',
              style: Theme.of(context).textTheme.bodyText1,
            ),
          ),
          Expanded(
            flex: 6,
            child: DropdownButtonFormField<int>(
              value: userPerson.organization?.parent_organizations?.first.id,
              items: [
                DropdownMenuItem<int>(
                  value: null, // Default item for when no selection is made
                  child: const Text('Select an organization'),
                ),
                ...organizations
                    .where((org) =>
                        org.avinya_type?.id == 105 ||
                        org.avinya_type?.id == 86) // Filter organizations
                    .map((org) {
                  return DropdownMenuItem<int>(
                    value: org.id,
                    child: Text(org.name?.name_en ?? 'Unknown'),
                  );
                }).toList(),
              ],
              onChanged: (int? newValue) async {
                if (newValue != null) {
                  classes = await fetchClasses(newValue);
                }
                setState(() {
                  userPerson.organization_id =
                      newValue; // Update the organization ID
                });
              },
              decoration: InputDecoration(
                labelText: 'Select Organization',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null) {
                  return 'Main organization is required';
                }
                return null; // No error if a value is selected
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvinyaTypeField() {
    // Function to calculate age from a String date of birth
    int? calculateAge(String? birthDateString) {
      if (birthDateString == null || birthDateString.isEmpty) return null;

      try {
        final birthDate =
            DateTime.parse(birthDateString); // Parse the date string
        final currentDate = DateTime.now();
        int age = currentDate.year - birthDate.year;
        if (currentDate.month < birthDate.month ||
            (currentDate.month == birthDate.month &&
                currentDate.day < birthDate.day)) {
          age--;
        }
        return age;
      } catch (e) {
        // Handle invalid date format
        print('Invalid date format: $birthDateString');
        return null;
      }
    }

    // Determine the Avinya Type ID
    final int? avinyaTypeId = (userPerson.date_of_birth != null &&
            calculateAge(userPerson.date_of_birth) != null &&
            calculateAge(userPerson.date_of_birth)! < 19)
        ? 103 // Auto-select Future Enrollees if under 18
        : (userPerson.avinya_type_id ??
            userPerson.avinya_type
                ?.id); // Fallback to avinya_type?.id if avinya_type_id is null

    // Filter avinyaTypes based on the selected IDs
    final filteredAvinyaTypes = avinyaTypes.where((org) {
      return org.id == 26 || // student applicant
          org.id == 37 || // empower-student
          org.id == 10 || // Vocational IT
          org.id == 96 || // Vocational CS
          org.id == 93 || // dropout-empower-student
          org.id == 100 || // dropout-cs-student
          org.id == 99 || // dropout-it-student
          org.id == 103 || // Future Enrollees
          org.id == 94; // dropout-student-applicant
    }).toList();

    filteredAvinyaTypes.any((org) => org.id == avinyaTypeId)
        ? userPerson.avinya_type_id = avinyaTypeId
        : null;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              'Avinya Type',
              style: Theme.of(context).textTheme.bodyText1,
            ),
          ),
          Expanded(
            flex: 6,
            child: DropdownButtonFormField<int>(
              // Ensure the value matches one of the filtered Avinya Types
              value: filteredAvinyaTypes.any((org) => org.id == avinyaTypeId)
                  ? avinyaTypeId
                  : null,
              items: filteredAvinyaTypes.map((org) {
                return DropdownMenuItem<int>(
                  value: org.id,
                  child: Text(org.name ?? 'Unknown'),
                );
              }).toList(),
              onChanged: (int? newValue) {
                setState(() {
                  userPerson.avinya_type_id =
                      newValue; // Update the Avinya Type ID
                });
              },
              decoration: const InputDecoration(
                labelText: 'Select Avinya Type',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null) {
                  return 'Avinya Type is required';
                }
                return null; // No error if a value is selected
              },
            ),
          ),
        ],
      ),
    );
  }

  List<DropdownMenuItem<int>> _getDistrictOptions() {
    return districts.map((district) {
      return DropdownMenuItem<int>(
        value: district.id as int,
        child: Text(district.name?.name_en ?? 'Unknown'),
      );
    }).toList();
  }

  List<DropdownMenuItem<int>> _getClassOptions() {
    return classes
        .map((classe) => DropdownMenuItem<int>(
              value: classe.id, // Access id directly from MainOrganization
              child: Text(classe.description ??
                  'No description'), // Handle null description
            ))
        .toList();
  }

  Widget _buildSaveButton(context) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            _formKey.currentState!.save();
            // Save userPerson changes
            createPerson(context, userPerson);
          }
        },
        child: const Text('Create Student'),
      ),
    );
  }

  Widget _buildDateOfBirthField(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              'Date of Birth',
              style: Theme.of(context).textTheme.bodyText1,
            ),
          ),
          Expanded(
            flex: 6,
            child: InkWell(
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: selectedDateOfBirth ?? DateTime(2000),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                );
                if (pickedDate != null) {
                  setState(() {
                    selectedDateOfBirth = pickedDate;
                    userPerson.date_of_birth =
                        DateFormat('yyyy-MM-dd').format(pickedDate);
                  });
                }
              },
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Select Date Of Birth',
                  border: OutlineInputBorder(),
                ),
                child: Text(
                  selectedDateOfBirth == null
                      ? 'Select Date'
                      : DateFormat('d MMM, yyyy').format(selectedDateOfBirth!),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentClassField() {
    if (classes.isEmpty) {
      return Container();
    } else {
      // Ensure selectedClassId exists in the class list, otherwise set it to null
      final isValidClass = classes.any((cls) => cls.id == selectedClassId);

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Expanded(
              flex: 4,
              child: Text(
                'Class',
                style: Theme.of(context).textTheme.bodyText1,
              ),
            ),
            Expanded(
              flex: 6,
              child: DropdownButtonFormField<int>(
                value: isValidClass
                    ? selectedClassId
                    : null, // Validate selectedClassId
                items: _getClassOptions(),
                onChanged: (value) {
                  setState(() {
                    selectedClassId = value;
                    userPerson.organization?.id = value;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Select Class',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }
}
