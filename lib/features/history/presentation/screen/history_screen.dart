import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:movemate_staff/features/history/presentation/widget/history_item.dart';
import 'package:movemate_staff/utils/commons/widgets/app_bar.dart';
import 'package:movemate_staff/utils/constants/asset_constant.dart';

@RoutePage()
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final List<Map<String, String>> orders = [
    {
      "title": "Đơn 1",
      "imageUrl":
          "https://storage.googleapis.com/a1aa/image/ovfmrVAgf8qt70fGhwwbfwZSqWtejzRHHyb2FK8kcQlgBgTdC.jpg",
      "location": "Modern-day",
      "museums": "5 Museums",
      "archives": "2 Archives",
      "tourDuration": "1-week tour",
    },
    {
      "title": "Đơn 2",
      "imageUrl": "https://storage.googleapis.com/a1aa/image/eiffel.jpg",
      "location": "Paris, France",
      "museums": "7 Museums",
      "archives": "3 Archives",
      "tourDuration": "2-week tour",
    },
    {
      "title": "Đơn 3",
      "imageUrl": "https://storage.googleapis.com/a1aa/image/pyramids.jpg",
      "location": "Cairo, Egypt",
      "museums": "10 Museums",
      "archives": "5 Archives",
      "tourDuration": "3-week tour",
    },
  ];

  List<Map<String, String>> filteredOrders = [];
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredOrders = orders;
  }

  void _filterOrders(String query) {
    setState(() {
      filteredOrders = orders
          .where((order) =>
              order["title"]!.toLowerCase().contains(query.toLowerCase()) ||
              order["location"]!.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: const CustomAppBar(
          backgroundColor: AssetsConstants.mainColor,
          title: "History",
          centerTitle: true,
          backButtonColor: AssetsConstants.whiteColor,
          showBackButton: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Stack(
                alignment: Alignment.centerLeft,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: TextField(
                      controller: searchController,
                      onChanged: _filterOrders,
                      decoration: InputDecoration(
                        hintText: "Tìm kiếm đơn hàng...",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 40,
                        ),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 18.0),
                    child: Icon(Icons.search, color: Colors.grey, size: 24),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: filteredOrders.length,
                  itemBuilder: (context, index) {
                    final order = filteredOrders[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: HistoryItem(
                        title: order["title"]!,
                        imageUrl: order["imageUrl"]!,
                        location: order["location"]!,
                        museums: order["museums"]!,
                        archives: order["archives"]!,
                        tourDuration: order["tourDuration"]!,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
