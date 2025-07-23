import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ApiBaseClass {
  final Dio _client = Dio(BaseOptions(
    receiveDataWhenStatusError: true,
    followRedirects: true,
    connectTimeout: Duration(seconds: 5),
    receiveTimeout: Duration(seconds: 5),
  ));

  Future<bool> hasInternetConnection() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  Future<dynamic> get(url, bool auth) async {

    return _retry(() async {
      try {
      final response = await _client.get(url, options: Options(headers: _buildHeaders(auth)));
      return _handleResponse(response);
    } on TimeoutException {
      throw TimeOutException('Request timed out');
    } on SocketException {
      throw FetchDataException('No Internet connection');
    } on DioError catch (e) {
      return _handleDioError(e);
    }
    });
  }

  Future<dynamic> post( url, dynamic body, bool auth) async {

    print("📤 [POST] $url");
    print("📦 Body: $body");

    return _retry(() async {
      print("📲 [ApibaseClass] retry called");
      try {
      final response = await _client.post(url, data: body, options: Options(headers: _buildHeaders(auth)));
      return _handleResponse(response);
    } on TimeoutException {
        print("⏱️ Timeout occurred during POST: $url");
        throw TimeOutException('Request timed out');
    } on SocketException {
        print("❌ No internet connection during POST: $url");
        throw FetchDataException('No Internet connection');
    } on DioError catch (e) {
      return _handleDioError(e);
    }
    });
  }

  Map<String, String> _buildHeaders(bool auth) {
    final headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      if (auth) 'Authorization': 'Bearer token',
    };
    print("🧾 Headers: $headers");
    return headers;
  }

  dynamic _handleDioError(DioError e) async {
    print("⚠️ DioError occurred: ${e.message}");
    print("⚠️ DioError type: ${e.type}");
    print("📉 Stacktrace: ${e.stackTrace}");
    if (e.response != null) {
      print("🔁 DioError Status Code: ${e.response?.statusCode}");
    }

    if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
      print("🔐 Token expired, attempting refresh...");

      final success = await _refreshToken();
      if (success) {
        final options = e.requestOptions;

        // Retry original request with updated token
        final newOptions = Options(
          method: options.method,
          headers: {
            ...options.headers,
            'Authorization': 'Bearer accesstoken',
          },
        );
        print("🔄 Retrying original request after token refresh...");

        final response = await _client.request(
          options.path,
          data: options.data,
          queryParameters: options.queryParameters,
          options: newOptions,
        );

        return _handleResponse(response);
      } else {
        print("❌ Token refresh failed");
        throw UnauthorisedException("Session expired. Please log in again.");
      }
    }

    if (e.type == DioExceptionType.badCertificate) {
      print("❌ SSL Certificate Error");

      throw FetchDataException("SSL Certificate Error");
    }

    if (e.response != null) {
      return _handleResponse(e.response!);
    } else if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      print("⏱️ Timeout from Dio");
      throw TimeOutException("Request Timeout");
    } else {
      print("❌ Unknown Dio Error: ${e.message}");
      throw FetchDataException(e.message);
    }
  }

  dynamic _handleResponse(Response response) {
    print("📥 Response Status: ${response.statusCode}");
    print("📥 Response Data: ${response.data}");

    switch (response.statusCode) {
      case 200:
        return response.data;
      case 400:
        throw BadRequestException(response.data.toString());
      case 401:
        throw UnauthorisedException(response.data.toString());
      case 403:
        throw UnauthorisedException(response.data.toString());
      case 404:
        throw FetchDataException('Not Found');
      case 500:
        throw FetchDataException('Internal Server Error');
      default:
        throw FetchDataException('Unexpected Error: ${response.statusCode}');
    }
  }

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = "refreshToken";
      if (refreshToken == null) return false;
      print("🔄 Sending refresh token request...");

      final response = await _client.post(
        'https://your.api/refresh-token',
        data: {'refresh_token': refreshToken},
      );

      if (response.statusCode == 200) {
        print("✅ Token refreshed");

        final newAccessToken = response.data['access_token'];
        final newRefreshToken = response.data['refresh_token'];

        // Update SessionController directly
        // SessionController.accessToken = newAccessToken;
        // SessionController.refreshToken = newRefreshToken;

        return true;
      }
      print("❌ Failed to refresh token");

      return false;
    } catch (e) {
      print("❌ Refresh token error: $e");

      return false;
    }
  }


  Future<dynamic> _retry(Function retryFunction, {int retries = 2}) async {
    int attempt = 0;

    while (attempt < retries) {
      try {
        // Check before retrying
        if (!await hasInternetConnection()) {
          print("📡 No internet, waiting max 15s...");
          await _waitForInternet(Duration(seconds: 15));
        }

        print("🔁 Retry Attempt: ${attempt + 1}");

        // Wrap retryFunction in 15s timeout
        return await retryFunction().timeout(Duration(seconds: 15));
      } on TimeoutException catch (_) {
        print("⏱️ Timeout on attempt ${attempt + 1}");
        attempt++;
        if (attempt >= retries) {
          throw FetchDataException("Request timed out after $retries attempts");
        }
      } on DioError catch (e) {
        if (e.type == DioErrorType.connectionTimeout ||
            e.type == DioErrorType.receiveTimeout ||
            e.type == DioErrorType.connectionError) {
          print("🔁 DioError (likely network): ${e.type}");
          attempt++;
          if (attempt >= retries) {
            throw FetchDataException("No Internet connection");
          }
          await _waitForInternet(Duration(seconds: 15));
        } else {
          rethrow; // other Dio errors (server 500, 403, etc.)
        }
      } on FetchDataException catch (e) {
        if (e.message == "Error During Communication" &&
            e.details == "No Internet connection") {
          print("📡 No Internet (custom exception), waiting...");
          attempt++;
          if (attempt >= retries) {
            throw FetchDataException("No Internet connection");
          }
          await _waitForInternet(Duration(seconds: 15));
        } else {
          rethrow;
        }
      }
    }

    throw FetchDataException("Retry attempts exceeded");
  }


  Future<void> _waitForInternet(Duration timeout) async {
    final completer = Completer<void>();
    final timer = Timer(timeout, () {
      if (!completer.isCompleted) {
        completer.completeError(TimeoutException("No internet within timeout"));
      }
    });

    final subscription = Connectivity().onConnectivityChanged.listen((result) {
      if (result != ConnectivityResult.none && !completer.isCompleted) {
        completer.complete();
      }
    });

    try {
      await completer.future;
      print("📶 Internet connection restored.");
    } finally {
      await subscription.cancel();
      timer.cancel();
    }

  }

}


class AppException implements Exception {
  final code;
  final message;
  final details;

  AppException({this.code, this.message, this.details});

  String toString() {
    return "[$code]: $message \n $details";
  }
}

class FetchDataException extends AppException {
  FetchDataException(String? details)
      : super(
          code: "fetch-data",
          message: "Error During Communication",
          details: details,
        );
}

class BadRequestException extends AppException {
  BadRequestException(String? details)
      : super(
          code: "invalid-request",
          message: "Invalid Request",
          details: details,
        );
}

class UnauthorisedException extends AppException {
  UnauthorisedException(String? details)
      : super(
          code: "unauthorised",
          message: "Unauthorised",
          details: details,
        );
}

class InvalidInputException extends AppException {
  InvalidInputException(String? details)
      : super(
          code: "invalid-input",
          message: "Invalid Input",
          details: details,
        );
}

class AuthenticationException extends AppException {
  AuthenticationException(String? details)
      : super(
          code: "authentication-failed",
          message: "Authentication Failed",
          details: details,
        );
}

class TimeOutException extends AppException {
  TimeOutException(String? details)
      : super(
          code: "request-timeout",
          message: "Request TimeOut",
          details: details,
        );
}

class ApiResponseBase {
  final bool success;
  final String? message;

  ApiResponseBase({required this.success, this.message});
}
