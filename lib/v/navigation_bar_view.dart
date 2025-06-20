import 'package:flutter/material.dart';
import 'package:n61/services/responsive.dart';
import 'package:n61/services/varibles.dart';
import 'package:n61/v/home.dart';

class NavigationBarView extends StatefulWidget {
  const NavigationBarView({super.key});

  @override
  State<NavigationBarView> createState() => _NavigationBarViewState();
}

class _NavigationBarViewState extends State<NavigationBarView> {
  int _selectedIndex = 0;

  String myinsuranceData = '';

  static final List<Widget> _pages = <Widget>[
    const Home(),
    const Placeholder(),
    const Placeholder(),
    const Placeholder(),
  ];

  void _onItemTapped(int index, {String? data}) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // @override
  // void initState() {
  //   super.initState();
  //   Provider.of<PolicyViewModel>(context, listen: false).fetchPolicies();
  //   Provider.of<InsuranceagentViewmodel>(context, listen: false).fetchInsuranceAgents();
  //   Provider.of<CustomerViewModel>(context, listen: false).fetchCustomer();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _pages[_selectedIndex],
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: navigationHeight,
              padding: (() {
                if (navigationHeight == 50) {
                  return const EdgeInsets.only(top: 0);
                } else {
                  return const EdgeInsets.only(bottom: 30);
                }
              }()),
              color: const Color.fromRGBO(255, 255, 255, 1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: (() {
                  if (navigationHeight == 50) {
                    return CrossAxisAlignment.center;
                  } else {
                    return CrossAxisAlignment.start;
                  }
                }()),
                children: [
                  Expanded(flex: 1, child: Container()),
                  Expanded(
                    flex: 4,
                    child: InkWell(
                      onTap: () => _onItemTapped(0, data: ''),
                      child: Padding(
                        padding: const EdgeInsets.all(12.5),
                        child: SizedBox(
                          width: ResponsiveSize.getWidth(context, 50),
                          height: ResponsiveSize.getHeight(context, 50),
                          child: Icon(
                            Icons.home,
                            color: _selectedIndex == 0 ? Colors.black : Colors.grey[500],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: InkWell(
                      onTap: () => _onItemTapped(2, data: ''),
                      child: Padding(
                        padding: const EdgeInsets.all(12.5),
                        child: SizedBox(
                          width: ResponsiveSize.getWidth(context, 50),
                          height: ResponsiveSize.getHeight(context, 50),
                          // child: const Icon(Icons.add),
                          child: Icon(
                            Icons.favorite,
                            color: _selectedIndex == 2 ? Colors.black : Colors.grey[500],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: InkWell(
                      onTap: () => _onItemTapped(1, data: ''),
                      child: Padding(
                        padding: const EdgeInsets.all(12.5),
                        child: SizedBox(
                          width: ResponsiveSize.getWidth(context, 50),
                          height: ResponsiveSize.getHeight(context, 50),
                          child: Icon(
                            Icons.shopping_basket,
                            color: _selectedIndex == 1 ? Colors.black : Colors.grey[500],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: InkWell(
                      onTap: () => _onItemTapped(3, data: ''),
                      child: Padding(
                        padding: const EdgeInsets.all(12.5),
                        child: SizedBox(
                          width: ResponsiveSize.getWidth(context, 50),
                          height: ResponsiveSize.getHeight(context, 50),
                          child: Icon(
                            Icons.person,
                            color: _selectedIndex == 3 ? Colors.black : Colors.grey[500],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(flex: 1, child: Container()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void navigateToPage(int index, {required String data}) {
    _onItemTapped(index, data: data);
  }
}
