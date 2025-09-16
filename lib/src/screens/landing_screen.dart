import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../widgets/menu_widget.dart';
import '../widgets/home_screen_home_widget.dart';
import 'settings_screen.dart';
import '../utils/web_api_brain.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';
import '../utils/app_state.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  WebApi webApi = WebApi();

  @override
  void initState() {
    webApi.getLockList(context);
    super.initState();
  }

  int _selectedIndex = 0;
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isLoading = Provider.of<AppState>(context).spinner;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
              onPressed: () {
                print('Checked Notifications');
              },
              icon: const Icon(
                Icons.notifications_none_outlined,
                color: Colors.white,
              ),
            ),
          ],
          toolbarHeight: 90,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue, Colors.lightBlueAccent],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
          ),
          leading: Builder(
            builder:
                (context) => IconButton(
                  icon: const Icon(Icons.menu, color: Colors.white),
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                ),
          ),
          title: SvgPicture.asset(
            'images/gnb_new_logo_.svg',
            color: Colors.white,
            height: 50,
          ),
          centerTitle: true,
        ),
        drawer: const MenuWidget(),
        body: ModalProgressHUD(
          inAsyncCall: isLoading,
          child:
              _selectedIndex == 0
                  ? const HomeScreenHomeWidget()
                  : SettingsScreen(),
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
              backgroundColor: Colors.blue,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
              backgroundColor: Colors.blue,
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.white,
          onTap: _onItemTapped,
          backgroundColor: Colors.blue,
        ),
      ),
    );
  }
}
