import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:racksmart/back_end/http_search.dart';
import 'package:racksmart/constants/data_const.dart';
import 'package:racksmart/models/device_customer.dart';
import 'package:racksmart/models/device_history.dart';
import 'package:racksmart/items/customer_item.dart';
import 'package:racksmart/items/history_item.dart';
import 'package:racksmart/models/search_box_data.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/device_item_model.dart';
import '../items/device_item.dart';
import '../qr_view/qr_view_take_tooling.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  HttpSearch? toolingValue;
  String? searchToolingValue;
  TextEditingController searchController = TextEditingController();
  final customersItemList = CustomerDevice.customerDeviceList();
  List<DeviceItemData> _foundDevice = [];
  List<DeviceItemData> _foundDeviceButton = [];
  List<CustomerDevice> _foundCustomer = [];
  List<CustomerDevice> _foundCustomerButton = [];

  SearchFilterState? selectedValue;
  List<SearchFilterState> stateItem = [
    SearchFilterState(id: 1, name: 'Part Number'),
    SearchFilterState(id: 2, name: 'Customer'),
  ];

  @override
  void initState() {
    // _foundDeviceButton = devicesItemList;
    super.initState();
    loadValues();
  }

  loadValues() async {
    //rackdata

    searchToolingValue = await SearchToolingData.getString(searchToolingKey);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    //String dropdownValue = 'Part Number';
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 190, 190, 190),
        appBar: AppBar(
          centerTitle: true,
          title: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/Satnusa.png',
                  scale: 3,
                ),
                const SizedBox(
                  width: 10,
                ),
                const Text(
                  'SMART RACK',
                  style: TextStyle(color: Colors.white),
                )
              ],
            ),
          ),
          backgroundColor: Colors.red,
        ),
        body: Center(
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            padding: const EdgeInsets.only(right: 80, left: 80),
            child: ListView(
              children: [
                const SizedBox(
                  height: 20,
                ),
                const Align(
                  alignment: Alignment.center,
                  child: Text(
                    'Search Tool & Device',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      width: 200,
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.black, width: 1),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(8))),
                      child: DropdownButton<SearchFilterState?>(
                          hint: const Text("Part Number"),
                          value: selectedValue,
                          onChanged: (value) {
                            setState(() {
                              selectedValue = value;
                              print(value?.id);
                            });
                          },
                          underline: const SizedBox(),
                          isExpanded: true,
                          items: stateItem
                              .map<DropdownMenuItem<SearchFilterState>>(
                                  (e) => DropdownMenuItem(
                                        value: e,
                                        child: Text((e.name ?? '').toString()),
                                      ))
                              .toList()),
                    ),
                    SizedBox(
                      width: 550,
                      child: SearchBox(),
                    ),
                    SizedBox(
                      width: 150,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            HttpSearch.connectAPI(searchController.text)
                                .then((value) {
                              toolingValue = value;
                              print(searchController.text);
                              print(toolingValue?.rackcode);
                              print(value.rackcode);
                              setState(() {});
                            });
                            if (selectedValue?.name == null) {
                              _foundDeviceButton = _foundDevice;
                              SearchToolingData.setString(
                                  searchToolingKey, searchController.text);
                              loadValues();
                            } else if (selectedValue?.name == 'Part Number') {
                              _foundDeviceButton = _foundDevice;
                              SearchToolingData.setString(
                                  searchToolingKey, searchController.text);
                              loadValues();
                            } else {
                              _foundCustomerButton = _foundCustomer;
                            }
                          });
                        },
                        style: ElevatedButton.styleFrom(
                            fixedSize: const Size(150, 48),
                            backgroundColor: Colors.red),
                        child: const Text('Search'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text(
                            (selectedValue?.name.toString() == null)
                                ? 'Results: Part Number'
                                : "Results: ${selectedValue?.name.toString()} ",
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w500),
                          ),
                        ),
                        SizedBox(
                          width: 450,
                          child: (selectedValue?.name.toString() == null ||
                                  selectedValue?.name.toString() ==
                                      'Part Number')
                              ? ((toolingValue?.rackcode == 'error' ||
                                      toolingValue == null)
                                  ? Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 40, horizontal: 20),
                                      margin: const EdgeInsets.only(bottom: 40),
                                      decoration: BoxDecoration(
                                          border: Border.all(width: 1),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          color: Color.fromARGB(
                                              255, 240, 239, 239)),
                                      child: Column(
                                        children: [
                                          Container(
                                            margin: const EdgeInsets.only(
                                                bottom: 30, top: 0),
                                            child: Image.asset(
                                              'assets/SearchIcon.png',
                                              scale: 1,
                                            ),
                                          ),
                                          Text(
                                            (toolingValue == null)
                                                ? 'Empty'
                                                : toolingValue!.message!,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ],
                                      ),
                                    )
                                  : Expanded(
                                      flex: 1,
                                      child: Container(
                                        padding: const EdgeInsets.only(
                                          bottom: 10,
                                        ),
                                        margin:
                                            const EdgeInsets.only(bottom: 40),
                                        decoration: BoxDecoration(
                                            border: Border.all(width: 1),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            color: Colors.white),
                                        child: Column(
                                          children: [
                                            ListTile(
                                              //onTap: () {},
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8)),
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 20,
                                                      vertical: 5),
                                              tileColor: Colors.white,
                                              leading: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  Text('Rack Code'),
                                                  Text(
                                                      "${toolingValue?.rackcode}")
                                                ],
                                              ),
                                              trailing: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  Text('Part Number'),
                                                  Text(
                                                      '${toolingValue?.partnumber}')
                                                ],
                                              ),
                                            ),
                                            ElevatedButton(
                                              onPressed: () {
                                                showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return AlertDialog(
                                                      title: Text(
                                                        '${toolingValue?.rackcode} LED is ON',
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                      content: const Text(
                                                        "Please fine your tooling!",
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                            color: Colors.grey,
                                                            fontSize: 12),
                                                      ),
                                                      actions: <Widget>[
                                                        Column(
                                                          children: [
                                                            Container(
                                                              margin:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      bottom:
                                                                          30,
                                                                      top: 0),
                                                              child:
                                                                  Image.asset(
                                                                'assets/DoneIcon.jpg',
                                                                scale: 3,
                                                              ),
                                                            ),
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceEvenly,
                                                              children: [
                                                                ElevatedButton(
                                                                  onPressed:
                                                                      () {
                                                                    Navigator.of(
                                                                            context)
                                                                        .pop();
                                                                    Navigator.push(
                                                                        context,
                                                                        MaterialPageRoute(builder:
                                                                            (context) {
                                                                      return const QRViewTakeTooling();
                                                                    }));
                                                                  },
                                                                  style: ElevatedButton.styleFrom(
                                                                      fixedSize:
                                                                          const Size(
                                                                              100,
                                                                              40),
                                                                      backgroundColor:
                                                                          Colors
                                                                              .red),
                                                                  child:
                                                                      const Text(
                                                                          'Take'),
                                                                ),
                                                                ElevatedButton(
                                                                  onPressed:
                                                                      () {
                                                                    //_showTurnOffLampDialog();
                                                                    print(
                                                                        'The light has been turned off');
                                                                    Navigator.of(
                                                                            context)
                                                                        .pop();
                                                                  },
                                                                  style: ElevatedButton.styleFrom(
                                                                      fixedSize:
                                                                          const Size(100,
                                                                              40),
                                                                      backgroundColor:
                                                                          Colors
                                                                              .white,
                                                                      side: const BorderSide(
                                                                          width:
                                                                              1,
                                                                          color:
                                                                              Colors.red)),
                                                                  child:
                                                                      const Text(
                                                                    'Turn Off',
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .red),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );
                                              },
                                              style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors
                                                      .red, // background (button) color
                                                  foregroundColor: Colors.white,
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 100,
                                                      vertical:
                                                          10) // foreground (text) color
                                                  ),
                                              child: const Text(
                                                'Find Me',
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )

                                      //     ListView(
                                      //   physics: const NeverScrollableScrollPhysics(),
                                      //   shrinkWrap: true,
                                      //   children: (selectedValue?.name.toString() == null ||
                                      //           selectedValue?.name.toString() ==
                                      //               'Part Number')
                                      //       ? searchResultsSection
                                      //       : searchCustomerSection,
                                      // )

                                      ))
                              : Text(''),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: const Text(
                            'History',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w500),
                          ),
                        ),
                        SizedBox(
                          width: 450,
                          child: Expanded(
                              flex: 1,
                              child: ListView(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                children: [
                                ],
                              )),
                        ),
                      ],
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  List<Widget> get searchResultsSection {
    return [DeviceItem()];
  }

  List<Widget> get searchCustomerSection {
    return [
      for (CustomerDevice item in _foundCustomerButton)
        CustomerItem(
          item: item,
        ),
    ];
  }

  Widget SearchBox() {
    return Container(
      //width: 200,
      margin: const EdgeInsets.only(top: 20, bottom: 20),
      padding: const EdgeInsets.symmetric(
        horizontal: 15,
      ),
      decoration: BoxDecoration(
          color: const Color.fromARGB(255, 255, 255, 255),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(width: 1)),
      child: TextField(
        controller: searchController,
        //onChanged: (value) => _runFilterSearchBox(value),
        decoration: const InputDecoration(
            contentPadding: EdgeInsets.all(0),
            prefixIcon: Icon(
              Icons.search,
              color: Colors.black,
              size: 20,
            ),
            prefixIconConstraints: BoxConstraints(maxHeight: 20, minWidth: 25),
            border: InputBorder.none,
            hintText: 'Search',
            hintStyle: TextStyle(color: Colors.grey)),
      ),
    );
  }
}

SearchToolingResult() {
  return Container(
    padding: const EdgeInsets.only(bottom: 10),
    margin: const EdgeInsets.only(bottom: 40),
    decoration: BoxDecoration(
        border: Border.all(width: 1),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white),
    child: Column(
      children: [
        ListTile(
          //onTap: () {},
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          tileColor: Colors.white,
          leading: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [Text('Rack Code'), Text('')],
          ),
          trailing: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [Text('Part Number'), Text('')],
          ),
        ),
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red, // background (button) color
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                  horizontal: 100, vertical: 10) // foreground (text) color
              ),
          child: const Text(
            'Find Me',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    ),
  );
}

_toolingDialogue() {}

class SearchFilterState {
  int? id;
  String? name;

  SearchFilterState({this.id, this.name});
}
