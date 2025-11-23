import 'package:capture_campus/features/home/presentation/widgets/account_screen.dart';
import 'package:capture_campus/features/home/presentation/bloc/home_bloc.dart';
import 'package:capture_campus/features/home/presentation/bloc/home_event.dart';
import 'package:capture_campus/features/home/presentation/widgets/home_tab.dart';
import 'package:capture_campus/features/home/presentation/widgets/save_screen.dart';
import 'package:capture_campus/features/home/presentation/widgets/search_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Widget> pages = [
    HomeTab(),

    SearchScreen(),
    SaveScreen(),
    AccountScreen(),
  ];
  int selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => HomeBloc(),
        child: pages[selectedIndex],
      ),
      bottomNavigationBar: Builder(
        builder: (context) {
          return BottomNavigationBar(
            iconSize: 34,
            selectedItemColor: Colors.amberAccent,
            elevation: 7,
            currentIndex: selectedIndex,
            onTap: (index) {
              setState(() {
                selectedIndex = index;
              });
            },
            type: BottomNavigationBarType.fixed,
            items: [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'home'),
              BottomNavigationBarItem(
                icon: Icon(Icons.search),
                label: 'search',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.favorite_border),
                label: 'Save',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Account',
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.grey,
        onPressed: () {},
        child: Icon(Icons.camera, color: Colors.amber, size: 35),
      ),
    );
  }
}
