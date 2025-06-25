import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:n61/m/product_model.dart';
import 'package:n61/services/responsive.dart';
import 'package:n61/services/varibles.dart';
import 'package:n61/v/chat_page.dart';
import 'package:n61/v/product_detail.dart';
import 'package:n61/v/screens/login_screen.dart';
import 'package:n61/v/widgets/app_drawer.dart';
import 'package:n61/viewmodel/user_view_model.dart';
import 'package:provider/provider.dart';
import 'package:n61/v/screens/edit_profile_screen.dart';
import 'package:n61/services/chat_api.dart';

// ▲ YENİ: FakeStoreAPI ürün servisi ve model
import 'package:n61/viewmodel/product_service.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // ▲ YENİ: servis ve veriler
  final ProductService _productService = ProductService();
  late Future<List<Product>> _womenProducts;
  late Future<List<Product>> _menProducts;

  // Chat için ürün listelerini sakla
  List<Product> _allProducts = [];

  @override
  void initState() {
    super.initState();
    _womenProducts = _loadProducts('women');
    _menProducts = _loadProducts('men');
    _loadAllProducts();
  }

  Future<void> _loadAllProducts() async {
    try {
      final women = await _womenProducts;
      final men = await _menProducts;
      _allProducts = [...women, ...men];
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('Ürünler yüklenirken hata: $e');
    }
  }

  Future<List<Product>> _loadProducts(String genderKeyword) async {
    // FakeStoreAPI'den tüm ürünleri çek - maksimum 20 ürün mevcut
    final all = await _productService.fetch(limit: 20);

    // FakeStoreAPI kategorileri: electronics, jewelery, men's clothing, women's clothing
    String categoryFilter = genderKeyword == 'women' ? "women's clothing" : "men's clothing";
    final filtered = all.where((p) => p.category.toLowerCase().contains(categoryFilter.toLowerCase())).toList();

    // Eğer yeterli ürün yoksa, diğer kategorilerden de ürün ekle
    if (filtered.length < 6) {
      final remaining = all.where((p) => !filtered.contains(p)).take(6 - filtered.length);
      filtered.addAll(remaining);
    }

    return filtered.take(12).toList();
  }

  @override
  void dispose() {
    _productService.close();
    super.dispose();
  }

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
              // … GİRİŞ / PROFİL menüsü (değişmedi)
              if (userViewModel.isLoggedIn)
                PopupMenuButton<String>(
                  onSelected: (value) async {
                    if (value == 'logout') {
                      await userViewModel.logout();
                    } else if (value == 'profile') {
                      _showProfileDialog(context, userViewModel);
                    }
                  },
                  itemBuilder: (context) => [
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
                        Text('Giriş', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                        Icon(Icons.chevron_right, color: Colors.orange),
                      ],
                    ),
                  ),
                ),
            ],
            leading: IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => _scaffoldKey.currentState?.openDrawer(),
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
              children: [
                // ————————— Kampanyalar (değişmedi) —————————
                SizedBox(
                  height: ResponsiveSize.getWidth(context, 30),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 5,
                    itemBuilder: (context, index) => _campaignCard(index),
                  ),
                ),

                // ————————— Kategoriler (değişmedi) —————————
                _CategoryQuickRow(),

                // ---------- Kadın Giyim (yeni ürün datası) ----------
                const _SectionTitle(title: 'Kadın Giyim'),
                _ProductHorizontalList(future: _womenProducts),

                // ---------- Erkek Giyim (yeni ürün datası) ----------
                const _SectionTitle(title: 'Erkek Giyim'),
                _ProductHorizontalList(future: _menProducts),

                SizedBox(height: navigationHeight),
              ],
            ),
          ),
          floatingActionButton: Padding(
            padding: EdgeInsets.only(bottom: navigationHeight - 30),
            child: FloatingActionButton(
              onPressed: () {
                // Anasayfa context'ini oluştur
                final homeContext = PageContext(
                  pageType: 'home',
                  pageTitle: 'N61 Anasayfa',
                  currentProducts: _allProducts,
                );

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChatPage(pageContext: homeContext),
                  ),
                );
              },
              child: const Icon(Icons.message),
            ),
          ),
        );
      },
    );
  }

  // --------------------------------- küçük bileşenler ---------------------------------
  Widget _campaignCard(int index) => Container(
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
            const Text('Kampanya', maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      );

  void _showProfileDialog(BuildContext context, UserViewModel vm) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Kullanıcı Bilgileri'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Ad Soyad'),
              subtitle: Text(vm.userName ?? ''),
            ),
            ListTile(
              leading: const Icon(Icons.email),
              title: const Text('E‑posta'),
              subtitle: Text(vm.currentUser?['email'] ?? ''),
            ),
            ListTile(
              leading: const Icon(Icons.phone),
              title: const Text('Telefon'),
              subtitle: Text(vm.userPhone ?? ''),
            ),
            ListTile(
              leading: const Icon(Icons.location_on),
              title: const Text('Adres'),
              subtitle: Text(vm.userAddress ?? ''),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () async {
              final navigator = Navigator.of(context);
              final confirm = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Hesabı Sil'),
                  content: const Text('Hesabınızı silmek istediğinize emin misiniz?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('İptal'),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Sil'),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                final success = await vm.deleteAccount();
                if (!mounted) return;
                if (success) {
                  navigator.pop();
                }
              }
            },
            child: const Text('Hesabı Sil'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen()));
            },
            child: const Text('Düzenle'),
          ),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────────
//  Bölüm başlığı
class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});
  final String title;
  @override
  Widget build(BuildContext context) => Row(
        children: [
          const SizedBox(width: 24.0),
          Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const Spacer(),
        ],
      );
}

//  Ürünleri yatay listeleyen widget
class _ProductHorizontalList extends StatelessWidget {
  const _ProductHorizontalList({required this.future});
  final Future<List<Product>> future;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Product>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Hata: ${snapshot.error?.toString() ?? "Bilinmeyen hata"}'),
          );
        }
        final products = snapshot.data ?? [];
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: products
                .map((p) => OpenContainer(
                      transitionType: ContainerTransitionType.fade,
                      transitionDuration: const Duration(milliseconds: 500),
                      closedColor: Colors.grey[100]!,
                      openColor: Colors.grey[100]!,
                      openBuilder: (_, __) => ProductDetail(product: p),
                      closedBuilder: (_, __) => _ProductCard(product: p),
                    ))
                .toList(),
          ),
        );
      },
    );
  }
}

//  Tekil ürün kartı — TASARIM DEĞİŞMEDEN
class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product});
  final Product product;

  @override
  Widget build(BuildContext context) {
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
              child: Image.network(
                product.thumbnail,
                height: ResponsiveSize.getWidth(context, 50),
                width: ResponsiveSize.getWidth(context, 30),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              product.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              '\$${product.price.toStringAsFixed(2)}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

//  Kategori kısayolları (tasarım korunarak fonksiyon eklenmedi)
class _CategoryQuickRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _quickCard(icon: Icons.category, label: 'Kategoriler'),
          _quickCard(icon: Icons.shopping_cart, label: 'Ürünler'),
          _quickCard(icon: Icons.shopping_bag, label: 'Siparişler'),
        ],
      ),
    );
  }

  Widget _quickCard({required IconData icon, required String label}) => Card(
        child: SizedBox(
          width: 120,
          height: 80,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Icon(icon), Text(label)],
          ),
        ),
      );
}
