import 'package:capture_campus/features/auth/data/user_model.dart';

abstract class UserRepo {
  Future<bool> singin(UserModel userData);
  Future<bool> login(String email, String passcode);
}
