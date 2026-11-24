import 'package:get/get.dart';
import '../models/user_model.dart';
import '../screens/login_screen.dart';
import '../screens/main_screen.dart';
import '../services/local_db_service.dart';

class AuthController extends GetxController {
  final RxBool isLoggedIn = false.obs;
  final RxBool isLoading = false.obs;
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    checkSession();
  }

  Future<void> checkSession() async {
    final user = await LocalDbService.getCurrentUserSession();
    if (user != null) {
      currentUser.value = user;
      isLoggedIn.value = true;
    } else {
      isLoggedIn.value = false;
      currentUser.value = null;
    }
  }

  Future<bool> login(String email, String password) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final user = await LocalDbService.login(email: email, password: password);
      currentUser.value = user;
      isLoggedIn.value = true;

      Get.offAll(() => const MainScreen());
      return true;
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final user = await LocalDbService.register(name: name, email: email, password: password);
      currentUser.value = user;
      isLoggedIn.value = true;

      Get.offAll(() => const MainScreen());
      return true;
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    await LocalDbService.logout();
    isLoggedIn.value = false;
    currentUser.value = null;

    Get.offAll(() => const LoginScreen());
  }
}
