import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:movemate_staff/configs/routes/app_router.dart';
import 'package:movemate_staff/features/job/domain/entities/location_model_entities.dart';
import 'package:movemate_staff/features/job/presentation/providers/booking_provider.dart';
import 'package:movemate_staff/features/porter/presentation/widgets/map_widget/button_custom.dart';

import 'package:movemate_staff/utils/constants/api_constant.dart';
import 'package:movemate_staff/utils/constants/asset_constant.dart';

final pickupAutocompleteResultsProvider =
    StateProvider<List<dynamic>>((ref) => []);
final dropoffAutocompleteResultsProvider =
    StateProvider<List<dynamic>>((ref) => []);

final pickupSelectedLocationProvider =
    StateProvider<Map<String, dynamic>?>((ref) => null);
final dropoffSelectedLocationProvider =
    StateProvider<Map<String, dynamic>?>((ref) => null);

final uiUpdateTriggerProvider = StateProvider<bool>((ref) => false);
final selectedRefIdProvider = StateProvider<String?>((ref) => null);

class LocationBottomSheet extends HookConsumerWidget {
  const LocationBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DraggableScrollableSheet(
      initialChildSize: 0.98,
      minChildSize: 0.9,
      maxChildSize: 0.98,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 8, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Chọn địa chỉ',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  IconButton(
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => context.router.pop(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: DefaultTabController(
                length: 2,
                child: Column(
                  children: [
                    // CHANGE 4: Enhanced TabBar styling
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      // Added bottom border for tab bar
                      decoration: BoxDecoration(
                        border: Border(
                          bottom:
                              BorderSide(color: Colors.grey[200]!, width: 1),
                        ),
                      ),
                      child: TabBar(
                        // CHANGE 5: Improved tab styling
                        labelColor: Colors.black,
                        unselectedLabelColor: Colors.grey,
                        labelStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        indicatorSize: TabBarIndicatorSize.tab,
                        indicatorWeight: 2,
                        tabs: const [
                          Tab(text: 'Điểm đi'),
                          Tab(text: 'Điểm đến'),
                        ],
                        onTap: (index) {
                          if (index == 0) {
                            ref
                                .read(
                                    pickupAutocompleteResultsProvider.notifier)
                                .state = [];
                          } else {
                            ref
                                .read(
                                    dropoffAutocompleteResultsProvider.notifier)
                                .state = [];
                          }
                        },
                      ),
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          LocationTab(context, ref, true),
                          LocationTab(context, ref, false),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget LocationTab(BuildContext context, WidgetRef ref, bool isPickUp) {
    // Theo dõi thay đổi UI
    final _ = ref.watch(uiUpdateTriggerProvider);

    // Truy cập booking notifier và state
    final bookingNotifier = ref.read(bookingProvider.notifier);
    final bookingState = ref.watch(bookingProvider);

    // Lấy kết quả tự động hoàn thành và vị trí đã chọn dựa trên isPickUp
    final autocompleteResults = ref.watch(isPickUp
        ? pickupAutocompleteResultsProvider
        : dropoffAutocompleteResultsProvider);
    final selectedLocation = ref.watch(isPickUp
        ? pickupSelectedLocationProvider
        : dropoffSelectedLocationProvider);

    // Theo dõi `ref_id` được chọn
    final selectedRefId = ref.watch(selectedRefIdProvider);

    const apiKey = APIConstants.apiVietMapKey;

    // Hàm lấy kết quả tự động hoàn thành
    void fetchAutocompleteResults(
        String query, WidgetRef ref, bool isPickUp) async {
      final url = Uri.parse(
          'https://maps.vietmap.vn/api/autocomplete/v3?apikey=$apiKey&text=$query');

      try {
        final response = await http.get(url);
        if (response.statusCode == 200) {
          final results = json.decode(response.body);
          if (isPickUp) {
            ref.read(pickupAutocompleteResultsProvider.notifier).state =
                results;
          } else {
            ref.read(dropoffAutocompleteResultsProvider.notifier).state =
                results;
          }
        }
      } catch (e) {
        print('Error fetching autocomplete results: $e');
      }
    }

    // Hàm lấy chi tiết vị trí
    void fetchLocationDetails(
        String refId, WidgetRef ref, bool isPickUp) async {
      final url = Uri.parse(
          'https://maps.vietmap.vn/api/place/v3?apikey=$apiKey&refid=$refId');

      try {
        final response = await http.get(url);
        if (response.statusCode == 200) {
          final details = json.decode(response.body);
          if (isPickUp) {
            ref.read(pickupSelectedLocationProvider.notifier).state = details;
          } else {
            ref.read(dropoffSelectedLocationProvider.notifier).state = details;
          }
        }
      } catch (e) {
        print('Error fetching location details: $e');
      }
    }

    // Cấu trúc widget với nút xác nhận nằm ngoài Expanded
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        // Phần nội dung có thể cuộn
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Ô tìm kiếm
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search, color: Colors.grey),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText:
                                  isPickUp ? 'Tìm điểm đi' : 'Tìm điểm đến',
                            ),
                            onChanged: (value) {
                              if (value.length > 2) {
                                fetchAutocompleteResults(value, ref, isPickUp);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Kết quả tự động hoàn thành
                  ...autocompleteResults.map((result) {
                    final isSelected = selectedRefId == result['ref_id'];
                    return ListTile(
                      leading: Icon(
                        Icons.location_on,
                        color: isSelected ? Colors.blue : Colors.grey,
                      ),
                      title: Text(
                        result['display'],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.w400,
                          color: Colors.black,
                        ),
                      ),
                      tileColor:
                          isSelected ? Colors.blue.withOpacity(0.1) : null,
                      onTap: () {
                        fetchLocationDetails(result['ref_id'], ref, isPickUp);
                        ref.read(selectedRefIdProvider.notifier).state =
                            result['ref_id'];
                      },
                    );
                  }),
                  const SizedBox(height: 20),

                  // Chi tiết vị trí đã chọn
                  // if (selectedLocation != null) ...[
                  //   Text('Địa điểm đã chọn: ${selectedLocation['display']}'),
                  //   Text('Vĩ độ: ${selectedLocation['lat']}'),
                  //   Text('Kinh độ: ${selectedLocation['lng']}'),
                  // ],

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
        // Nút xác nhận nằm ngoài Expanded, luôn ở cuối modal
        if (selectedLocation != null)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ButtonCustom(
              buttonText: 'Xác nhận',
              buttonColor: AssetsConstants.primaryDark,
              isButtonEnabled: true,
              onButtonPressed: () {
                final location = LocationModel(
                  label: selectedLocation['name'],
                  address: selectedLocation['display'],
                  latitude: selectedLocation['lat'],
                  longitude: selectedLocation['lng'],
                  distance: '',
                );
                if (isPickUp) {
                  bookingNotifier.updatePickUpLocation(location);
                } else {
                  bookingNotifier.updateDropOffLocation(location);
                }
                // final pickUpLocation = bookingState.pickUpLocation;
                // final dropOffLocation = bookingState.dropOffLocation;
                // Kiểm tra xem cả điểm đi và điểm đến đã được chọn chưa
                final pickUpLocation = ref.read(pickupSelectedLocationProvider);
                final dropOffLocation =
                    ref.read(dropoffSelectedLocationProvider);

                if (pickUpLocation != null && dropOffLocation != null) {
                  final tabsRouter = context.router.root
                      .innerRouterOf<TabsRouter>(TabViewScreenRoute.name);
                  if (tabsRouter != null) {
                    tabsRouter.setActiveIndex(0);
                    context.router
                        .popUntilRouteWithName(TabViewScreenRoute.name);
                  }
                } else {
                  final tabController = DefaultTabController.of(context);
                  tabController.animateTo(isPickUp ? 1 : 0);
                }
              },
            ),
          ),
      ],
    );
  }
}
