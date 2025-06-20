import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  final bool isLoggedIn;
  final String? userName;
  final VoidCallback onLogout;

  const AppDrawer({
    super.key,
    required this.isLoggedIn,
    this.userName,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text(isLoggedIn ? userName ?? '' : 'Misafir Kullanıcı'),
            accountEmail: Text(isLoggedIn ? 'Hoş geldiniz!' : 'Giriş yapın'),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                isLoggedIn ? (userName?.isNotEmpty == true ? userName![0].toUpperCase() : 'U') : 'M',
                style: const TextStyle(fontSize: 40.0),
              ),
            ),
            decoration: const BoxDecoration(
              color: Colors.blue,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Ana Sayfa'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          if (isLoggedIn) ...[
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profilim'),
              onTap: () {
                Navigator.pop(context);
                // Profile sayfasına yönlendirme yapılabilir
              },
            ),
            ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text('Çıkış Yap'),
              onTap: () {
                onLogout();
                Navigator.pop(context);
              },
            ),
          ],
        ],
      ),
    );
  }
}
