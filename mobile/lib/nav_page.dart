import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:running_mate/screens/home/home_view.dart';
import 'package:running_mate/screens/running/run_view.dart';
import 'package:running_mate/screens/tracks/my_tracks_view.dart';
import 'package:running_mate/screens/SNS/shared_routes_page.dart';
import 'package:running_mate/viewmodels/auth_view_model.dart';

class NavPage extends StatefulWidget {
  const NavPage({super.key});

  @override
  _NavPageState createState() => _NavPageState();
}

class _NavPageState extends State<NavPage> {
  int _selectedIndex = 0;

  static final List<Widget> _pages = <Widget>[
    HomeView(),
    const MyTracksView(),
    const RunView(),
    const SharedRoutesPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();

    // 로그아웃 시 로그인 화면으로 리다이렉트
    if (!authViewModel.isLoggedIn) {
      Future.microtask(() => Navigator.pushReplacementNamed(context, '/login'));
    }

    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // Fixed type으로 설정
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Tracks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'SNS',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}
