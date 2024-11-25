import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:movemate_staff/utils/providers/common_provider.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

class CallPage extends HookConsumerWidget {
  const CallPage({super.key, required this.callID});
  final String callID;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserId = ref.read(authProvider)!.id.toString();
    final currentUserName = ref.read(authProvider)!.name.toString();

    return ZegoUIKitPrebuiltCall(
        appID:
            1144653605, // Fill in the appID that you get from ZEGOCLOUD Admin Console.
        appSign:
            "af0bcdb584b619b8f46ad4d84f8083651e1a4829d574ad82a08f8ce53132bff8", // Fill in the appSign that you get from ZEGOCLOUD Admin Console.
        userID: currentUserId,
        userName: currentUserName,
        callID: callID,
        // You can also use groupVideo/groupVoice/oneOnOneVoice to make more types of calls.
        config: ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall());
  }
}
