import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:running_mate/provider/running_status_provider.dart';
import 'package:running_mate/screens/home/home_view.dart';
import 'package:running_mate/screens/running/run_view.dart';
import 'package:running_mate/screens/running/running_view.dart';
import 'package:running_mate/screens/tracks/my_tracks_view.dart';
import 'package:running_mate/screens/SNS/sns_view.dart';
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
    const SnsView(),
  ];

  void _onItemTapped(int index) {
    final isRunning =
        Provider.of<RunningStatusProvider>(context, listen: false).isRunning;

    if (index == 2 && isRunning) {
      // 런닝 상태일 때 RunningView로 이동
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const RunningView()),
      );
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();

    // 로그아웃 시 로그인 화면으로 리다이렉트
    if (!authViewModel.isLoggedIn) {
      Future.microtask(() => Navigator.pushReplacementNamed(context, '/login'));
    }

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
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
            icon: Icon(Icons.directions_run),
            label: 'Run',
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
