import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class BDappsService {
  static const String baseUrl = 'https://bdappsdigitalapps.com/NADB26095';
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
  ));

  /// Parse response.data safely into Map<String, dynamic>
  Map<String, dynamic> _parseResponse(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return {};
  }

  // Request OTP for subscription
  Future<Map<String, dynamic>> sendOtp(String mobileNumber) async {
    final cleaned = _cleanMobile(mobileNumber);
    try {
      final response = await _dio.post(
        '$baseUrl/send_otp.php',
        data: {'user_mobile': cleaned, 'subscriberId': cleaned},
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
      if (response.statusCode == 200 && response.data != null) {
        final parsed = _parseResponse(response.data);
        if (parsed.isNotEmpty) return parsed;
      }
      return {'success': false, 'message': 'No response from server'};
    } catch (e) {
      if (kDebugMode) print('sendOtp error: $e');
      return {'success': false, 'message': 'Network error. Please check your connection.'};
    }
  }

  // Verify OTP PIN — requires referenceNo from sendOtp response
  Future<Map<String, dynamic>> verifyOtp(String mobileNumber, String otp, String referenceNo) async {
    final cleaned = _cleanMobile(mobileNumber);
    try {
      final response = await _dio.post(
        '$baseUrl/verify_otp.php',
        data: {
          'user_mobile': cleaned,
          'subscriberId': cleaned,
          'Otp': otp,
          'otp': otp,
          'referenceNo': referenceNo,
        },
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
      if (response.statusCode == 200 && response.data != null) {
        final parsed = _parseResponse(response.data);
        if (parsed.isNotEmpty) return parsed;
      }
      return {'statusCode': 'FAILED', 'message': 'No response from server'};
    } catch (e) {
      if (kDebugMode) print('verifyOtp error: $e');
      return {'statusCode': 'FAILED', 'message': 'Verification failed. Please try again.'};
    }
  }

  // Check Subscription Status against backend
  Future<bool> checkSubscription(String mobileNumber) async {
    final cleaned = _cleanMobile(mobileNumber);
    if (cleaned.isEmpty || cleaned.length < 11) return false;
    try {
      final response = await _dio.post(
        '$baseUrl/check_subscription.php',
        data: {'user_mobile': cleaned, 'subscriberId': cleaned},
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
      if (response.statusCode == 200 && response.data != null) {
        final data = _parseResponse(response.data);
        if (data.isNotEmpty) {
          // Explicitly check for UNREGISTERED or isSubscribed == false
          if (data['isSubscribed'] == false ||
              data['subscriptionStatus'] == 'UNREGISTERED' ||
              data['status'] == 'UNREGISTERED') {
            return false;
          }
          return data['isSubscribed'] == true ||
              data['subscriptionStatus'] == 'REGISTERED' ||
              data['status'] == 'SUBSCRIBED';
        }
      }
      return false;
    } catch (e) {
      if (kDebugMode) print('checkSubscription error: $e');
      return false;
    }
  }

  // Unsubscribe Service
  Future<Map<String, dynamic>> unsubscribe(String mobileNumber) async {
    final cleaned = _cleanMobile(mobileNumber);
    if (cleaned.isEmpty || cleaned.length < 11) {
      return {'success': false, 'message': 'Invalid mobile number'};
    }
    try {
      final response = await _dio.post(
        '$baseUrl/unsubscribe.php',
        data: {'user_mobile': cleaned, 'subscriberId': cleaned},
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
      if (response.statusCode == 200 && response.data != null) {
        final parsed = _parseResponse(response.data);
        if (parsed.isNotEmpty) return parsed;
      }
      return {'success': false, 'message': 'No response from server'};
    } catch (e) {
      if (kDebugMode) print('unsubscribe error: $e');
      return {'success': false, 'message': 'Unsubscribe failed. Please try again.'};
    }
  }

  // Account Auth: Check if user exists & has password set in subscribed_users.json
  Future<Map<String, dynamic>> checkUserAccount(String mobileNumber) async {
    final cleaned = _cleanMobile(mobileNumber);
    try {
      final response = await _dio.post(
        '$baseUrl/account_auth.php?action=check',
        data: {'user_mobile': cleaned},
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
      if (response.statusCode == 200 && response.data != null) {
        return _parseResponse(response.data);
      }
      return {'success': false};
    } catch (e) {
      if (kDebugMode) print('checkUserAccount error: $e');
      return {'success': false};
    }
  }

  // Account Auth: Set/Save user password
  Future<bool> setUserPassword(String mobileNumber, String password) async {
    final cleaned = _cleanMobile(mobileNumber);
    try {
      final response = await _dio.post(
        '$baseUrl/account_auth.php?action=set_password',
        data: {'user_mobile': cleaned, 'password': password},
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
      if (response.statusCode == 200 && response.data != null) {
        final parsed = _parseResponse(response.data);
        return parsed['success'] == true;
      }
      return false;
    } catch (e) {
      if (kDebugMode) print('setUserPassword error: $e');
      return false;
    }
  }

  // Account Auth: Verify entered password
  Future<Map<String, dynamic>> verifyUserPassword(String mobileNumber, String password) async {
    final cleaned = _cleanMobile(mobileNumber);
    try {
      final response = await _dio.post(
        '$baseUrl/account_auth.php?action=verify_password',
        data: {'user_mobile': cleaned, 'password': password},
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
      if (response.statusCode == 200 && response.data != null) {
        return _parseResponse(response.data);
      }
      return {'success': false, 'message': 'Network error'};
    } catch (e) {
      if (kDebugMode) print('verifyUserPassword error: $e');
      return {'success': false, 'message': 'Verification failed'};
    }
  }

  String _cleanMobile(String raw) {
    String digits = raw.replaceAll(RegExp(r'\D+'), '');
    if (digits.startsWith('880') && digits.length == 13) {
      digits = digits.substring(2);
    } else if (digits.length == 10 && digits.startsWith('1')) {
      digits = '0$digits';
    }
    return digits;
  }
}
