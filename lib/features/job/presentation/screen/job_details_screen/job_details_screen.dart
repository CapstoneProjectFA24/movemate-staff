import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:movemate_staff/configs/routes/app_router.dart';
import 'package:movemate_staff/features/job/presentation/widgets/details/address.dart';
import 'package:movemate_staff/features/job/presentation/widgets/details/booking_code.dart';
import 'package:movemate_staff/features/job/presentation/widgets/details/column.dart';
import 'package:movemate_staff/features/job/presentation/widgets/details/image.dart';
import 'package:movemate_staff/features/job/presentation/widgets/details/infoItem.dart';
import 'package:movemate_staff/features/job/presentation/widgets/details/item.dart';
import 'package:movemate_staff/features/job/presentation/widgets/details/policies.dart';
import 'package:movemate_staff/features/job/presentation/widgets/details/priceItem.dart';
import 'package:movemate_staff/features/job/presentation/widgets/details/section.dart';
import 'package:movemate_staff/features/job/presentation/widgets/details/summary.dart';
import 'package:movemate_staff/utils/commons/widgets/app_bar.dart';
import 'package:movemate_staff/utils/constants/asset_constant.dart';
import 'package:timeline_tile/timeline_tile.dart';

// Nhập khẩu các widget đã tạo

@RoutePage()
class JobDetailsScreen extends HookConsumerWidget {
  const JobDetailsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isExpanded =
        useState(false); // Manage the dropdown state using useState
    final isExpanded1 =
        useState(false); // Manage the dropdown state using useState

    void toggleDropdown() {
      isExpanded.value = !isExpanded.value; // Toggle the dropdown state
    }

    void toggleDropdown1() {
      isExpanded1.value = !isExpanded1.value; // Toggle the dropdown state
    }

    return Scaffold(
      appBar: CustomAppBar(
        backgroundColor: AssetsConstants.primaryMain,
        backButtonColor: AssetsConstants.whiteColor,
        showBackButton: true,
        title: "Thông tin đơn hàng",
        iconSecond: Icons.home_outlined,
        onCallBackSecond: () {
          final tabsRouter = context.router.root
              .innerRouterOf<TabsRouter>(TabViewScreenRoute.name);
          if (tabsRouter != null) {
            tabsRouter.setActiveIndex(0);
            context.router.popUntilRouteWithName(TabViewScreenRoute.name);
          }
        },
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 2.0, top: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 14.0),
                child: Text(
                  "đang chờ reviewer xét duyệt",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(height: 10),

              // const SizedBox(height: 50),
              //   const Padding(
              //     padding: EdgeInsets.only(left: 2.0),
              //     child: Row(
              //       mainAxisAlignment: MainAxisAlignment.spaceAround,
              //       children: [
              //         Text('Đặt hàng', style: TextStyle(fontSize: 14)),
              //         Text('Gói hàng', style: TextStyle(fontSize: 14)),
              //         Text('Giao hàng', style: TextStyle(fontSize: 14)),
              //         Text('Thành công', style: TextStyle(fontSize: 14)),
              //       ],
              //     ),
              //   ),
              const SizedBox(height: 50),
              Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                child: Center(
                  child: Container(
                    width: 350,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: 2,
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          decoration: const BoxDecoration(
                            color: Color(0xFF007bff),
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(10)),
                          ),
                          padding: const EdgeInsets.all(15),
                          child: const Row(
                            children: [
                              Icon(FontAwesomeIcons.home, color: Colors.white),
                              SizedBox(width: 10),
                              Text('Thông tin dịch vụ',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 18)),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Loại nhà : Công ty',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 10),
                              buildAddressRow(
                                Icons.location_on_outlined,
                                '172 Phạm Ngũ Lão, Hùng Vương, Bình Tân, Hồ Chí Minh',
                              ),
                              const Divider(
                                  height: 12, color: Colors.grey, thickness: 1),
                              buildAddressRow(
                                Icons.location_searching,
                                '194 Cao Lãnh, Hùng Vương, Tân phú Hồ Chí Minh',
                              ),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  buildDetailColumn(
                                      FontAwesomeIcons.building, '2 tầng'),
                                  buildDetailColumn(
                                      FontAwesomeIcons.building, '2 phòng'),
                                ],
                              ),
                              const SizedBox(height: 20),
                              buildPolicies(FontAwesomeIcons.checkCircle,
                                  'Miễn phí đặt lại'),
                              const SizedBox(height: 20),
                              buildPolicies(FontAwesomeIcons.checkCircle,
                                  'Áp dụng chính sách đổi lịch'),
                              const SizedBox(height: 20),
                              buildBookingCode('Mã đặt chỗ', 'FD8UH6'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.only(left: 16.0),
                child: Text("Thông tin khách hàng",
                    style:
                        TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              ),
              // const Padding(
              //   padding: EdgeInsets.only(left: 16.0, top: 20),
              //   child: Text("Label",
              //       style:
              //           TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              // ),
              const Padding(
                padding: EdgeInsets.only(left: 16.0),
                child: Text("NGUYEN VAN A",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFDDDDDD)),
                  borderRadius: BorderRadius.circular(5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 2,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Thông tin liên hệ',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            isExpanded.value
                                ? Icons.arrow_drop_up
                                : Icons.arrow_drop_down,
                            color: Colors.black54,
                          ),
                          onPressed: toggleDropdown,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (isExpanded.value) ...[
                      buildInfoItem('Họ và tên', 'NGUYEN VAN ANH'),
                      buildInfoItem('Số điện thoại', '0900123456'),
                      buildInfoItem('Email', 'nguyenvananh@gmail.com'),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Thông tin hình ảnh',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            isExpanded.value
                                ? Icons.arrow_drop_up
                                : Icons.arrow_drop_down,
                            color: Colors.black54,
                          ),
                          onPressed: toggleDropdown1, // Toggle dropdown
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (isExpanded1.value) ...[
                      const Section(
                        title: 'Phòng khách',
                        imageUrls: [
                          'https://storage.googleapis.com/a1aa/image/dvpjaAZVn8JdNhNPtaaFDhQIeMwhXQ0HMUcf0hHMhoKYKAmTA.jpg',
                          'https://storage.googleapis.com/a1aa/image/mHPD0OkSSGZZLRmqv6dH8NaZ24RSHqpVKZVHHNZLFZjnCg5E.jpg',
                          'https://storage.googleapis.com/a1aa/image/K1C1Fefpj2lXgEmrDGfRdpJooZY7I5nU3WxfE85UFQ9PqAYOB.jpg',
                        ],
                      ),
                      const Section(
                        title: 'Phòng ngủ',
                        imageUrls: [
                          'https://storage.googleapis.com/a1aa/image/fBpjleWEpgugmEBvFjXwk2H98ZgSIbDKaheiOgg4UZhBVAMnA.jpg',
                          'https://storage.googleapis.com/a1aa/image/ogWeseWHSnvUPkDESsXp5aABBSSiMKHwevQDKSZN6PVDVAMnA.jpg',
                          'https://storage.googleapis.com/a1aa/image/BJdB94Gzprb0BZraxwED8F5DWPeH8T92UNmlBZ8SX05OFAzJA.jpg',
                        ],
                      ),
                      const Section(
                        title: 'Phòng ăn/ bếp',
                        imageUrls: [
                          'https://storage.googleapis.com/a1aa/image/LGjfvIaJ6xw0WygoEs8q6YmuI77RohPhefDyz6ndgf9RqAYOB.jpg',
                          'https://storage.googleapis.com/a1aa/image/trWo0O6H9fRAZymxTUOhutvO4tFUvv1Zq0MRvBUr2IeVKAmTA.jpg',
                          'https://storage.googleapis.com/a1aa/image/QfROlDzTbKTpYyEpiJ7fHWaUehLPdXFJyDTgwUSNFIZ2UAMnA.jpg',
                        ],
                      ),
                      const Section(
                        title: 'Phòng làm việc',
                        imageUrls: [
                          'https://storage.googleapis.com/a1aa/image/RLtRhYWNmeQMaKflapHPLpszw0sfvHv6tTHZeRpd2o2iqAYOB.jpg',
                          'https://storage.googleapis.com/a1aa/image/s6lUv1OMNWoZDtfhkuB9bbpsrUIethkiJ9dIkOOjPTFaKAmTA.jpg',
                          'https://storage.googleapis.com/a1aa/image/89UXhJbyaioJKZBnZkLB1E8K6ZNuVW2NPfbwUH4DRlLTFAzJA.jpg',
                        ],
                      ),
                      const Section(
                        title: 'Phòng vệ sinh',
                        imageUrls: [
                          'https://storage.googleapis.com/a1aa/image/qeNJZtlx9G3YKK4Rqhw7OKUFFWCtl0pqhDF69Dx39zuLFAzJA.jpg',
                          'https://storage.googleapis.com/a1aa/image/gpJf0Pchpp31UaaqoU2r5Euz8ezHi7xyO6LRv3eCdalKVAMnA.jpg',
                          'https://storage.googleapis.com/a1aa/image/XxGrBWX8LgYjCpnBVcf8TyBu8f4QRSThluqdztAGuxtpKAmTA.jpg',
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 20),
              Container(
                // margin: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 0),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'chi tiết giá',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    buildItem(
                      imageUrl:
                          'https://storage.googleapis.com/a1aa/image/9rjSBLSWxmoedSK8EHEZx3zrEUxndkuAofGOwCAMywzUTWlTA.jpg',
                      title: 'Xe Tải 1250 kg',
                      description:
                          'Giờ Cấm Tải 6H-9H & 16H-20H | Chở tới đa 1250kg & 7CBM\n3.1 x 1.6 x 1.6 Mét - Lên đến 1250 kg',
                    ),
                    buildPriceItem('Phí giao hàng', '282.900 đ'),
                    buildPriceItem(
                        'Dịch Vụ Bốc Xếp Bốc Xếp Tận Nơi (Bởi tài xế)',
                        '140.000 đ'),
                    buildPriceItem(
                        'Dịch Vụ Bốc Xếp. Bốc Xếp Tận Nơi (Có người hỗ trợ)',
                        '282.900 đ'),
                    buildPriceItem(
                        'Dịch Vụ Bốc Xếp - Bốc Xếp Dưới Xe (Có người hỗ trợ)',
                        '240.000 đ'),
                    buildPriceItem('Phí cầu đường', '40.000 đ'),
                    buildPriceItem('Giao hàng siêu tốc', '22.900 đ'),
                    buildPriceItem('Giao hàng 2 chiều', '20.000 đ'),
                    buildSummary('Giảm giá', '-00.000 đ'),
                    buildSummary('Thuế GTGT', '-00.000 đ'),
                    const Divider(color: Colors.grey, thickness: 1),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Text(
                            'Giảm giá',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Text(
                            '8.000.000 đ',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'Ghi chú',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        // Add your onPressed logic here
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF9900),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        fixedSize: const Size(
                            400, 50), // Chiều rộng tự động và chiều cao là 50
                      ),
                      child: const Text(
                        'Xác nhận',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
