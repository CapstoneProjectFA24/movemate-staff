import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:auto_route/auto_route.dart';
import 'package:movemate_staff/utils/constants/asset_constant.dart';

@RoutePage()
class DriverScreen extends StatelessWidget {
  const DriverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: const Icon(FontAwesomeIcons.arrowLeft),
        title: const Text(
          'Assign Drivers',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w500,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionTitle(title: 'Nearest Driver'),
              const DriverCard(
                name: 'Ramesh Kumar',
                distance: '200 Meters',
                imageUrl:
                    'https://storage.googleapis.com/a1aa/image/zxTYIYgOksK6FJYgbe8e0cJvjG9azcGQzrVnCkTuoGwAAkpTA.jpg',
                rating: '4.5',
              ),
              const SizedBox(height: 20),
              const SectionTitle(title: 'My Drivers'),
              SearchBar(),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                children: List.generate(
                  5,
                  (index) => DriverCard(
                    name: 'Driver $index',
                    distance: '${150 + index * 10} Meters',
                    imageUrl:
                        'https://storage.googleapis.com/a1aa/image/zxTYIYgOksK6FJYgbe8e0cJvjG9azcGQzrVnCkTuoGwAAkpTA.jpg',
                    rating: '4.${index + 1}',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class DriverCard extends StatelessWidget {
  final String name;
  final String distance;
  final String imageUrl;
  final String rating;

  const DriverCard({super.key, 
    required this.name,
    required this.distance,
    required this.imageUrl,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          builder: (BuildContext context) {
            return Container(
              decoration: const BoxDecoration(
                  color: AssetsConstants.whiteColor,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20))),
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: NetworkImage(imageUrl),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            distance,
                            style: const TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              const Icon(
                                FontAwesomeIcons.star,
                                color: Color(0xFFFFCC00),
                                size: 14,
                              ),
                              const SizedBox(width: 5),
                              Text(rating,
                                  style: const TextStyle(fontSize: 14)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6600),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    onPressed: () {
                      // Thực hiện hành động gọi
                    },
                    child:
                        const Text('Call Now', style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            );
          },
        );
      },
      child: Container(
        width: 160,
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.orange[100],
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFF0F0F0)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 25,
              backgroundImage: NetworkImage(imageUrl),
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(FontAwesomeIcons.mapMarkerAlt,
                    color: Color(0xFFFF6600), size: 14),
                const SizedBox(width: 5),
                Text(
                  distance,
                  style:
                      const TextStyle(color: Color(0xFFFF6600), fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(FontAwesomeIcons.star,
                    color: Color(0xFFFFCC00), size: 14),
                const SizedBox(width: 5),
                Text(rating, style: const TextStyle(fontSize: 14)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SearchBar extends StatelessWidget {
  const SearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search Drivers',
              contentPadding: const EdgeInsets.symmetric(horizontal: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: const BorderSide(color: Colors.grey),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(FontAwesomeIcons.filter, size: 16),
          label: const Text('Filters'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF6600),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          ),
        ),
      ],
    );
  }
}
