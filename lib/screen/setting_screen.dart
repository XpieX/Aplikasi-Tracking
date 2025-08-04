import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:tracking_app/screen/login_screen.dart';
import 'package:tracking_app/service/api_service.dart';
import 'package:tracking_app/service/auth_service.dart';
import 'package:tracking_app/utils/appcolor.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  bool isloading = false;
  final api = APIService();
  String? username;
  String? email;
  String? foto;
  String? status;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  void _logout() async {
    try {
      await api.logoutFromBackend();
      await AuthService.logout();
      if (!mounted) return;
      Navigator.of(
        context,
        rootNavigator: true,
      ).push(MaterialPageRoute(builder: (_) => const LoginScreen()));
    } catch (e) {
      final message =
          e.toString().contains('timeout')
              ? 'Timeout Lebih dari 10 detik'
              : e.toString();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> loadUserData() async {
    final user = await AuthService.getUserData();

    String? fotoUrl;
    if (user != null && user['id'] != null) {
      fotoUrl = await api.getFotoProfil(user['id']);
    }

    setState(() {
      username = user?['username'];
      email = user?['email'];
      foto = fotoUrl;
    });
  }

  Future<void> _confirmLogout() async {
    AwesomeDialog(
      context: context,
      title: "Logout",
      desc: "Apakah anda yakin untuk Logout?",
      dialogType: DialogType.noHeader,
      width: 400,
      dialogBackgroundColor: AppColor.backgroundColorPrimary,
      headerAnimationLoop: false,
      dismissOnBackKeyPress: false,
      dismissOnTouchOutside: false,
      btnOkText: "Logout",
      btnOkOnPress: () {
        _logout();
      },
      btnCancelOnPress: () {},
    ).show();
  }

  Widget _statusIcon(String? status) {
    switch (status) {
      case '0':
        return const Icon(Icons.close, color: Colors.red);
      case '1':
        return const Icon(Icons.check, color: Colors.green);
      default:
        return const Icon(Icons.help_outline);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Stack(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blue,
                      ),
                      child: ClipOval(
                        child: SizedBox.fromSize(
                          size: const Size.fromRadius(60),
                          child:
                              (foto != null && foto!.isNotEmpty)
                                  ? Image.network(foto!, fit: BoxFit.cover)
                                  : Image.asset(
                                    "assets/images/user_image.png",
                                    fit: BoxFit.cover,
                                  ),
                        ),
                      ),
                    ),
                    const Gap(12),
                    Text(
                      username ?? "Tidak Diketahui",
                      style: const TextStyle(fontSize: 18),
                    ),
                    Text(
                      email ?? "Tidak Diketahui",
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const Gap(12),
                    const Divider(thickness: 1),
                    ListTile(
                      leading: const Icon(Icons.person),
                      title: const Text("Profil"),
                      trailing: _statusIcon(status),
                      onTap: () {},
                    ),
                    const Divider(thickness: 1),
                    ListTile(
                      leading: const Icon(Icons.logout),
                      title: const Text("Logout"),
                      onTap: _confirmLogout,
                    ),
                    const Divider(thickness: 1),
                  ],
                ),
                if (isloading)
                  Center(
                    child: LoadingAnimationWidget.staggeredDotsWave(
                      color: Colors.blue,
                      size: 40,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
