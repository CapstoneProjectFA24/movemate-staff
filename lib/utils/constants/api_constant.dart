class APIConstants {
  static const baseUrl = "https://api.movemate.info/api/v1";
  static const contentType = 'application/json';
  static const contentHeader = 'Content-Type';
  static const authHeader = 'Authorization';
  static const prefixToken = 'bearer ';

  // auth
  static const login = '/authentications/login';
  static const register = '/authentications/register';
  static const checkExists = '/authentications/check-exists';
  static const verifyToken = '/authentications/verify-token';
  static const reGenerateToken = '/authentications/re';
  static const regiseterFcm = '/authentications/fcmtoken';
  static const authen = '/authentications';

  // Booking endpoints
  // static const get_truck_category = '/truckcategorys';
  static const get_service_truck_cate = '/services/truck-category';
  static const get_service_not_type_truck = '/services/not-type-truck';
  static const get_fees_system = '/fees/system';
  static const get_house_types = '/housetypes';
  static const get_package_services = '/services';
  static const post_valuation_booking_service = '/bookings/valuation-booking';

  //post booking

  static const post_booking_service = '/bookings/reviewer/update-booking';
  //post booking

  // static const post_booking_service = '/bookings/register-booking';
  // order
  static const bookings = '/bookings';

  // reviwer-status
  // static const reviewer_state = '/bookingdetails/reviewer/update-status';
  static const reviewer_state = '/bookingdetails/reviewer/update-status';
  static const reviewer_at = '/bookings/reviewer/review-at';
  static const assignments = '/assignments';

  // driver
  static const drivers = '/bookingdetails/driver/update-status';
  static const available_drivers = '/assignments/available-driver';
  static const assign_manual_available_drivers =
      '/assignments/assign-auto-by-manual-driver';
  static const driver_confirms_cash = '/bookings/confirm-pay-by-cash';

  static const put_staff_incident = '/assignments/report-booking-detail';
  static const put_driver_update_new_service =
      '/bookingdetails/driver/update-booking';

  //porter
  static const porters = '/bookingdetails/porter/update-status';
  static const available_porters = '/assignments/available-porter';
  static const assign_manual_available_porters =
      '/assignments/assign-auto-by-manual-porter';

  static const put_porter_update_new_service =
      '/bookingdetails/porter/update-booking';

  static const put_porter_accept_incident = '/assignments/porter';

  //get incident list
  static const get_incident_list_by_booking_id = '/bookingtrackers';
  // payments
  static const paymentsBooking = '/payments/create-payment-url';
  static const paymentsDeposit = '/wallets/recharge';

  //user info
  static const user_info = '/users';

  // api vietmap-key
  // static const apiVietMapKey =
  //     "be00f7e132bdd086ccd57e21460209836f5d37ce56beaa42";
  // // api vietmap-key
  // static const apiVietMapKey =
  //     "e7fb2f56a9eca6890aae01882c6b789527a21dcf88c75145";

   static const apiVietMapKey =
      "38db2f3d058b34e0f52f067fe66a902830fac1a044e8d444";

  // error
  static const Map<String, String> errorTrans = {
    'Email is already registered.': 'Email này đã được đăng kí',
    'Phone number is already registered.': 'Số điện thoại này đã được đăng kí',
    'Email already exists.': 'Email này đã được đăng kí',
    'Phone already exists.': 'Số điện thoại này đã được đăng kí',
    'Email does not exist in the system.':
        'Email không tồn tại trong hệ thống.',
    'Email or Password is invalid.': 'Email hoặc mật khẩu không hợp lệ.',
    'Your OTP code does not match the previously sent OTP code.':
        'Mã OTP bạn nhập không đúng.',
    'Email is invalid Email format.': 'Email sai định dạng.',
    'OTP code has expired.': 'Mã OTP đã hết hạn',
    'Email has not been previously authenticated.': 'Email chưa được xác thực',
    'Email is not yet authenticated with the previously sent OTP code.':
        'Email chưa được xác thực bằng mã OTP',
    'You are not allowed to access this function!':
        'Bạn không có quyền truy cập hệ thống',
    'Rejected Reason is not empty.': 'Lý do hủy đơn không được trống',

    // payment-error
    "Booking status must be either DEPOSITING or COMPLETED":
        "Trạng thái đặt đơn đã hoàn thành"
  };
}
