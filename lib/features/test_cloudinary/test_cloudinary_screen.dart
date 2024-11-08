// import 'package:flutter/material.dart';
// import 'package:auto_route/auto_route.dart';
// import 'package:flutter_hooks/flutter_hooks.dart';
// import 'package:movemate_staff/utils/commons/widgets/cloudinary/cloudinary_camera_upload_widget.dart';
// import 'package:movemate_staff/utils/commons/widgets/cloudinary/cloudinary_upload_widget.dart';

// @RoutePage()
// class TestCloudinaryScreen extends HookWidget {
//   const TestCloudinaryScreen({super.key});

//   @override
//   Widget build(BuildContext context) {

//     // Danh sách hình ảnh giả lập từ backend
//     final images = useState<List<String>>([
//       // "https://res.cloudinary.com/dkpnkjnxs/image/upload/v1728483658/movemate/kv3nomfji9rtofok0wmo.jpg",  // 1
//       // "https://res.cloudinary.com/dkpnkjnxs/image/upload/v1728485337/movemate/g12muevg0sqpkboh232d.jpg"
//     ]);
//     print('Images: ${images.value}');

// // Tách publicId từ danh sách hình ảnh   => cái này t fotmat từ images =>
// // id riêng ví dụ :
//         // https://res.cloudinary.com/dkpnkjnxs/image/upload/v1728483658/movemate/kv3nomfji9rtofok0wmo.jpg
//         // thành => movemate/kv3nomfji9rtofok0wmo
//     final imagePublicIds = useState<List<String>>(
//       images.value.map((url) {
//         final uri = Uri.parse(url);
//         final pathSegments = uri.pathSegments;
//         return pathSegments.length > 1
//             ? '${pathSegments[pathSegments.length - 2]}/${pathSegments.last.split('.').first}'
//             : '';
//       }).toList(),
//     );

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Test Cloudinary Upload'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Image Upload Test',
//               style: TextStyle(
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 16),
//             CloudinaryCameraUploadWidget(
//               imagePublicIds: imagePublicIds.value,
//               onImageUploaded: (url, publicId) {
//                 print('Uploaded successfully: $url');
//                 print('Uploaded successfully: $publicId');
//                 // Cập nhật danh sách images bằng URL trả về
//                       //=> RỒI LƯU VÔ state images nè rồi khi PUT cập nhật thì gửi cái images mới lên flow api ấy hen chú TUẤN
//                 images.value = [...images.value, url];

//                 // Cập nhật danh sách publicIds
//                 imagePublicIds.value = [...imagePublicIds.value, publicId];

//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(
//                     content: Text('Image uploaded successfully: $url'),
//                     duration: const Duration(seconds: 2),
//                   ),
//                 );
//               },
//               onImageRemoved: (publicId) {
//                 imagePublicIds.value =
//                     imagePublicIds.value.where((id) => id != publicId).toList();
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(
//                     content: Text('Image removed: $publicId'),
//                     duration: const Duration(seconds: 2),
//                   ),
//                 );
//               },
//             ),
//             const SizedBox(height: 16),
//             Text(
//               'Uploaded Images: ${imagePublicIds.value.length}',
//               style: const TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:movemate_staff/utils/commons/widgets/cloudinary/cloudinary_camera_upload_widget.dart';

@RoutePage()
class TestCloudinaryScreen extends HookWidget {
  const TestCloudinaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Phần 1: Image Upload Test 1
    final images1 = useState<List<String>>([]);
    final imagePublicIds1 = useState<List<String>>([]);

    // Phần 2: Image Upload Test 2
    final images2 = useState<List<String>>([]);
    final imagePublicIds2 = useState<List<String>>([]);

    // Phần 3: Image Upload Test 3
    final images3 = useState<List<String>>([]);
    final imagePublicIds3 = useState<List<String>>([]);

    // State for full screen image viewer
    final fullScreenImage = useState<String?>(null);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Upload Test'),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Phần 1: Image Upload Test 1
                  const Text(
                    'Nhân viên xác nhận: Nguyễn Văn A',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  CloudinaryCameraUploadWidget(
                    imagePublicIds: imagePublicIds1.value,
                    onImageUploaded: (url, publicId) {
                      images1.value = [...images1.value, url];
                      imagePublicIds1.value = [
                        ...imagePublicIds1.value,
                        publicId
                      ];
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Image uploaded successfully: $url'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    onImageRemoved: (publicId) {
                      imagePublicIds1.value = imagePublicIds1.value
                          .where((id) => id != publicId)
                          .toList();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Image removed: $publicId'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    onImageTapped: (url) {
                      fullScreenImage.value = url;
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Uploaded Images: ${imagePublicIds1.value.length}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 32),
                  const Text(
                    'Tài xế xác nhận: Nguyễ Văn B',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  CloudinaryCameraUploadWidget(
                    imagePublicIds: imagePublicIds2.value,
                    onImageUploaded: (url, publicId) {
                      images2.value = [...images2.value, url];
                      imagePublicIds2.value = [
                        ...imagePublicIds2.value,
                        publicId
                      ];
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Image uploaded successfully: $url'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    onImageRemoved: (publicId) {
                      imagePublicIds2.value = imagePublicIds2.value
                          .where((id) => id != publicId)
                          .toList();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Image removed: $publicId'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    onImageTapped: (url) {
                      fullScreenImage.value = url;
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Uploaded Images: ${imagePublicIds2.value.length}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 32),
                  const Text(
                    'Khách hàng xác nhận: Nguyễn Văn C',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  CloudinaryCameraUploadWidget(
                    imagePublicIds: imagePublicIds3.value,
                    onImageUploaded: (url, publicId) {
                      images3.value = [...images3.value, url];
                      imagePublicIds3.value = [
                        ...imagePublicIds3.value,
                        publicId
                      ];
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Image uploaded successfully: $url'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    onImageRemoved: (publicId) {
                      imagePublicIds3.value = imagePublicIds3.value
                          .where((id) => id != publicId)
                          .toList();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Image removed: $publicId'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    onImageTapped: (url) {
                      fullScreenImage.value = url;
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Uploaded Images: ${imagePublicIds3.value.length}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (fullScreenImage.value != null)
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  fullScreenImage.value = null;
                },
                child: Container(
                  color: Colors.black.withOpacity(0.8),
                  child: Center(
                    child: Image.network(
                      fullScreenImage.value!,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
