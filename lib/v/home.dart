import 'dart:math';
import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:n61/services/responsive.dart';
import 'package:n61/services/varibles.dart';
import 'package:n61/v/chat_page.dart';
import 'package:n61/v/product_detail.dart';
import 'package:n61/v/screens/login_screen.dart';
import 'package:n61/v/widgets/app_drawer.dart';
import 'package:n61/viewmodel/user_view_model.dart';
import 'package:provider/provider.dart';
import 'package:n61/v/screens/edit_profile_screen.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Consumer<UserViewModel>(
      builder: (context, userViewModel, child) {
        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: Colors.grey[100],
          appBar: AppBar(
            title: const Text('N61'),
            actions: [
              if (userViewModel.isLoggedIn)
                PopupMenuButton<String>(
                  onSelected: (value) async {
                    if (value == 'logout') {
                      await userViewModel.logout();
                    } else if (value == 'profile') {
                      // Kullanıcı detaylarını gösteren dialog
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Kullanıcı Bilgileri'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ListTile(
                                leading: Icon(Icons.person),
                                title: Text('Ad Soyad'),
                                subtitle: Text(userViewModel.userName ?? ''),
                              ),
                              ListTile(
                                leading: Icon(Icons.email),
                                title: Text('E-posta'),
                                subtitle: Text(userViewModel.currentUser?['email'] ?? ''),
                              ),
                              ListTile(
                                leading: Icon(Icons.phone),
                                title: Text('Telefon'),
                                subtitle: Text(userViewModel.userPhone ?? ''),
                              ),
                              ListTile(
                                leading: Icon(Icons.location_on),
                                title: Text('Adres'),
                                subtitle: Text(userViewModel.userAddress ?? ''),
                              ),
                              // ListTile(
                              //   leading: Icon(Icons.calendar_today),
                              //   title: Text('Kayıt Tarihi'),
                              //   subtitle: Text(
                              //     DateTime.parse(
                              //       userViewModel.currentUser?['createdAt'] ?? '',
                              //     ).toLocal().toString().split('.')[0],
                              //   ),
                              // ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text('Kapat'),
                            ),
                            TextButton(
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.red,
                              ),
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text('Hesabı Sil'),
                                    content: Text('Hesabınızı silmek istediğinize emin misiniz?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, false),
                                        child: Text('İptal'),
                                      ),
                                      TextButton(
                                        style: TextButton.styleFrom(
                                          foregroundColor: Colors.red,
                                        ),
                                        onPressed: () => Navigator.pop(context, true),
                                        child: Text('Sil'),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirm == true) {
                                  await userViewModel.deleteAccount();
                                  if (mounted) {
                                    Navigator.pop(context); // Profil dialogunu kapat
                                  }
                                }
                              },
                              child: Text('Hesabı Sil'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context); // Dialog'u kapat
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const EditProfileScreen(),
                                  ),
                                );
                              },
                              child: Text('Düzenle'),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                  itemBuilder: (BuildContext context) => [
                    PopupMenuItem(
                      value: 'profile',
                      child: Row(
                        children: [
                          Icon(Icons.person, color: Theme.of(context).iconTheme.color),
                          const SizedBox(width: 8),
                          Text('Merhaba, ${userViewModel.userName}'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'logout',
                      child: Row(
                        children: [
                          Icon(Icons.exit_to_app, color: Theme.of(context).iconTheme.color),
                          const SizedBox(width: 8),
                          const Text('Çıkış Yap'),
                        ],
                      ),
                    ),
                  ],
                )
              else
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                    );
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Giriş',
                          style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                        ),
                        Icon(Icons.chevron_right, color: Colors.orange),
                      ],
                    ),
                  ),
                ),
            ],
            leading: IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                _scaffoldKey.currentState?.openDrawer();
              },
            ),
          ),
          drawer: AppDrawer(
            isLoggedIn: userViewModel.isLoggedIn,
            userName: userViewModel.userName,
            onLogout: () => userViewModel.logout(),
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Kampanyalar kısmı
                SizedBox(
                  height: ResponsiveSize.getWidth(context, 30),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 5,
                    itemBuilder: (context, index) {
                      return Container(
                        width: ResponsiveSize.getWidth(context, 18),
                        margin: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(ResponsiveSize.getWidth(context, 11.5)),
                              child: Image.asset(
                                'assets/campaigns/${(index % 5) + 1}.webp',
                                height: ResponsiveSize.getWidth(context, 18),
                                width: ResponsiveSize.getWidth(context, 18),
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            const Text(
                              'Kampanya',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                // Kategoriler kısmı
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Card(
                        child: SizedBox(
                          width: ResponsiveSize.getWidth(context, 40),
                          height: ResponsiveSize.getWidth(context, 10),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.category),
                              Text('Kategoriler'),
                            ],
                          ),
                        ),
                      ),
                      Card(
                        child: SizedBox(
                          width: ResponsiveSize.getWidth(context, 40),
                          height: ResponsiveSize.getWidth(context, 10),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.shopping_cart),
                              Text('Ürünler'),
                            ],
                          ),
                        ),
                      ),
                      Card(
                        child: SizedBox(
                          width: ResponsiveSize.getWidth(context, 40),
                          height: ResponsiveSize.getWidth(context, 10),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.shopping_bag),
                              Text('Siparişler'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Kadın Giyim
                const Row(
                  children: [
                    SizedBox(width: 24.0),
                    Text('Kadın Giyim', style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold)),
                    Spacer(),
                  ],
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      for (int i = 0; i < 12; i++)
                        OpenContainer(
                          transitionType: ContainerTransitionType.fade,
                          transitionDuration: const Duration(milliseconds: 500),
                          closedColor: Colors.grey[100]!,
                          openColor: Colors.grey[100]!,
                          openBuilder: (context, _) {
                            return const ProductDetail();
                          },
                          closedBuilder: (context, _) {
                            return Card(
                              elevation: 0.0,
                              child: SizedBox(
                                width: ResponsiveSize.getWidth(context, 40),
                                height: ResponsiveSize.getWidth(context, 70),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8.0),
                                      child: Image.asset(
                                        'assets/women_products/(${(i % 13) + 1}).webp',
                                        height: ResponsiveSize.getWidth(context, 50),
                                        width: ResponsiveSize.getWidth(context, 30),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    const SizedBox(height: 8.0),
                                    Text(
                                      (() {
                                        final randomNames = [
                                          'Örgü Midi Elbise',
                                          'Dar Kesim Elbise',
                                          'Asimetrik Yakalı Elbise',
                                          'İpekyol Elbise',
                                          'Miss İpekyol Elbise',
                                          'Saten Basic Elbise',
                                          'Ajurlu Elbise',
                                          'Kruvaze Elbise',
                                          'Kemerli Elbise',
                                          'Kemer Detaylı Elbise',
                                          'Triko Mix Elbise',
                                          'Kadife Elbise',
                                        ];
                                        return randomNames[i];
                                      }()),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      (() {
                                        final random = Random();
                                        final randomPrices = List.generate(12, (_) => '${1000 + random.nextInt(2001)}.99 TL');
                                        return randomPrices[i];
                                      }()),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
                // Erkek Giyim
                const Row(
                  children: [
                    SizedBox(width: 24.0),
                    Text('Erkek Giyim', style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold)),
                    Spacer(),
                  ],
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      for (int i = 0; i < 12; i++)
                        InkWell(
                          onTap: () {},
                          child: Card(
                            child: SizedBox(
                              width: ResponsiveSize.getWidth(context, 40),
                              height: ResponsiveSize.getWidth(context, 70),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: Image.asset(
                                      'assets/men_products/(${(i % 13) + 1}).webp',
                                      height: ResponsiveSize.getWidth(context, 50),
                                      width: ResponsiveSize.getWidth(context, 30),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(height: 8.0),
                                  Text(
                                    (() {
                                      final randomNames = [
                                        'Örgü Midi Elbise',
                                        'Dar Kesim Elbise',
                                        'Asimetrik Yakalı Elbise',
                                        'İpekyol Elbise',
                                        'Miss İpekyol Elbise',
                                        'Saten Basic Elbise',
                                        'Ajurlu Elbise',
                                        'Kruvaze Elbise',
                                        'Kemerli Elbise',
                                        'Kemer Detaylı Elbise',
                                        'Triko Mix Elbise',
                                        'Kadife Elbise',
                                      ];
                                      return randomNames[i];
                                    }()),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    (() {
                                      final random = Random();
                                      final randomPrices = List.generate(12, (_) => '${1000 + random.nextInt(2001)}.99 TL');
                                      return randomPrices[i];
                                    }()),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(height: navigationHeight),
              ],
            ),
          ),
          floatingActionButton: Padding(
            padding: EdgeInsets.only(bottom: navigationHeight - 30),
            child: FloatingActionButton(
              onPressed: () {
                // _openChatScreen(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ChatPage()));
              },
              child: const Icon(Icons.message),
            ),
          ),
        );
      },
    );
  }
}
