// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'app_router.dart';

abstract class _$AppRouter extends RootStackRouter {
  // ignore: unused_element
  _$AppRouter({super.navigatorKey});

  @override
  final Map<String, PageFactory> pagesMap = {
    AddJobScreenRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const AddJobScreen(),
      );
    },
    AvailableVehiclesScreenRoute.name: (routeData) {
      final args = routeData.argsAs<AvailableVehiclesScreenRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: AvailableVehiclesScreen(
          key: args.key,
          job: args.job,
        ),
      );
    },
    BookingScreenServiceRoute.name: (routeData) {
      final args = routeData.argsAs<BookingScreenServiceRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: BookingScreenService(
          key: args.key,
          job: args.job,
        ),
      );
    },
    ContactScreenRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const ContactScreen(),
      );
    },
    DriverDetailScreenRoute.name: (routeData) {
      final args = routeData.argsAs<DriverDetailScreenRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: DriverDetailScreen(
          key: args.key,
          job: args.job,
        ),
      );
    },
    DriverScreenRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const DriverScreen(),
      );
    },
    DriversScreenRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const DriversScreen(),
      );
    },
    GenerateNewJobScreenRoute.name: (routeData) {
      final args = routeData.argsAs<GenerateNewJobScreenRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: GenerateNewJobScreen(
          key: args.key,
          job: args.job,
        ),
      );
    },
    HistoryScreenRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const HistoryScreen(),
      );
    },
    HomeScreenRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const HomeScreen(),
      );
    },
    InfoScreenRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const InfoScreen(),
      );
    },
    JobDetailsScreenRoute.name: (routeData) {
      final args = routeData.argsAs<JobDetailsScreenRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: JobDetailsScreen(
          key: args.key,
          job: args.job,
        ),
      );
    },
    JobScreenRoute.name: (routeData) {
      final args = routeData.argsAs<JobScreenRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: JobScreen(
          key: args.key,
          isReviewOnline: args.isReviewOnline,
        ),
      );
    },
    MapScreenTestRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const MapScreenTest(),
      );
    },
    OTPVerificationScreenRoute.name: (routeData) {
      final args = routeData.argsAs<OTPVerificationScreenRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: OTPVerificationScreen(
          key: args.key,
          phoneNumber: args.phoneNumber,
          verifyType: args.verifyType,
        ),
      );
    },
    OrderScreenRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const OrderScreen(),
      );
    },
    PorterConfirmScreenRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const PorterConfirmScreen(),
      );
    },
    PorterDetailScreenRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const PorterDetailScreen(),
      );
    },
    PorterScreenRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const PorterScreen(),
      );
    },
    PrivacyPolicyScreenRoute.name: (routeData) {
      final args = routeData.argsAs<PrivacyPolicyScreenRouteArgs>(
          orElse: () => const PrivacyPolicyScreenRouteArgs());
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: PrivacyPolicyScreen(key: args.key),
      );
    },
    ProfileDetailScreenRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const ProfileDetailScreen(),
      );
    },
    ProfileScreenRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const ProfileScreen(),
      );
    },
    SignInScreenRoute.name: (routeData) {
      final args = routeData.argsAs<SignInScreenRouteArgs>(
          orElse: () => const SignInScreenRouteArgs());
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: SignInScreen(key: args.key),
      );
    },
    SignUpScreenRoute.name: (routeData) {
      final args = routeData.argsAs<SignUpScreenRouteArgs>(
          orElse: () => const SignUpScreenRouteArgs());
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: SignUpScreen(key: args.key),
      );
    },
    SplashScreenRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const SplashScreen(),
      );
    },
    TabViewScreenRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const TabViewScreen(),
      );
    },
    TermOfUseScreenRoute.name: (routeData) {
      final args = routeData.argsAs<TermOfUseScreenRouteArgs>(
          orElse: () => const TermOfUseScreenRouteArgs());
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: TermOfUseScreen(key: args.key),
      );
    },
    TestCloudinaryScreenRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const TestCloudinaryScreen(),
      );
    },
    TestScreenRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const TestScreen(),
      );
    },
    WalletScreenRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const WalletScreen(),
      );
    },
  };
}

/// generated route for
/// [AddJobScreen]
class AddJobScreenRoute extends PageRouteInfo<void> {
  const AddJobScreenRoute({List<PageRouteInfo>? children})
      : super(
          AddJobScreenRoute.name,
          initialChildren: children,
        );

  static const String name = 'AddJobScreenRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [AvailableVehiclesScreen]
class AvailableVehiclesScreenRoute
    extends PageRouteInfo<AvailableVehiclesScreenRouteArgs> {
  AvailableVehiclesScreenRoute({
    Key? key,
    required BookingResponseEntity job,
    List<PageRouteInfo>? children,
  }) : super(
          AvailableVehiclesScreenRoute.name,
          args: AvailableVehiclesScreenRouteArgs(
            key: key,
            job: job,
          ),
          initialChildren: children,
        );

  static const String name = 'AvailableVehiclesScreenRoute';

  static const PageInfo<AvailableVehiclesScreenRouteArgs> page =
      PageInfo<AvailableVehiclesScreenRouteArgs>(name);
}

class AvailableVehiclesScreenRouteArgs {
  const AvailableVehiclesScreenRouteArgs({
    this.key,
    required this.job,
  });

  final Key? key;

  final BookingResponseEntity job;

  @override
  String toString() {
    return 'AvailableVehiclesScreenRouteArgs{key: $key, job: $job}';
  }
}

/// generated route for
/// [BookingScreenService]
class BookingScreenServiceRoute
    extends PageRouteInfo<BookingScreenServiceRouteArgs> {
  BookingScreenServiceRoute({
    Key? key,
    required BookingResponseEntity job,
    List<PageRouteInfo>? children,
  }) : super(
          BookingScreenServiceRoute.name,
          args: BookingScreenServiceRouteArgs(
            key: key,
            job: job,
          ),
          initialChildren: children,
        );

  static const String name = 'BookingScreenServiceRoute';

  static const PageInfo<BookingScreenServiceRouteArgs> page =
      PageInfo<BookingScreenServiceRouteArgs>(name);
}

class BookingScreenServiceRouteArgs {
  const BookingScreenServiceRouteArgs({
    this.key,
    required this.job,
  });

  final Key? key;

  final BookingResponseEntity job;

  @override
  String toString() {
    return 'BookingScreenServiceRouteArgs{key: $key, job: $job}';
  }
}

/// generated route for
/// [ContactScreen]
class ContactScreenRoute extends PageRouteInfo<void> {
  const ContactScreenRoute({List<PageRouteInfo>? children})
      : super(
          ContactScreenRoute.name,
          initialChildren: children,
        );

  static const String name = 'ContactScreenRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [DriverDetailScreen]
class DriverDetailScreenRoute
    extends PageRouteInfo<DriverDetailScreenRouteArgs> {
  DriverDetailScreenRoute({
    Key? key,
    required BookingResponseEntity job,
    List<PageRouteInfo>? children,
  }) : super(
          DriverDetailScreenRoute.name,
          args: DriverDetailScreenRouteArgs(
            key: key,
            job: job,
          ),
          initialChildren: children,
        );

  static const String name = 'DriverDetailScreenRoute';

  static const PageInfo<DriverDetailScreenRouteArgs> page =
      PageInfo<DriverDetailScreenRouteArgs>(name);
}

class DriverDetailScreenRouteArgs {
  const DriverDetailScreenRouteArgs({
    this.key,
    required this.job,
  });

  final Key? key;

  final BookingResponseEntity job;

  @override
  String toString() {
    return 'DriverDetailScreenRouteArgs{key: $key, job: $job}';
  }
}

/// generated route for
/// [DriverScreen]
class DriverScreenRoute extends PageRouteInfo<void> {
  const DriverScreenRoute({List<PageRouteInfo>? children})
      : super(
          DriverScreenRoute.name,
          initialChildren: children,
        );

  static const String name = 'DriverScreenRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [DriversScreen]
class DriversScreenRoute extends PageRouteInfo<void> {
  const DriversScreenRoute({List<PageRouteInfo>? children})
      : super(
          DriversScreenRoute.name,
          initialChildren: children,
        );

  static const String name = 'DriversScreenRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [GenerateNewJobScreen]
class GenerateNewJobScreenRoute
    extends PageRouteInfo<GenerateNewJobScreenRouteArgs> {
  GenerateNewJobScreenRoute({
    Key? key,
    required BookingResponseEntity job,
    List<PageRouteInfo>? children,
  }) : super(
          GenerateNewJobScreenRoute.name,
          args: GenerateNewJobScreenRouteArgs(
            key: key,
            job: job,
          ),
          initialChildren: children,
        );

  static const String name = 'GenerateNewJobScreenRoute';

  static const PageInfo<GenerateNewJobScreenRouteArgs> page =
      PageInfo<GenerateNewJobScreenRouteArgs>(name);
}

class GenerateNewJobScreenRouteArgs {
  const GenerateNewJobScreenRouteArgs({
    this.key,
    required this.job,
  });

  final Key? key;

  final BookingResponseEntity job;

  @override
  String toString() {
    return 'GenerateNewJobScreenRouteArgs{key: $key, job: $job}';
  }
}

/// generated route for
/// [HistoryScreen]
class HistoryScreenRoute extends PageRouteInfo<void> {
  const HistoryScreenRoute({List<PageRouteInfo>? children})
      : super(
          HistoryScreenRoute.name,
          initialChildren: children,
        );

  static const String name = 'HistoryScreenRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [HomeScreen]
class HomeScreenRoute extends PageRouteInfo<void> {
  const HomeScreenRoute({List<PageRouteInfo>? children})
      : super(
          HomeScreenRoute.name,
          initialChildren: children,
        );

  static const String name = 'HomeScreenRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [InfoScreen]
class InfoScreenRoute extends PageRouteInfo<void> {
  const InfoScreenRoute({List<PageRouteInfo>? children})
      : super(
          InfoScreenRoute.name,
          initialChildren: children,
        );

  static const String name = 'InfoScreenRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [JobDetailsScreen]
class JobDetailsScreenRoute extends PageRouteInfo<JobDetailsScreenRouteArgs> {
  JobDetailsScreenRoute({
    Key? key,
    required BookingResponseEntity job,
    List<PageRouteInfo>? children,
  }) : super(
          JobDetailsScreenRoute.name,
          args: JobDetailsScreenRouteArgs(
            key: key,
            job: job,
          ),
          initialChildren: children,
        );

  static const String name = 'JobDetailsScreenRoute';

  static const PageInfo<JobDetailsScreenRouteArgs> page =
      PageInfo<JobDetailsScreenRouteArgs>(name);
}

class JobDetailsScreenRouteArgs {
  const JobDetailsScreenRouteArgs({
    this.key,
    required this.job,
  });

  final Key? key;

  final BookingResponseEntity job;

  @override
  String toString() {
    return 'JobDetailsScreenRouteArgs{key: $key, job: $job}';
  }
}

/// generated route for
/// [JobScreen]
class JobScreenRoute extends PageRouteInfo<JobScreenRouteArgs> {
  JobScreenRoute({
    Key? key,
    required bool isReviewOnline,
    List<PageRouteInfo>? children,
  }) : super(
          JobScreenRoute.name,
          args: JobScreenRouteArgs(
            key: key,
            isReviewOnline: isReviewOnline,
          ),
          initialChildren: children,
        );

  static const String name = 'JobScreenRoute';

  static const PageInfo<JobScreenRouteArgs> page =
      PageInfo<JobScreenRouteArgs>(name);
}

class JobScreenRouteArgs {
  const JobScreenRouteArgs({
    this.key,
    required this.isReviewOnline,
  });

  final Key? key;

  final bool isReviewOnline;

  @override
  String toString() {
    return 'JobScreenRouteArgs{key: $key, isReviewOnline: $isReviewOnline}';
  }
}

/// generated route for
/// [MapScreenTest]
class MapScreenTestRoute extends PageRouteInfo<void> {
  const MapScreenTestRoute({List<PageRouteInfo>? children})
      : super(
          MapScreenTestRoute.name,
          initialChildren: children,
        );

  static const String name = 'MapScreenTestRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [OTPVerificationScreen]
class OTPVerificationScreenRoute
    extends PageRouteInfo<OTPVerificationScreenRouteArgs> {
  OTPVerificationScreenRoute({
    Key? key,
    required String phoneNumber,
    required VerificationOTPType verifyType,
    List<PageRouteInfo>? children,
  }) : super(
          OTPVerificationScreenRoute.name,
          args: OTPVerificationScreenRouteArgs(
            key: key,
            phoneNumber: phoneNumber,
            verifyType: verifyType,
          ),
          initialChildren: children,
        );

  static const String name = 'OTPVerificationScreenRoute';

  static const PageInfo<OTPVerificationScreenRouteArgs> page =
      PageInfo<OTPVerificationScreenRouteArgs>(name);
}

class OTPVerificationScreenRouteArgs {
  const OTPVerificationScreenRouteArgs({
    this.key,
    required this.phoneNumber,
    required this.verifyType,
  });

  final Key? key;

  final String phoneNumber;

  final VerificationOTPType verifyType;

  @override
  String toString() {
    return 'OTPVerificationScreenRouteArgs{key: $key, phoneNumber: $phoneNumber, verifyType: $verifyType}';
  }
}

/// generated route for
/// [OrderScreen]
class OrderScreenRoute extends PageRouteInfo<void> {
  const OrderScreenRoute({List<PageRouteInfo>? children})
      : super(
          OrderScreenRoute.name,
          initialChildren: children,
        );

  static const String name = 'OrderScreenRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [PorterConfirmScreen]
class PorterConfirmScreenRoute extends PageRouteInfo<void> {
  const PorterConfirmScreenRoute({List<PageRouteInfo>? children})
      : super(
          PorterConfirmScreenRoute.name,
          initialChildren: children,
        );

  static const String name = 'PorterConfirmScreenRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [PorterDetailScreen]
class PorterDetailScreenRoute extends PageRouteInfo<void> {
  const PorterDetailScreenRoute({List<PageRouteInfo>? children})
      : super(
          PorterDetailScreenRoute.name,
          initialChildren: children,
        );

  static const String name = 'PorterDetailScreenRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [PorterScreen]
class PorterScreenRoute extends PageRouteInfo<void> {
  const PorterScreenRoute({List<PageRouteInfo>? children})
      : super(
          PorterScreenRoute.name,
          initialChildren: children,
        );

  static const String name = 'PorterScreenRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [PrivacyPolicyScreen]
class PrivacyPolicyScreenRoute
    extends PageRouteInfo<PrivacyPolicyScreenRouteArgs> {
  PrivacyPolicyScreenRoute({
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
          PrivacyPolicyScreenRoute.name,
          args: PrivacyPolicyScreenRouteArgs(key: key),
          initialChildren: children,
        );

  static const String name = 'PrivacyPolicyScreenRoute';

  static const PageInfo<PrivacyPolicyScreenRouteArgs> page =
      PageInfo<PrivacyPolicyScreenRouteArgs>(name);
}

class PrivacyPolicyScreenRouteArgs {
  const PrivacyPolicyScreenRouteArgs({this.key});

  final Key? key;

  @override
  String toString() {
    return 'PrivacyPolicyScreenRouteArgs{key: $key}';
  }
}

/// generated route for
/// [ProfileDetailScreen]
class ProfileDetailScreenRoute extends PageRouteInfo<void> {
  const ProfileDetailScreenRoute({List<PageRouteInfo>? children})
      : super(
          ProfileDetailScreenRoute.name,
          initialChildren: children,
        );

  static const String name = 'ProfileDetailScreenRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [ProfileScreen]
class ProfileScreenRoute extends PageRouteInfo<void> {
  const ProfileScreenRoute({List<PageRouteInfo>? children})
      : super(
          ProfileScreenRoute.name,
          initialChildren: children,
        );

  static const String name = 'ProfileScreenRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [SignInScreen]
class SignInScreenRoute extends PageRouteInfo<SignInScreenRouteArgs> {
  SignInScreenRoute({
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
          SignInScreenRoute.name,
          args: SignInScreenRouteArgs(key: key),
          initialChildren: children,
        );

  static const String name = 'SignInScreenRoute';

  static const PageInfo<SignInScreenRouteArgs> page =
      PageInfo<SignInScreenRouteArgs>(name);
}

class SignInScreenRouteArgs {
  const SignInScreenRouteArgs({this.key});

  final Key? key;

  @override
  String toString() {
    return 'SignInScreenRouteArgs{key: $key}';
  }
}

/// generated route for
/// [SignUpScreen]
class SignUpScreenRoute extends PageRouteInfo<SignUpScreenRouteArgs> {
  SignUpScreenRoute({
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
          SignUpScreenRoute.name,
          args: SignUpScreenRouteArgs(key: key),
          initialChildren: children,
        );

  static const String name = 'SignUpScreenRoute';

  static const PageInfo<SignUpScreenRouteArgs> page =
      PageInfo<SignUpScreenRouteArgs>(name);
}

class SignUpScreenRouteArgs {
  const SignUpScreenRouteArgs({this.key});

  final Key? key;

  @override
  String toString() {
    return 'SignUpScreenRouteArgs{key: $key}';
  }
}

/// generated route for
/// [SplashScreen]
class SplashScreenRoute extends PageRouteInfo<void> {
  const SplashScreenRoute({List<PageRouteInfo>? children})
      : super(
          SplashScreenRoute.name,
          initialChildren: children,
        );

  static const String name = 'SplashScreenRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [TabViewScreen]
class TabViewScreenRoute extends PageRouteInfo<void> {
  const TabViewScreenRoute({List<PageRouteInfo>? children})
      : super(
          TabViewScreenRoute.name,
          initialChildren: children,
        );

  static const String name = 'TabViewScreenRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [TermOfUseScreen]
class TermOfUseScreenRoute extends PageRouteInfo<TermOfUseScreenRouteArgs> {
  TermOfUseScreenRoute({
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
          TermOfUseScreenRoute.name,
          args: TermOfUseScreenRouteArgs(key: key),
          initialChildren: children,
        );

  static const String name = 'TermOfUseScreenRoute';

  static const PageInfo<TermOfUseScreenRouteArgs> page =
      PageInfo<TermOfUseScreenRouteArgs>(name);
}

class TermOfUseScreenRouteArgs {
  const TermOfUseScreenRouteArgs({this.key});

  final Key? key;

  @override
  String toString() {
    return 'TermOfUseScreenRouteArgs{key: $key}';
  }
}

/// generated route for
/// [TestCloudinaryScreen]
class TestCloudinaryScreenRoute extends PageRouteInfo<void> {
  const TestCloudinaryScreenRoute({List<PageRouteInfo>? children})
      : super(
          TestCloudinaryScreenRoute.name,
          initialChildren: children,
        );

  static const String name = 'TestCloudinaryScreenRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [TestScreen]
class TestScreenRoute extends PageRouteInfo<void> {
  const TestScreenRoute({List<PageRouteInfo>? children})
      : super(
          TestScreenRoute.name,
          initialChildren: children,
        );

  static const String name = 'TestScreenRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [WalletScreen]
class WalletScreenRoute extends PageRouteInfo<void> {
  const WalletScreenRoute({List<PageRouteInfo>? children})
      : super(
          WalletScreenRoute.name,
          initialChildren: children,
        );

  static const String name = 'WalletScreenRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}
