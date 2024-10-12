import 'package:flutter/material.dart';
import 'package:movemate_staff/utils/commons/functions/shared_preference_utils.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:dio/dio.dart';
import 'package:auto_route/auto_route.dart';

// config
import 'package:movemate_staff/configs/routes/app_router.dart';

// domain - data
import 'package:movemate_staff/features/auth/domain/repositories/auth_repository.dart';

// utils
import 'package:movemate_staff/utils/constants/asset_constant.dart';
import 'package:movemate_staff/utils/commons/functions/api_utils.dart';
import 'package:movemate_staff/utils/commons/widgets/widgets_common_export.dart';
import 'package:movemate_staff/utils/extensions/extensions_export.dart';
import 'package:movemate_staff/utils/constants/api_constant.dart';

part 'profile_controller.g.dart';

@riverpod
class ProfileController extends _$ProfileController {
  @override
  FutureOr<void> build() {}
}
