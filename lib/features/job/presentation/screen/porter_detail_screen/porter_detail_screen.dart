// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:vietmap_flutter/vietmap_flutter.dart'; // Replace with actual import for vietmap

// class JobDetailScreen extends StatelessWidget {
//   final BookingJob job;

//   const JobDetailScreen({super.key, required this.job});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           job.title,
//           style: const TextStyle(color: Colors.white),
//         ),
//         backgroundColor: Colors.orange.shade800,
//         iconTheme: const IconThemeData(color: Colors.white),
//       ),
//       body: Column(
//         children: [
//           // VietMap for Pickup and Dropoff Locations
//           Expanded(
//             child: VietmapFlutterMap(
//               initialCameraPosition: CameraPosition(
//                 target: LatLng(10.762622, 106.660172), // Example coordinates
//                 zoom: 12,
//               ),
//               onMapCreated: (VietmapFlutterController controller) {
//                 // You can customize the map here, like adding markers
//                 controller.addMarker(
//                   Marker(
//                     markerId: MarkerId("pickup"),
//                     position: LatLng(10.762622, 106.660172), // Pickup location
//                   ),
//                 );
//                 controller.addMarker(
//                   Marker(
//                     markerId: MarkerId("dropoff"),
//                     position: LatLng(10.780439, 106.665239), // Dropoff location
//                   ),
//                 );
//               },
//             ),
//           ),
//           const Divider(),

//           // Job Details Section
//           Padding(
//             padding: const EdgeInsets.all(15.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       "Job ID: ${job.id}",
//                       style: const TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 16,
//                       ),
//                     ),
//                     Text(
//                       job.status,
//                       style: TextStyle(
//                         color: job.status == 'Đã vận chuyển'
//                             ? Colors.green
//                             : Colors.red,
//                         fontWeight: FontWeight.bold,
//                         fontSize: 14,
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 10),
//                 Text(
//                   "Time: ${DateFormat.Hm().format(job.startTime)} - ${DateFormat.Hm().format(job.endTime)}",
//                   style: const TextStyle(fontSize: 14),
//                 ),
//                 const SizedBox(height: 10),
//                 Text(
//                   "Pickup: ${job.pickupAddress}",
//                   style: const TextStyle(fontSize: 14),
//                 ),
//                 const SizedBox(height: 5),
//                 Text(
//                   "Dropoff: ${job.dropoffAddress}",
//                   style: const TextStyle(fontSize: 14),
//                 ),
//                 const SizedBox(height: 10),
//                 Text(
//                   "Description: ${job.description}",
//                   style: const TextStyle(fontSize: 14),
//                 ),
//               ],
//             ),
//           ),
//           const Divider(),

//           // Confirmation Button
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
//             child: SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: () {
//                   _confirmTransport(context, job);
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.orange.shade800,
//                   padding: const EdgeInsets.all(15),
//                 ),
//                 child: const Text(
//                   'Confirm Transport',
//                   style: TextStyle(color: Colors.white, fontSize: 16),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // Function to handle transport confirmation
//   void _confirmTransport(BuildContext context, BookingJob job) {
//     // Handle the logic for transport confirmation here (e.g., update status in database)
//     // For demonstration, showing a snackbar
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text("Transport for ${job.title} confirmed!"),
//         backgroundColor: Colors.green,
//       ),
//     );
//   }
// }
