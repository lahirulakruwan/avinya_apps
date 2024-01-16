import 'package:gallery/avinya/attendance/lib/data/dashboard_data.dart';
import 'package:gallery/avinya/attendance/lib/screens/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_date_range_picker/flutter_date_range_picker.dart';

import '../constants.dart';
import 'file_info_card.dart';
import 'package:gallery/data/person.dart';
import 'package:gallery/data/campus_apps_portal.dart';
import 'package:intl/intl.dart';

class MyFiles extends StatefulWidget {
  const MyFiles({
    Key? key,
  }) : super(key: key);

  @override
  _MyFilesState createState() => _MyFilesState();
}

class _MyFilesState extends State<MyFiles> {
  List<DashboardData> _fetchedDashboardData = [];
  Organization? _fetchedOrganization;
  // late Future<List<DashboardData>> cardData;
  var _selectedValue;
  bool _isFetching = true;
  //calendar specific variables
  DateTime? _selectedDay;
  late DateTime today;

  String formattedStartDate = "";
  String formattedEndDate = "";
  String startDate = "";
  String endDate = "";
  List cardData = [];

  @override
  void initState() {
    super.initState();
    today = DateTime.now();
    formattedStartDate = DateFormat('MMM d, yyyy').format(today);
    formattedEndDate = DateFormat('MMM d, yyyy').format(today);
    String formattedToday = DateFormat('yyyy-MM-dd').format(today);
    // Organization? parentOrgId =
    //     campusAppsPortalInstance.getUserPerson().organization!;
    // cardData = getDashboardCardDataByParentOrg(
    //     formattedToday, formattedToday, parentOrgId);
    refreshState(null, formattedToday, formattedToday);
  }

  @override
  void dispose() {
    super.dispose();
  }

  // @override
  // void didUpdateWidget(covariant MyFiles oldWidget) {
  //   super.didUpdateWidget(oldWidget);

  //   // Check if the initialTime property has changed
  //   // if (_fetchedDashboardData != oldWidget._fetchedDashboardData) {
  //   //   setState(() {
  //   //     fetchedDashboardData = widget.fetchedDashboardData;
  //   //   });
  //   // }
  // }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() {
      // _fetchedOrganization;
      // this._isFetching = false;
      // this._fetchedDashboardData = _fetchedDashboardData;
      // this.cardData = _fetchedDashboardData;
      // _data = MyData(_fetchedAttendance, newSelectedVal, updateSelected);
    });
  }

  DateRange? selectedDateRange;
  void updateDateRange(_rangeStart, _rangeEnd) async {
    int? parentOrgId =
        campusAppsPortalInstance.getUserPerson().organization!.id;
    if (parentOrgId != null) {
      setState(() {
        _isFetching = true; // Set _isFetching to true before starting the fetch
      });
      try {
        setState(() {
          final startDate = _rangeStart ?? _selectedDay;
          final endDate = _rangeEnd ?? _selectedDay;
          final formatter = DateFormat('MMM d, yyyy');
          final formattedStartDate = formatter.format(startDate!);
          final formattedEndDate = formatter.format(endDate!);
          this.formattedStartDate = formattedStartDate;
          this.formattedEndDate = formattedEndDate;
          // this.cardData = cardData;
          this.startDate = DateFormat('yyyy-MM-dd').format(startDate);
          this.endDate = DateFormat('yyyy-MM-dd').format(endDate);
          refreshState(this._selectedValue, this.startDate, this.endDate);
        });
      } catch (error) {
        // Handle any errors that occur during the fetch
        setState(() {
          _isFetching = false; // Set _isFetching to false in case of error
        });
        // Perform error handling, e.g., show an error message
      }
    }
  }

  void refreshState(
      Organization? newValue, String startDate, String endDate) async {
    setState(() {
      _isFetching = true; // Set _isFetching to true before starting the fetch
    });
    int? parentOrgId =
        campusAppsPortalInstance.getUserPerson().organization!.id;
    _selectedValue = newValue ?? null;

    if (_selectedValue == null) {
      _fetchedDashboardData = await getDashboardCardDataByParentOrg(
          startDate, endDate, parentOrgId);
      if (_fetchedOrganization != null) {
        // _fetchedOrganization!.people = _fetchedDashboardData;
        _fetchedOrganization!.id = parentOrgId;
        _fetchedOrganization!.description = "Select All";
      } else {
        _fetchedOrganization = Organization();
        // _fetchedOrganization!.people = _fetchedDashboardData;
        _fetchedOrganization!.id = parentOrgId;
        _fetchedOrganization!.description = "Select All";
      }
    } else {
      _fetchedOrganization = await fetchOrganization(newValue!.id!);
      _fetchedDashboardData =
          await getDashboardCardDataByDate(startDate, endDate, newValue.id!);
    }

    String? newSelectedVal;
    if (_selectedValue != null) {
      newSelectedVal = _selectedValue.description;
    }

    setState(() {
      _fetchedOrganization;
      this._isFetching = false;
      // this._fetchedDashboardData = _fetchedDashboardData;
      this.cardData = _fetchedDashboardData;
      // _data = MyData(_fetchedAttendance, newSelectedVal, updateSelected);
    });
  }

  Widget datePickerBuilder(
          BuildContext context, dynamic Function(DateRange?) onDateRangeChanged,
          [bool doubleMonth = true]) =>
      DateRangePickerWidget(
        doubleMonth: doubleMonth,
        maximumDateRangeLength: 10,
        quickDateRanges: [
          QuickDateRange(dateRange: null, label: "Remove date range"),
          QuickDateRange(
            label: 'Last 3 days',
            dateRange: DateRange(
              DateTime.now().subtract(const Duration(days: 3)),
              DateTime.now(),
            ),
          ),
          QuickDateRange(
            label: 'Last 7 days',
            dateRange: DateRange(
              DateTime.now().subtract(const Duration(days: 7)),
              DateTime.now(),
            ),
          ),
          QuickDateRange(
            label: 'Last 30 days',
            dateRange: DateRange(
              DateTime.now().subtract(const Duration(days: 30)),
              DateTime.now(),
            ),
          ),
          QuickDateRange(
            label: 'Last 90 days',
            dateRange: DateRange(
              DateTime.now().subtract(const Duration(days: 90)),
              DateTime.now(),
            ),
          ),
          QuickDateRange(
            label: 'Last 180 days',
            dateRange: DateRange(
              DateTime.now().subtract(const Duration(days: 180)),
              DateTime.now(),
            ),
          ),
        ],
        minimumDateRangeLength: 3,
        initialDateRange: selectedDateRange,
        disabledDates: [DateTime(2023, 11, 20)],
        initialDisplayedDate:
            selectedDateRange?.start ?? DateTime(2023, 11, 20),
        onDateRangeChanged: (DateRange? value) {
          print(value);
          var _rangeStart = value!.start;
          var _rangeEnd = value.end;
          updateDateRange(_rangeStart, _rangeEnd);
          // Handle the selected date range here
        },
      );

  @override
  Widget build(BuildContext context) {
    final Size _size = MediaQuery.of(context).size;
    bool isMobile = MediaQuery.of(context).size.width < 600;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Attendance Dashboard",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Color.fromARGB(255, 38, 38, 38),
          ),
        ),
        SizedBox(height: 10),
        if (!isMobile)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                  child: Container(
                margin: EdgeInsets.only(left: 8.0),
                child: Row(children: <Widget>[
                  for (var org in campusAppsPortalInstance
                      .getUserPerson()
                      .organization!
                      .child_organizations)
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          if (org.child_organizations.length > 0)
                            Container(
                              margin: EdgeInsets.only(
                                  left: 20, top: 20, bottom: 10),
                              child: Row(children: <Widget>[
                                Text('Select a class:'),
                                SizedBox(width: 10),
                                DropdownButton<Organization>(
                                  value: _selectedValue,
                                  onChanged: (Organization? newValue) async {
                                    _selectedValue = newValue ?? null;
                                    int? parentOrgId = campusAppsPortalInstance
                                        .getUserPerson()
                                        .organization!
                                        .id;
                                    // if (_selectedValue == null) {
                                    //   // _fetchedOrganization = null;
                                    //   _fetchedDashboardData =
                                    //       await fetchOrganizationForAll(
                                    //           parentOrgId!);
                                    // } else {
                                    //   // _fetchedDashboardData = <Person>[];
                                    //   _fetchedOrganization =
                                    //       await fetchOrganization(
                                    //           newValue!.id!);
                                    // }
                                    if (_selectedValue == null) {
                                      setState(() {
                                        if (_fetchedOrganization != null) {
                                          // _fetchedOrganization!.people =
                                          //     _fetchedDashboardData;
                                          _fetchedOrganization!.id =
                                              parentOrgId;
                                          _fetchedOrganization!.description =
                                              "Select All";
                                        } else {
                                          _fetchedOrganization = Organization();
                                          // _fetchedOrganization!.people =
                                          //     _fetchedDashboardData;
                                          _fetchedOrganization!.id =
                                              parentOrgId;
                                          _fetchedOrganization!.description =
                                              "Select All";
                                        }
                                        _fetchedDashboardData;
                                      });
                                    } else {
                                      setState(() {
                                        _fetchedOrganization;
                                        _fetchedDashboardData;
                                      });
                                    }
                                    if (this.startDate == "" &&
                                        this.endDate == "") {
                                      today = DateTime.now();
                                      String formattedToday =
                                          DateFormat('yyyy-MM-dd')
                                              .format(today);
                                      refreshState(this._selectedValue,
                                          formattedToday, formattedToday);
                                    } else {
                                      refreshState(this._selectedValue,
                                          this.startDate, this.endDate);
                                    }
                                  },
                                  items: [
                                    // Add "Select All" option
                                    DropdownMenuItem<Organization>(
                                      value: null,
                                      child: Text("Select All"),
                                    ),
                                    // Add other organization options
                                    ...org.child_organizations
                                        .map((Organization value) {
                                      return DropdownMenuItem<Organization>(
                                        value: value,
                                        child: Text(value.description!),
                                      );
                                    }),
                                  ],
                                ),
                              ]),
                            ),
                        ]),
                ]),
              )),
              ElevatedButton(
                onPressed: () => showDateRangePickerDialog(
                    context: context,
                    builder: datePickerBuilder,
                    offset: Offset(310, 180)),
                style: ButtonStyle(
                  padding: MaterialStateProperty.all(EdgeInsets.all(16.0)),
                  textStyle: MaterialStateProperty.all(
                    const TextStyle(fontSize: 16),
                  ),
                  elevation: MaterialStateProperty.all(20),
                  backgroundColor:
                      MaterialStateProperty.all(Colors.greenAccent),
                  foregroundColor: MaterialStateProperty.all(Colors.black),
                ),
                child: Text(formattedStartDate + " - " + formattedEndDate),
              ),
            ],
          ),
        if (isMobile)
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Expanded(
                      child: Container(
                    margin: EdgeInsets.only(left: 8.0),
                    child: Row(children: <Widget>[
                      for (var org in campusAppsPortalInstance
                          .getUserPerson()
                          .organization!
                          .child_organizations)
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              if (org.child_organizations.length > 0)
                                Container(
                                  margin: EdgeInsets.only(
                                      left: 20, top: 20, bottom: 10),
                                  child: Row(children: <Widget>[
                                    Text('Select a class:'),
                                    SizedBox(width: 10),
                                    DropdownButton<Organization>(
                                      value: _selectedValue,
                                      onChanged:
                                          (Organization? newValue) async {
                                        _selectedValue = newValue ?? null;
                                        int? parentOrgId =
                                            campusAppsPortalInstance
                                                .getUserPerson()
                                                .organization!
                                                .id;
                                        if (_selectedValue == null) {
                                          // _fetchedOrganization = null;
                                          if (this.startDate == "" &&
                                              this.endDate == "") {
                                            today = DateTime.now();
                                            String formattedToday =
                                                DateFormat('yyyy-MM-dd')
                                                    .format(today);
                                            _fetchedDashboardData =
                                                await getDashboardCardDataByParentOrg(
                                                    formattedToday,
                                                    formattedToday,
                                                    parentOrgId!);
                                          } else {
                                            _fetchedDashboardData =
                                                await getDashboardCardDataByParentOrg(
                                                    this.startDate,
                                                    this.endDate,
                                                    parentOrgId!);
                                          }
                                        } else {
                                          // _fetchedDashboardData = <Person>[];
                                          _fetchedOrganization =
                                              await fetchOrganization(
                                                  newValue!.id!);
                                          if (this.startDate == "" &&
                                              this.endDate == "") {
                                            today = DateTime.now();
                                            String formattedToday =
                                                DateFormat('yyyy-MM-dd')
                                                    .format(today);
                                            _fetchedDashboardData =
                                                await getDashboardCardDataByDate(
                                                    formattedToday,
                                                    formattedToday,
                                                    newValue.id!);
                                          } else {
                                            _fetchedDashboardData =
                                                await getDashboardCardDataByDate(
                                                    this.startDate,
                                                    this.endDate,
                                                    newValue.id!);
                                          }
                                        }
                                        if (_selectedValue == null) {
                                          setState(() {
                                            if (_fetchedOrganization != null) {
                                              // _fetchedOrganization!.people =
                                              //     _fetchedDashboardData;
                                              _fetchedOrganization!.id =
                                                  parentOrgId;
                                              _fetchedOrganization!
                                                  .description = "Select All";
                                            } else {
                                              _fetchedOrganization =
                                                  Organization();
                                              // _fetchedOrganization!.people =
                                              //     _fetchedDashboardData;
                                              _fetchedOrganization!.id =
                                                  parentOrgId;
                                              _fetchedOrganization!
                                                  .description = "Select All";
                                            }
                                            _fetchedDashboardData;
                                            // cardData = _fetchedDashboardData;
                                          });
                                        } else {
                                          setState(() {
                                            _fetchedOrganization;
                                            _fetchedDashboardData;
                                            // cardData = _fetchedDashboardData;
                                          });
                                        }
                                      },
                                      items: [
                                        // Add "Select All" option
                                        DropdownMenuItem<Organization>(
                                          value: null,
                                          child: Text("Select All"),
                                        ),
                                        // Add other organization options
                                        ...org.child_organizations
                                            .map((Organization value) {
                                          return DropdownMenuItem<Organization>(
                                            value: value,
                                            child: Text(value.description!),
                                          );
                                        }),
                                      ],
                                    ),
                                  ]),
                                ),
                            ]),
                    ]),
                  )),
                ],
              ),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () => showDateRangePickerDialog(
                        context: context,
                        builder: datePickerBuilder,
                        offset: Offset(310, 180)),
                    style: ButtonStyle(
                      padding: MaterialStateProperty.all(EdgeInsets.all(16.0)),
                      textStyle: MaterialStateProperty.all(
                        const TextStyle(fontSize: 16),
                      ),
                      elevation: MaterialStateProperty.all(20),
                      backgroundColor:
                          MaterialStateProperty.all(Colors.greenAccent),
                      foregroundColor: MaterialStateProperty.all(Colors.black),
                    ),
                    child: Text(formattedStartDate + " - " + formattedEndDate),
                  ),
                ],
              ),
            ],
          ),
        SizedBox(height: defaultPadding),
        Responsive(
          mobile: FileInfoCardGridView(
            cardData: this.cardData,
            crossAxisCount: _size.width < 650 ? 2 : 4,
            childAspectRatio: _size.width < 650 && _size.width > 350 ? 1.3 : 1,
          ),
          tablet: FileInfoCardGridView(cardData: this.cardData),
          desktop: FileInfoCardGridView(
              childAspectRatio: _size.width < 1400 ? 1.1 : 1.4,
              cardData: this.cardData),
        ),
      ],
    );
  }
}

class FileInfoCardGridView extends StatefulWidget {
  const FileInfoCardGridView({
    Key? key,
    required this.cardData,
    this.crossAxisCount = 4,
    this.childAspectRatio = 1,
  }) : super(key: key);

  final List cardData;
  final int crossAxisCount;
  final double childAspectRatio;

  @override
  _FileInfoCardGridViewState createState() => _FileInfoCardGridViewState();
}

class _FileInfoCardGridViewState extends State<FileInfoCardGridView> {
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: widget.cardData.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: widget.crossAxisCount,
        crossAxisSpacing: defaultPadding,
        mainAxisSpacing: defaultPadding,
        childAspectRatio: widget.childAspectRatio,
      ),
      itemBuilder: (context, index) =>
          FileInfoCard(info: widget.cardData[index]),
    );
  }
}
