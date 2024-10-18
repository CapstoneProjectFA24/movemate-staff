import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movemate_staff/utils/commons/functions/functions_common_export.dart';
import 'package:movemate_staff/utils/enums/enums_export.dart';

class RoleGuard extends AutoRouteGuard {
  final Ref _ref;
  final List<UserRole> allowedRoles;

  RoleGuard(this._ref, this.allowedRoles);

  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) async {
    final userData = await SharedPreferencesUtils.getInstance('user_token');

    if (allowedRoles.contains(userData?.roleName)) {
      resolver.next();
    } else {
      showDialog(
        context: router.navigatorKey.currentContext!,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.black87,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            title: const Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.redAccent,
                  size: 30.0,
                ),
                SizedBox(width: 8),
                Text(
                  'Truy cập bị từ chối',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            content: const Text(
              'Bạn không có quyền truy cập vô trang này',
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.white70,
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0, bottom: 8.0),
                child: TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: const Text(
                    'Đồng ý',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    router.pop();
                  },
                ),
              ),
            ],
          );
        },
      );
      resolver.next(false);
    }
  }
}
