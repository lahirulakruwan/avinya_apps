// import 'package:attendance/responsive.dart';
import 'package:flutter/material.dart';
import 'package:attendance/data/activity_attendance.dart';
import 'package:gallery/avinya/attendance/lib/screens/dashboard/components/my_fields.dart';
import 'package:gallery/avinya/attendance/lib/screens/responsive.dart';
import './constants.dart';
import 'package:gallery/avinya/attendance/lib/screens/dashboard/components/recent_files.dart';
import 'package:gallery/avinya/attendance/lib/screens/dashboard/components/weekly_attendance_graph.dart';
import 'package:gallery/avinya/attendance/lib/data/dashboard_data.dart';
import 'components/storage_details.dart';
import 'package:gallery/data/person.dart';
import 'package:gallery/data/campus_apps_portal.dart';
import 'package:intl/intl.dart';
import 'package:flutter_date_range_picker/flutter_date_range_picker.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class AttendanceDashboardScreen extends StatefulWidget {
  const AttendanceDashboardScreen({Key? key}) : super(key: key);

  @override
  _AttendanceDashboardScreenState createState() =>
      _AttendanceDashboardScreenState();
}

class _AttendanceDashboardScreenState extends State<AttendanceDashboardScreen> {
  List<DashboardData> _fetchedDashboardData = [];
  List<ActivityAttendance> _fetchedAttendanceData = [];
  List<ActivityAttendance> _fetchedPieChartData = [];
  List<ActivityAttendance> _fetchedLineChartData = [];
  Organization? _fetchedOrganization;
  int totalStudentCount = 0;
  int totalAttendance = 0;
  var _selectedValue;
  bool _isFetching = true;
  //calendar specific variables
  DateTime? _selectedDay;
  late DateTime today;

  String formattedStartDate = "";
  String formattedEndDate = "";
  String batchStartDate = "";
  String batchEndDate = "";
  String startDate = "";
  String endDate = "";
  List cardData = [];
  late Future<List<Organization>> _fetchBatchData;
  Organization? _selectedOrganizationValue;
  List<Organization> _batchData = [];
  List<Organization> _fetchedOrganizations = [];

  @override
  void initState() {
    super.initState();
    today = DateTime.now();
    formattedStartDate = DateFormat('MMM d, yyyy').format(today);
    formattedEndDate = DateFormat('MMM d, yyyy').format(today);
    // batchStartDate = DateFormat('MMM d, yyyy').format(today);
    // batchEndDate = DateFormat('MMM d, yyyy').format(today);
    ;
    String formattedToday = DateFormat('yyyy-MM-dd').format(today);
    _fetchBatchData = _loadBatchData();
    // refreshState(null, formattedToday, formattedToday, 'batch');
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<List<Organization>> _loadBatchData() async {
    _batchData = await fetchOrganizationsByAvinyaType(86);
    _selectedOrganizationValue = _batchData.isNotEmpty ? _batchData.last : null;
    batchStartDate = DateFormat('MMM d, yyyy').format(DateTime.parse(
        _selectedOrganizationValue!.organization_metadata[0].value.toString()));
    batchEndDate = DateFormat('MMM d, yyyy').format(DateTime.parse(
        _selectedOrganizationValue!.organization_metadata[1].value.toString()));
    if (_selectedOrganizationValue != null) {
      int orgId = _selectedOrganizationValue!.id!;
      _fetchedOrganization = await fetchOrganization(orgId);
      _fetchedOrganizations = _fetchedOrganization?.child_organizations ?? [];
      setState(() {
        _fetchedOrganizations = _fetchedOrganizations;
      });
    }
    this.updateDateRange(today, today);
    return _batchData;
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
          this.startDate = DateFormat('yyyy-MM-dd').format(startDate);
          this.endDate = DateFormat('yyyy-MM-dd').format(endDate);
          refreshState(
              this._selectedValue, this.startDate, this.endDate, 'date');
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

  int calculateTotalStudentCount(List<ActivityAttendance> fetchedPieChartData) {
    int totalStudentCount = 0;

    for (var activityAttendance in fetchedPieChartData) {
      totalStudentCount += activityAttendance.total_student_count ?? 0;
    }

    return totalStudentCount;
  }

  int calculateTotalAttendance(List<ActivityAttendance> fetchedPieChartData) {
    int totalAttendance = 0;

    for (var activityAttendance in fetchedPieChartData) {
      totalAttendance += activityAttendance.present_count ?? 0;
    }

    return totalAttendance;
  }

  void refreshState(Organization? newValue, String startDate, String endDate,
      String from) async {
    setState(() {
      _isFetching = true; // Set _isFetching to true before starting the fetch
    });
    int? parentOrgId =
        campusAppsPortalInstance.getUserPerson().organization!.id;
    _selectedValue = newValue ?? null;
    _fetchedPieChartData =
        await getDailyStudentsAttendanceByParentOrg(parentOrgId);
    totalStudentCount = await calculateTotalStudentCount(_fetchedPieChartData);
    totalAttendance = await calculateTotalAttendance(_fetchedPieChartData);

    if (_selectedValue == null) {
      _fetchedDashboardData = await getDashboardCardDataByParentOrg(
          startDate, endDate, parentOrgId);
      _fetchedAttendanceData = await getAttendanceMissedBySecurityByParentOrg(
          parentOrgId, startDate, endDate);
      if (startDate == endDate) {
        DateTime startDateDateTime = DateTime.parse(startDate);
        DateTime thirtyDaysAgo = startDateDateTime.subtract(Duration(days: 30));
        _fetchedLineChartData = await getTotalAttendanceCountByParentOrg(
            parentOrgId,
            DateFormat('yyyy-MM-dd').format(thirtyDaysAgo),
            endDate);
      } else {
        _fetchedLineChartData = await getTotalAttendanceCountByParentOrg(
            parentOrgId, startDate, endDate);
      }

      if (_fetchedOrganization != null) {
        _fetchedOrganization!.id = parentOrgId;
        _fetchedOrganization!.description = "Select All";
      } else {
        _fetchedOrganization = Organization();
        _fetchedOrganization!.id = parentOrgId;
        _fetchedOrganization!.description = "Select All";
      }
    } else {
      _fetchedDashboardData =
          await getDashboardCardDataByDate(startDate, endDate, newValue?.id!);
      _fetchedAttendanceData = await getAttendanceMissedBySecurityByOrg(
          newValue!.id!, startDate, endDate);
      _fetchedLineChartData = await getTotalAttendanceCountByDateByOrg(
          newValue.id!, startDate, endDate);
    }

    String? newSelectedVal;
    if (_selectedValue != null) {
      newSelectedVal = _selectedValue.description;
    }

    setState(() {
      _fetchedOrganization;
      _fetchedOrganizations;
      this._isFetching = false;
      this.cardData = _fetchedDashboardData;
      this._fetchedAttendanceData = _fetchedAttendanceData;
      this._fetchedPieChartData = _fetchedPieChartData;
      this.totalStudentCount = totalStudentCount;
      this._fetchedLineChartData = _fetchedLineChartData;
    });
  }

  Widget datePickerBuilder(
          BuildContext context, dynamic Function(DateRange?) onDateRangeChanged,
          [bool doubleMonth = false]) =>
      DateRangePickerWidget(
        minDate: DateFormat('MMM d, yyyy').parse(batchStartDate),
        maxDate: DateFormat('MMM d, yyyy').parse(batchEndDate),
        doubleMonth: doubleMonth,
        maximumDateRangeLength: 200,
        theme: CalendarTheme(
          selectedColor: Colors.blue,
          dayNameTextStyle: TextStyle(color: Colors.black45, fontSize: 10),
          inRangeColor: Color(0xFFD9EDFA),
          inRangeTextStyle: TextStyle(color: Colors.blue),
          selectedTextStyle: TextStyle(color: Colors.white),
          todayTextStyle: TextStyle(fontWeight: FontWeight.bold),
          monthTextStyle: TextStyle(color: Colors.black, fontSize: 12),
          defaultTextStyle: TextStyle(color: Colors.black, fontSize: 12),
          radius: 10,
          tileSize: 40,
          disabledTextStyle: TextStyle(color: Colors.grey),
        ),
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
          // QuickDateRange(
          //   label: 'Last 90 days',
          //   dateRange: DateRange(
          //     DateTime.now().subtract(const Duration(days: 90)),
          //     DateTime.now(),
          //   ),
          // ),
          // QuickDateRange(
          //   label: 'Last 180 days',
          //   dateRange: DateRange(
          //     DateTime.now().subtract(const Duration(days: 180)),
          //     DateTime.now(),
          //   ),
          // ),
        ],
        minimumDateRangeLength: 3,
        // initialDateRange: this.selectedDateRange ??
        //     DateRange(
        //         DateTime.now(), DateTime.now().add(const Duration(days: 7))),
        // disabledDates: [DateTime(2023, 11, 20)],
        // initialDisplayedDate: this.selectedDateRange?.start ?? today,
        initialDisplayedDate: this.selectedDateRange?.start ??
            DateFormat('MMM d, yyyy').parse(batchStartDate),
        onDateRangeChanged: (DateRange? value) {
          if (value != null) {
            var _rangeStart = value.start;
            var _rangeEnd = value.end;
            this.updateDateRange(_rangeStart, _rangeEnd);
          } else {
            onDateRangeChanged(DateRange(today, today));
            this.updateDateRange(today, today);
          }
        },
      );
  Widget datePickerBuilderMobile(
          BuildContext context, dynamic Function(DateRange?) onDateRangeChanged,
          [bool doubleMonth = false]) =>
      DateRangePickerWidget(
        minDate: DateFormat('MMM d, yyyy').parse(batchStartDate),
        maxDate: DateFormat('MMM d, yyyy').parse(batchEndDate),
        doubleMonth: doubleMonth,
        maximumDateRangeLength: 10,
        theme: CalendarTheme(
          selectedColor: Colors.blue,
          dayNameTextStyle: TextStyle(color: Colors.black45, fontSize: 10),
          inRangeColor: Color(0xFFD9EDFA),
          inRangeTextStyle: TextStyle(color: Colors.blue),
          selectedTextStyle: TextStyle(color: Colors.white),
          todayTextStyle: TextStyle(fontWeight: FontWeight.bold),
          monthTextStyle: TextStyle(color: Colors.black, fontSize: 12),
          defaultTextStyle: TextStyle(color: Colors.black, fontSize: 12),
          radius: 10,
          tileSize: 40,
          disabledTextStyle: TextStyle(color: Colors.grey),
        ),
        minimumDateRangeLength: 3,
        // initialDateRange: this.selectedDateRange ??
        //     DateRange(
        //         DateTime.now(), DateTime.now().add(const Duration(days: 7))),
        // disabledDates: [DateTime(2023, 11, 20)],
        // initialDisplayedDate: this.selectedDateRange?.start ?? today,
        initialDisplayedDate: this.selectedDateRange?.start ??
            DateFormat('MMM d, yyyy').parse(batchStartDate),
        onDateRangeChanged: (DateRange? value) {
          if (value != null) {
            var _rangeStart = value.start;
            var _rangeEnd = value.end;
            this.updateDateRange(_rangeStart, _rangeEnd);
          } else {
            onDateRangeChanged(DateRange(today, today));
            this.updateDateRange(today, today);
          }
        },
      );

  @override
  Widget build(BuildContext context) {
    final Size _size = MediaQuery.of(context).size;
    bool isMobile = MediaQuery.of(context).size.width < 600;
    return SafeArea(
      child: SingleChildScrollView(
        primary: false,
        padding: EdgeInsets.all(defaultPadding),
        child: Column(
          children: [
            // New Row Above
            Row(
              children: [
                Text(
                  "Attendance Dashboard",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Color.fromARGB(255, 38, 38, 38),
                  ),
                )
              ],
            ),
            SizedBox(width: defaultPadding),
            if (!isMobile)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () => showDateRangePickerDialog(
                        context: context,
                        builder: datePickerBuilder,
                        offset: Offset(20, 155)),
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
                  SizedBox(
                    width: 30,
                  ),
                  Text('Select a Batch :'),
                  SizedBox(
                    width: 10,
                  ),
                  FutureBuilder<List<Organization>>(
                    future: _fetchBatchData,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Container(
                          margin: EdgeInsets.only(top: 10),
                          child: SpinKitCircle(
                            color: (Colors.deepPurpleAccent),
                            size: 70,
                          ),
                        );
                      } else if (snapshot.hasError) {
                        return const Center(
                          child: Text('Something went wrong...'),
                        );
                      } else if (!snapshot.hasData) {
                        return const Center(
                          child: Text('No batch found'),
                        );
                      }
                      final batchData = snapshot.data!;
                      return DropdownButton<Organization>(
                          value: _selectedOrganizationValue,
                          items: batchData.map((Organization batch) {
                            return DropdownMenuItem(
                                value: batch,
                                child: Text(batch.name!.name_en ?? ''));
                          }).toList(),
                          onChanged: (Organization? newValue) async {
                            if (newValue == null) {
                              return;
                            }

                            if (newValue.organization_metadata.isEmpty) {
                              return;
                            }

                            _fetchedOrganization =
                                await fetchOrganization(newValue!.id!);
                            _fetchedOrganizations =
                                _fetchedOrganization?.child_organizations ?? [];

                            setState(() {
                              _fetchedOrganizations;
                              _selectedValue = null;
                              _selectedOrganizationValue = newValue;
                              batchStartDate = DateFormat('MMM d, yyyy').format(
                                  DateTime.parse(_selectedOrganizationValue!
                                      .organization_metadata[0].value
                                      .toString()));

                              batchEndDate = DateFormat('MMM d, yyyy').format(
                                  DateTime.parse(_selectedOrganizationValue!
                                      .organization_metadata[1].value
                                      .toString()));

                              this.updateDateRange(
                                  DateTime.parse(_selectedOrganizationValue!
                                      .organization_metadata[0].value
                                      .toString()),
                                  DateTime.parse(_selectedOrganizationValue!
                                      .organization_metadata[1].value
                                      .toString()));
                            });
                          });
                    },
                  ),
                  Expanded(
                      child: Container(
                    margin: EdgeInsets.only(left: 8.0),
                    child: Row(children: <Widget>[
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            // if (org.child_organizations_for_dashboard.length > 0)
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
                                    if (_selectedValue == null) {
                                      setState(() {
                                        if (_fetchedOrganization != null) {
                                          _fetchedOrganization!.id =
                                              parentOrgId;
                                          _fetchedOrganization!.description =
                                              "Select All";
                                        } else {
                                          _fetchedOrganization = Organization();
                                          _fetchedOrganization!.id =
                                              parentOrgId;
                                          _fetchedOrganization!.description =
                                              "Select All";
                                        }
                                        _fetchedDashboardData;
                                      });
                                    } else {
                                      setState(() {
                                        _selectedValue;
                                        _fetchedOrganization;
                                        _fetchedDashboardData;
                                      });
                                    }
                                    if (this.startDate == "" &&
                                        this.endDate == "") {
                                      today = DateTime.now();
                                      String formattedToday =
                                          DateFormat('MMM d, yyyy')
                                              .format(today);
                                      refreshState(
                                          this._selectedValue,
                                          formattedToday,
                                          formattedToday,
                                          'class');
                                    } else {
                                      refreshState(
                                          this._selectedValue,
                                          this.startDate,
                                          this.endDate,
                                          'class');
                                    }
                                  },
                                  items: [
                                    // Add "Select All" option
                                    DropdownMenuItem<Organization>(
                                      value: null,
                                      child: Text("Select All"),
                                    ),
                                    // Add other organization options
                                    for (var org in _fetchedOrganizations)
                                      DropdownMenuItem<Organization>(
                                        value: org,
                                        child: Text(org.description!),
                                      )
                                  ],
                                ),
                              ]),
                            ),
                          ]),
                    ]),
                  )),
                ],
              ),
            if (isMobile)
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text('Select a Batch :'),
                      SizedBox(
                        width: 5,
                      ),
                      SizedBox(
                        width: 240,
                        child: FutureBuilder<List<Organization>>(
                          future: _fetchBatchData,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Container(
                                margin: EdgeInsets.only(top: 10),
                                child: SpinKitCircle(
                                  color: (Colors.deepPurpleAccent),
                                  size: 70,
                                ),
                              );
                            } else if (snapshot.hasError) {
                              return const Center(
                                child: Text('Something went wrong...'),
                              );
                            } else if (!snapshot.hasData) {
                              return const Center(
                                child: Text('No batch found'),
                              );
                            }
                            final batchData = snapshot.data!;
                            return DropdownButton<Organization>(
                                value: _selectedOrganizationValue,
                                items: batchData.map((Organization batch) {
                                  return DropdownMenuItem(
                                      value: batch,
                                      child: Text(batch.name!.name_en ?? ''));
                                }).toList(),
                                onChanged: (Organization? newValue) async {
                                  if (newValue == null) {
                                    return;
                                  }

                                  if (newValue.organization_metadata.isEmpty) {
                                    return;
                                  }

                                  _fetchedOrganization =
                                      await fetchOrganization(newValue!.id!);
                                  _fetchedOrganizations = _fetchedOrganization
                                          ?.child_organizations ??
                                      [];

                                  setState(() {
                                    _fetchedOrganizations;
                                    _selectedValue = null;
                                    _selectedOrganizationValue = newValue;
                                    batchStartDate = DateFormat('MMM d, yyyy')
                                        .format(DateTime.parse(
                                            _selectedOrganizationValue!
                                                .organization_metadata[0].value
                                                .toString()));

                                    batchEndDate = DateFormat('MMM d, yyyy')
                                        .format(DateTime.parse(
                                            _selectedOrganizationValue!
                                                .organization_metadata[1].value
                                                .toString()));

                                    this.updateDateRange(
                                        DateTime.parse(
                                            _selectedOrganizationValue!
                                                .organization_metadata[0].value
                                                .toString()),
                                        DateTime.parse(
                                            _selectedOrganizationValue!
                                                .organization_metadata[1].value
                                                .toString()));
                                  });
                                });
                          },
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text('Select a Class :'),
                      SizedBox(
                        width: 5,
                      ),
                      SizedBox(
                        width: 240,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              // if (org.child_organizations_for_dashboard.length > 0)
                              Container(
                                margin: EdgeInsets.only(
                                    left: 20, top: 20, bottom: 10),
                                child: Row(children: <Widget>[
                                  DropdownButton<Organization>(
                                    value: _selectedValue,
                                    onChanged: (Organization? newValue) async {
                                      _selectedValue = newValue ?? null;
                                      int? parentOrgId =
                                          campusAppsPortalInstance
                                              .getUserPerson()
                                              .organization!
                                              .id;
                                      if (_selectedValue == null) {
                                        setState(() {
                                          if (_fetchedOrganization != null) {
                                            _fetchedOrganization!.id =
                                                parentOrgId;
                                            _fetchedOrganization!.description =
                                                "Select All";
                                          } else {
                                            _fetchedOrganization =
                                                Organization();
                                            _fetchedOrganization!.id =
                                                parentOrgId;
                                            _fetchedOrganization!.description =
                                                "Select All";
                                          }
                                          _fetchedDashboardData;
                                        });
                                      } else {
                                        setState(() {
                                          _selectedValue;
                                          _fetchedOrganization;
                                          _fetchedDashboardData;
                                        });
                                      }
                                      if (this.startDate == "" &&
                                          this.endDate == "") {
                                        today = DateTime.now();
                                        String formattedToday =
                                            DateFormat('MMM d, yyyy')
                                                .format(today);
                                        refreshState(
                                            this._selectedValue,
                                            formattedToday,
                                            formattedToday,
                                            'class');
                                      } else {
                                        refreshState(
                                            this._selectedValue,
                                            this.startDate,
                                            this.endDate,
                                            'class');
                                      }
                                    },
                                    items: [
                                      // Add "Select All" option
                                      DropdownMenuItem<Organization>(
                                        value: null,
                                        child: Text("Select All"),
                                      ),
                                      // Add other organization options
                                      for (var org in _fetchedOrganizations)
                                        DropdownMenuItem<Organization>(
                                          value: org,
                                          child: Text(org.description!),
                                        )
                                    ],
                                  ),
                                ]),
                              ),
                            ]),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () => showDateRangePickerDialog(
                            context: context,
                            builder: datePickerBuilderMobile,
                            offset: Offset(5, 220)),
                        style: ButtonStyle(
                          padding:
                              MaterialStateProperty.all(EdgeInsets.all(16.0)),
                          textStyle: MaterialStateProperty.all(
                            const TextStyle(fontSize: 16),
                          ),
                          elevation: MaterialStateProperty.all(20),
                          backgroundColor:
                              MaterialStateProperty.all(Colors.greenAccent),
                          foregroundColor:
                              MaterialStateProperty.all(Colors.black),
                        ),
                        child: Text(this.formattedStartDate +
                            " - " +
                            this.formattedEndDate),
                      ),
                    ],
                  )
                ],
              ),

            // Existing Column
            Column(
              children: [
                SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          Responsive(
                            mobile: FileInfoCardGridView(
                              cardData: this.cardData,
                              crossAxisCount: _size.width < 650 ? 2 : 4,
                              childAspectRatio:
                                  _size.width < 650 && _size.width > 350
                                      ? 1.3
                                      : 1,
                            ),
                            tablet: FileInfoCardGridView(
                              cardData: this.cardData,
                              crossAxisCount: _size.width < 800 ? 4 : 2,
                            ),
                            desktop: FileInfoCardGridView(
                                childAspectRatio:
                                    _size.width < 1400 ? 1.1 : 1.4,
                                crossAxisCount: _size.width < 1400 ? 2 : 2,
                                cardData: this.cardData),
                          ),
                          SizedBox(height: defaultPadding),
                          if (Responsive.isMobile(context))
                            SizedBox(height: defaultPadding),
                          if (Responsive.isMobile(context))
                            LineChartWidget(_fetchedLineChartData),
                          SizedBox(height: defaultPadding),
                          if (Responsive.isMobile(context))
                            SizedBox(height: defaultPadding),
                          if (Responsive.isMobile(context))
                            if (this.totalStudentCount > 0)
                              StorageDetails(
                                  fetchedPieChartData:
                                      this._fetchedPieChartData,
                                  totalStudentCount: this.totalStudentCount,
                                  totalAttendance: this.totalAttendance),
                        ],
                      ),
                    ),
                    if (!Responsive.isMobile(context))
                      SizedBox(width: defaultPadding),
                    if (!Responsive.isMobile(context))
                      Expanded(
                        flex: 3,
                        child: Column(
                          children: [
                            Text("Daily Attendance Trends",
                                style:
                                    Theme.of(context).textTheme.headlineMedium),
                            LineChartWidget(_fetchedLineChartData),
                            Text(
                              "Date Range: " +
                                  this.formattedStartDate +
                                  " - " +
                                  this.formattedEndDate,
                              style: TextStyle(
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: defaultPadding),
                            AttendanceMissedBySecurity(
                                fetchedAttendanceData: _fetchedAttendanceData),
                          ],
                        ),
                      ),
                    if (!Responsive.isMobile(context))
                      SizedBox(width: defaultPadding),
                    if (!Responsive.isMobile(context))
                      if (this.totalStudentCount > 0)
                        Expanded(
                          flex: 2,
                          child: StorageDetails(
                              fetchedPieChartData: this._fetchedPieChartData,
                              totalStudentCount: this.totalStudentCount,
                              totalAttendance: this.totalAttendance),
                        ),
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
