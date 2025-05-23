import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:gallery/avinya/enrollment/lib/widgets/file_upload_widget.dart';
import 'package:intl/intl.dart';
import 'package:gallery/avinya/enrollment/lib/data/person.dart';

class StudentUpdate extends StatefulWidget {
  final int? id;
  const StudentUpdate({Key? key, this.id}) : super(key: key);

  @override
  State<StudentUpdate> createState() => _StudentUpdateState();
}

class _StudentUpdateState extends State<StudentUpdate> {
  late Person userPerson = Person();
  List<District> districts = [];
  List<MainOrganization> organizations = [];
  List<AvinyaType> avinyaTypes = [];
  List<MainOrganization> classes = [];
  int _currentStep = 0; // Track the current step
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  List<City> cityList = [];
  late Person updatedPerson = Person();
  List<UserDocument> userDocuments = [];

  String? selectedSex;
  int? selectedCityId;
  int? selectedDistrictId;
  int? selectedOrgId;
  int? selectedClassId;
  DateTime? selectedDateOfBirth;

  bool isDistrictsDataLoaded = false;
  bool isOrganizationsDataLoaded = false;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    await getUserPerson();
    await fetchAvinyaTypeList();
  }

  // Future<void> getUserPerson() async {
  //   Person user = await fetchPerson(widget.id);
  //   classes = await fetchClasses(
  //       (user.organization?.parent_organizations?.isNotEmpty ?? false)
  //           ? user.organization?.parent_organizations?.first.id
  //           : null);

  //   setState(() {
  //     classes = classes;
  //     userPerson = user;
  //     selectedSex = userPerson.sex;
  //     userPerson.avinya_type_id = user.avinya_type_id;
  //     selectedDistrictId = user.mailing_address?.city?.district!.id;
  //     // Safely assign city and organization IDs with fallbacks
  //     selectedCityId = userPerson.mailing_address?.city?.id ??
  //         0; // Default to 0 or another fallback value
  //     if (selectedDistrictId != null) {
  //       _loadCities(selectedDistrictId, selectedCityId);
  //     }

  //     selectedOrgId =
  //         userPerson.organization?.id ?? 0; // Similarly handle organization ID
  //     selectedClassId = userPerson.organization?.id ??
  //         0; // Ensure organization ID is used for class as well

  //     // Handling date of birth
  //     String? dob = userPerson.date_of_birth;
  //     print("Date of Birth String: $dob");

  //     // Safely try parsing the date of birth
  //     if (dob == null || dob.isEmpty) {
  //       selectedDateOfBirth = DateTime.now(); // Default if dob is null or empty
  //     } else {
  //       try {
  //         selectedDateOfBirth =
  //             DateTime.parse(dob); // Use DateTime.parse directly
  //       } catch (e) {
  //         print('Error parsing date: $e');
  //         selectedDateOfBirth =
  //             DateTime.now(); // Fallback to now if parsing fails
  //       }
  //     }
  //   });
  // }
  Future<void> getUserPerson() async {
    try {
      Person user = await fetchPerson(widget.id);

      // Safely check if parent_organizations exist and are not empty
      final parentOrganizationId =
          (user.organization?.parent_organizations?.isNotEmpty ?? false)
              ? user.organization?.parent_organizations?.first.id
              : null;

      // Fetch classes with a fallback to an empty list if null
      if (parentOrganizationId != null) {
        classes = await fetchClasses(parentOrganizationId);
      } else {
        classes = [];
      }

      setState(() {
        userPerson = user;
        selectedSex = userPerson.sex;
        userPerson.avinya_type_id = user.avinya_type_id;
        userPerson.documents_id = user.documents_id ?? 0;

        // Safely assign district, city, and organization IDs with fallbacks
        selectedDistrictId = user.mailing_address?.city?.district?.id;
        selectedCityId = userPerson.mailing_address?.city?.id ?? 0;
        if (selectedDistrictId != null) {
          _loadCities(selectedDistrictId, selectedCityId);
        }

        selectedOrgId = userPerson.organization?.id ?? 0;
        selectedClassId =
            (userPerson.organization != null) ? userPerson.organization!.id : 0;

        // Handling date of birth safely
        String? dob = userPerson.date_of_birth;
        print("Date of Birth String: $dob");

        if (dob == null || dob.isEmpty) {
          selectedDateOfBirth = DateTime.now();
        } else {
          try {
            selectedDateOfBirth = DateTime.parse(dob);
          } catch (e) {
            print('Error parsing date: $e');
            selectedDateOfBirth = DateTime.now();
          }
        }
      });
    } catch (e) {
      print('Error fetching user data: $e');
      // Optionally handle the error further, e.g., show a dialog or fallback UI
    }
  }

  Future<List<District>> fetchDistrictList() async {
    return await fetchDistricts();
  }

  // Future<void> fetchDistrictList() async {
  //   List<District> districtList = await fetchDistricts();
  //   int? districtId = getDistrictIdByCityId(selectedCityId, districtList);
  //   if (mounted) {
  //     setState(() {
  //       districts = districtList;
  //       selectedDistrictId = districtId ?? selectedDistrictId;
  //     });
  //   }
  // }
  Future<List<MainOrganization>> fetchOrganizationList() async {
    final result = await fetchOrganizations();
    return result ?? []; // Fallback to an empty list
  }

  // Future<void> fetchOrganizationList() async {
  //   List<MainOrganization> orgList = await fetchOrganizations();
  //   if (mounted) {
  //     setState(() {
  //       organizations = orgList;
  //     });
  //   }
  // }

  Future<void> fetchAvinyaTypeList() async {
    List<AvinyaType> avinyaTypeList = await fetchAvinyaTypes();
    if (mounted) {
      setState(() {
        avinyaTypes = avinyaTypeList;
      });
    }
  }

  // int? getDistrictIdByCityId(int? selectedCityId, List<District> districtList) {
  //   for (var district in districtList) {
  //     if (district.cities != null) {
  //       // Check if cities is not null
  //       for (var city in district.cities!) {
  //         // Use the non-null assertion operator
  //         if (city.id == selectedCityId) {
  //           return district.id; // Return the district ID if the city ID matches
  //         }
  //       }
  //     }
  //   }
  //   return null; // Return null if no matching district is found
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: userPerson.preferred_name == null
          ? const Center(
              child: SpinKitCircle(
                color: (Color.fromARGB(255, 74, 161, 70)),
                size: 70,
              ),
            )
          : Center(
              child: SizedBox(
                width: 850,
                child: Stepper(
                  connectorColor: MaterialStateProperty.all(
                      Color.fromARGB(255, 74, 161, 70)),
                  type: StepperType.vertical,
                  currentStep: _currentStep,
                  onStepContinue: _nextStep,
                  onStepCancel: _previousStep,
                  steps: [
                    Step(
                      title: Text('Student Information'),
                      content: SingleChildScrollView(
                        padding: const EdgeInsets.all(16.0),
                        child: Center(
                          child: SizedBox(
                            width: 800,
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildProfileHeader(context),
                                  const SizedBox(height: 20),
                                  _buildSectionTitle(
                                      context, 'Student Information'),
                                  _buildEditableField('Preferred Name',
                                      userPerson.preferred_name, (value) {
                                    userPerson.preferred_name = value;
                                  },
                                      validator: (value) => value!.isEmpty
                                          ? 'Preferred name is required'
                                          : null),
                                  _buildEditableField(
                                      'Full Name', userPerson.full_name,
                                      (value) {
                                    userPerson.full_name = value;
                                  },
                                      validator: (value) => value!.isEmpty
                                          ? 'Full name is required'
                                          : null),
                                  _buildEditableField(
                                      'NIC Number', userPerson.nic_no, (value) {
                                    userPerson.nic_no = value;
                                  }, validator: _validateNIC),
                                  _buildDateOfBirthField(context),
                                  _buildSexField(),
                                  const SizedBox(height: 10),
                                  FutureBuilder<List<MainOrganization>>(
                                      future: fetchOrganizationList(),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return Container(
                                            margin: EdgeInsets.only(top: 10),
                                            child: SpinKitCircle(
                                              color: (Color.fromARGB(
                                                  255, 74, 161, 70)),
                                              size: 70,
                                            ),
                                          );
                                        } else if (snapshot.hasError) {
                                          return const Center(
                                            child:
                                                Text('Something went wrong...'),
                                          );
                                        } else if (!snapshot.hasData) {
                                          return const Center(
                                            child:
                                                Text('No organizations found'),
                                          );
                                        } else if (snapshot.connectionState ==
                                                ConnectionState.done &&
                                            snapshot.hasData &&
                                            snapshot.data!.isNotEmpty) {
                                          WidgetsBinding.instance
                                              .addPostFrameCallback((_) {
                                            if (!isOrganizationsDataLoaded) {
                                              setState(() {
                                                isOrganizationsDataLoaded =
                                                    true;
                                                print(
                                                    "isorgdataload:${isOrganizationsDataLoaded}");
                                              });
                                            }
                                          });
                                          organizations = snapshot.data!;
                                          return _buildOrganizationField();
                                        } else {
                                          return SizedBox();
                                        }
                                      }),
                                  // _buildOrganizationField(),
                                  _buildStudentClassField(), // Student Class based on organization.description
                                  const SizedBox(height: 20),
                                  _buildSectionTitle(
                                      context, 'Contact Information'),
                                  _buildEditableField(
                                      'Personal Email', userPerson.email,
                                      (value) {
                                    userPerson.email = value;
                                  }),
                                  _buildEditableField('Phone',
                                      userPerson.phone?.toString() ?? '',
                                      (value) {
                                    userPerson.phone = int.tryParse(value);
                                  }, validator: _validatePhone),
                                  _buildEditableField(
                                      'Street Address',
                                      userPerson.mailing_address
                                              ?.street_address ??
                                          'N/A', (value) {
                                    if (userPerson.mailing_address == null) {
                                      userPerson.mailing_address =
                                          Address(street_address: value);
                                    } else {
                                      userPerson.mailing_address!
                                          .street_address = value;
                                    }
                                  }),
                                  FutureBuilder<List<District>>(
                                      future: fetchDistrictList(),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return Container(
                                            margin: EdgeInsets.only(top: 10),
                                            child: SpinKitCircle(
                                              color: (Color.fromARGB(
                                                  255, 74, 161, 70)),
                                              size: 70,
                                            ),
                                          );
                                        } else if (snapshot.hasError) {
                                          return const Center(
                                            child:
                                                Text('Something went wrong...'),
                                          );
                                        } else if (!snapshot.hasData) {
                                          return const Center(
                                            child: Text('No districts found'),
                                          );
                                        } else if (snapshot.connectionState ==
                                                ConnectionState.done &&
                                            snapshot.hasData) {
                                          WidgetsBinding.instance
                                              .addPostFrameCallback((_) {
                                            if (!isDistrictsDataLoaded) {
                                              setState(() {
                                                isDistrictsDataLoaded = true;
                                                print(
                                                    "isDistrictsDataLoaded:${isDistrictsDataLoaded}");
                                              });
                                            }
                                          });
                                          districts = snapshot.data!;
                                          return Column(
                                            children: [
                                              _buildDistrictField(),
                                              _buildCityField(),
                                            ],
                                          );
                                        }

                                        return SizedBox();
                                      }),
                                  const SizedBox(height: 20),
                                  _buildSectionTitle(
                                      context, 'Digital Information'),
                                  _buildEditableField(
                                      'Digital ID', userPerson.digital_id,
                                      (value) {
                                    userPerson.digital_id = value;
                                  }),
                                  _buildAvinyaTypeField(),
                                  const SizedBox(height: 20),
                                  _buildSectionTitle(
                                      context, 'Bank Information'),
                                  _buildEditableField(
                                      'Bank Name', userPerson.bank_name,
                                      (value) {
                                    userPerson.bank_name = value;
                                  }),
                                  _buildEditableField(
                                      'Bank Branch', userPerson.bank_branch,
                                      (value) {
                                    userPerson.bank_branch = value;
                                  }),
                                  _buildEditableField('Bank Account Name',
                                      userPerson.bank_account_name, (value) {
                                    userPerson.bank_account_name = value;
                                  }),
                                  _buildEditableField('Account Number',
                                      userPerson.bank_account_number, (value) {
                                    userPerson.bank_account_number = value;
                                  }),
                                  const SizedBox(height: 20),
                                  _buildSectionTitle(
                                      context, 'Professional Information'),
                                  _buildEditableField(
                                      'Current Job', userPerson.current_job,
                                      (value) {
                                    userPerson.current_job = value;
                                  }),
                                  _buildEditableTextArea(
                                      'Comments', userPerson.notes, (value) {
                                    userPerson.notes = value;
                                  }),
                                  const SizedBox(height: 40),
                                  // _buildSaveButton(isDistrictsDataLoaded,
                                  //     isOrganizationsDataLoaded),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      isActive: _currentStep >= 0,
                    ),
                    Step(
                      title: Text('Upload Files'),
                      content: FutureBuilder<List<UserDocument>?>(
                          future: fetchDocuments(userPerson.documents_id ?? 0),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Container(
                                margin: EdgeInsets.only(top: 10),
                                child: SpinKitCircle(
                                  color: (Color.fromARGB(255, 74, 161, 70)),
                                  size: 70,
                                ),
                              );
                            } else if (snapshot.hasError) {
                              return const Center(
                                child: Text('Something went wrong...'),
                              );
                            } else if (!snapshot.hasData ||
                                snapshot.data == null) {
                              return const Center(
                                child: Text('No user documents found'),
                              );
                            } else if (snapshot.connectionState ==
                                    ConnectionState.done &&
                                snapshot.hasData) {
                              userDocuments = snapshot.data!;
                              return SingleChildScrollView(
                                padding: const EdgeInsets.all(16.0),
                                child: Center(
                                  child: SizedBox(
                                    width: 800,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // _buildSectionTitle(context, 'File Upload'),
                                        // GridView inside SingleChildScrollView
                                        GridView.builder(
                                          shrinkWrap:
                                              true, // Avoid infinite size issue
                                          physics:
                                              NeverScrollableScrollPhysics(),
                                          gridDelegate:
                                              SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount:
                                                2, // 2 items per row
                                            crossAxisSpacing: 16.0,
                                            mainAxisSpacing: 16.0,
                                            childAspectRatio:
                                                1.5, // Adjust the aspect ratio to take up more space
                                          ),
                                          itemCount: 11,
                                          itemBuilder: (context, index) {
                                            List<String> documentTypesLabels = [
                                              'NIC Front',
                                              'NIC Back',
                                              'Birth Certificate Front',
                                              'Birth Certificate Back',
                                              'O/L Certificate',
                                              'A/L  Certificate',
                                              'Additional Certificate 01',
                                              'Additional Certificate 02',
                                              'Additional Certificate 03',
                                              'Additional Certificate 04',
                                              'Additional Certificate 05'
                                            ];

                                            List<String> documentTypes = [
                                              'nicFront',
                                              'nicBack',
                                              'birthCertificateFront',
                                              'birthCertificateBack',
                                              'olDocument',
                                              'alDocument',
                                              'additionalCertificate01',
                                              'additionalCertificate02',
                                              'additionalCertificate03',
                                              'additionalCertificate04',
                                              'additionalCertificate05'
                                            ];
                                            final filteredDocument =
                                                userDocuments.firstWhere(
                                                    (document) =>
                                                        document
                                                            .document_type ==
                                                        documentTypes[index],
                                                    orElse: () => UserDocument(
                                                        document: null,
                                                        document_type: null));
                                            return FileUploadWidget(
                                              userDocumentId:
                                                  userPerson.documents_id ?? 0,
                                              documentTypeLabel:
                                                  documentTypesLabels[index],
                                              documentType:
                                                  documentTypes[index],
                                              stringImage:
                                                  filteredDocument.document,
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }

                            return SizedBox();
                          }),
                      isActive: _currentStep >= 1,
                    )
                  ],
                ),
              ),
            ),
    );
  }

  // Navigate to the next step
  void _nextStep() async {
    bool isEnabled = isDistrictsDataLoaded && isOrganizationsDataLoaded;
    print('is enabled:${isEnabled}');
    if (_currentStep == 0 && isEnabled) {
      if (_formKey.currentState!.validate()) {
        _formKey.currentState!.save();
        userPerson = await updatePerson(userPerson);
        if (userPerson.id != null) {
          setState(() {
            _currentStep += 1;
          });
        }
      }
      // } else if (_currentStep < 1 && isEnabled) {
    } else if (_currentStep == 1) {
      Navigator.pop(context);
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep -= 1;
      });
    }
  }

  Widget _buildProfileHeader(BuildContext context) {
    String imagePath = selectedSex == 'Male'
        ? 'assets/images/student_profile_male.jpg' // Replace with the male profile image path
        : 'assets/images/student_profile.jpeg'; // Default or female profile image

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 40,
          backgroundImage: AssetImage(imagePath),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              userPerson.full_name ?? 'N/A',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(width: 16),
            Text(
              userPerson.organization?.parent_organizations != null &&
                      userPerson.organization!.parent_organizations!.isNotEmpty
                  ? userPerson.organization?.parent_organizations!.first.name
                          ?.name_en ??
                      'N/A'
                  : 'N/A',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(width: 56),
            Text(
              userPerson.organization?.avinya_type != null
                  ? userPerson.organization?.avinya_type!.name ?? 'N/A'
                  : 'N/A',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ],
    );
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

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    final phoneRegex = RegExp(r'^[0-9]+$');
    if (!phoneRegex.hasMatch(value) || value.length < 9) {
      return 'Enter a valid phone number (at least 9 digits)';
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

  Future<void> _loadCities(int? districtId, int? cityid) async {
    final fetchedCities = await fetchCities(districtId);
    setState(() {
      cityList = fetchedCities;
      selectedCityId = cityid;
    });
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
              onChanged: (value) async {
                await _loadCities(value, null);
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
    if (organizations.isEmpty) {
      return const Center(
        child: Text('No organizations available to display'),
      );
    }

    // final parentOrganizationId =
    //     (userPerson.organization != null) ? userPerson.organization!.id : 0;

    final parentOrganizationId =
        (userPerson.organization?.parent_organizations != null &&
                userPerson.organization!.parent_organizations!.isNotEmpty)
            ? userPerson.organization!.parent_organizations!.first.id
            : 0;
    // Ensure parentOrganizationId is in the organizations list or set it to null
    final validParentOrganizationId = organizations.any((org) =>
            org.id == parentOrganizationId &&
            (org.avinya_type?.id == 105 || org.avinya_type?.id == 86))
        ? parentOrganizationId
        : null;
    
    userPerson.parent_organization_id = validParentOrganizationId;

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
              value: validParentOrganizationId ?? userPerson.organization_id,
              items: organizations
                  .where((org) =>
                      org.avinya_type?.id == 105 ||
                      org.avinya_type?.id == 86) // Filter organizations
                  .map((org) {
                return DropdownMenuItem<int>(
                  value: org.id,
                  child: Text(org.name?.name_en ?? 'Unknown'),
                );
              }).toList(),
              onChanged: (int? newValue) async {
                classes = await fetchClasses(newValue);
                setState(() {
                  classes = classes;
                  // userPerson.organization_id =
                  //     newValue; // Update the organization ID
                  userPerson.parent_organization_id = newValue;

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
    // final int? avinyaTypeId = (userPerson.date_of_birth != null &&
    //         calculateAge(userPerson.date_of_birth) != null &&
    //         calculateAge(userPerson.date_of_birth)! < 19)
    //     ? 103 // Auto-select Future Enrollees if under 18
    //     : (userPerson.avinya_type_id ??
    //         userPerson.avinya_type
    //             ?.id); // Fallback to avinya_type?.id if avinya_type_id is null

    final int? avinyaTypeId =
        (userPerson.avinya_type_id ?? userPerson.avinya_type?.id);

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

  Widget _buildSaveButton(
      bool isDistrictsDataLoaded, bool isOrganizationsDataLoaded) {
    bool isEnabled = isDistrictsDataLoaded && isOrganizationsDataLoaded;
    print('is enabled:${isEnabled}');
    return Center(
      child: ElevatedButton(
        onPressed: isEnabled
            ? () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  // Save userPerson changes
                  updatePerson(userPerson);
                }
              }
            : null,
        child: const Text('Save Changes'),
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
                    ? (userPerson.organization != null)
                        ? userPerson.organization!.id
                        : 0
                    : selectedClassId, // Validate selectedClassId
                items: _getClassOptions(),
                onChanged: (value) {
                  setState(() {
                    selectedClassId = value;
                    userPerson.organization_id = value;
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
