import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_core/firebase_core.dart';

class FirebaseFunctionsService {
  const FirebaseFunctionsService();

  bool get _isReady {
    try {
      Firebase.app();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<Map<String, dynamic>> call(
    String name,
    Map<String, dynamic> data, {
    Duration timeout = const Duration(seconds: 30),
  }) async {
    if (!_isReady) throw Exception('Firebase not initialized');

    final callable =
        FirebaseFunctions.instanceFor(region: 'us-central1').httpsCallable(
      name,
      options: HttpsCallableOptions(timeout: timeout),
    );
    final result = await callable.call<Map<Object?, Object?>>(data);
    return _normalize(result.data) as Map<String, dynamic>;
  }

  dynamic _normalize(dynamic value) {
    if (value is Map) {
      return value.map<String, dynamic>(
        (key, child) => MapEntry(key.toString(), _normalize(child)),
      );
    }
    if (value is List) {
      return value.map(_normalize).toList();
    }
    return value;
  }
}
