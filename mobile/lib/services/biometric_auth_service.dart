import 'package:local_auth/local_auth.dart';

class BiometricAuthService {
  BiometricAuthService({LocalAuthentication? localAuthentication})
    : _localAuthentication = localAuthentication ?? LocalAuthentication();

  final LocalAuthentication _localAuthentication;

  Future<bool> canUseBiometrics() async {
    final bool deviceSupported = await _localAuthentication.isDeviceSupported();
    final bool canCheckBiometrics =
        await _localAuthentication.canCheckBiometrics;

    return deviceSupported && canCheckBiometrics;
  }

  Future<bool> authenticate({required String reason}) async {
    final bool canAuthenticate = await canUseBiometrics();

    if (!canAuthenticate) {
      return false;
    }

    return _localAuthentication.authenticate(
      localizedReason: reason,
      options: const AuthenticationOptions(
        biometricOnly: true,
        stickyAuth: true,
      ),
    );
  }
}
