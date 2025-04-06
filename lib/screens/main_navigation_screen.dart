import 'package:flutter/material.dart';
import 'package:parking_app_flutter/models/person.dart';
import 'package:parking_app_flutter/screens/user_screen.dart';
import 'package:parking_app_flutter/screens/vehicles_screen.dart';
import 'package:parking_app_flutter/screens/parking_spaces_screen.dart';
import 'package:parking_app_flutter/screens/parkings_screen.dart';
import 'package:parking_app_flutter/services/user_service.dart';

class MainNavigationScreen extends StatefulWidget {
  final Person user;
  
  const MainNavigationScreen({Key? key, required this.user}) : super(key: key);

  @override
  _MainNavigationScreenState createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _screens;
  
  @override
  void initState() {
    super.initState();
    
    // Make sure UserService has the current user
    UserService().setCurrentUser(widget.user);
    
    _screens = [
      const VehiclesScreen(),
      const ParkingSpacesScreen(),
      const ParkingsScreen(),
      UserScreen(user: widget.user), 
    ];
  }

  final List<String> _titles = [
    'Fordon',
    'Parkeringsplatser',
    'Parkeringar',
    'Användare',
  ];

  final List<IconData> _icons = [
    Icons.directions_car,
    Icons.local_parking,
    Icons.access_time,
    Icons.person,
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        backgroundColor: Color(0xFF0078D7),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              // Log out and navigate back to welcome screen
              Navigator.pushReplacementNamed(context, '/');
            },
            tooltip: 'Logga ut',
          ),
        ],
      ),
      body: Row(
        children: [
          if (isLargeScreen)
            NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: _onItemTapped,
              labelType: NavigationRailLabelType.selected,
              backgroundColor: Color(0xFFF0F8FF), // Light azure
              selectedIconTheme: IconThemeData(color: Color(0xFF0078D7)),
              selectedLabelTextStyle: TextStyle(color: Color(0xFF0078D7)),
              destinations: List.generate(
                _titles.length,
                (index) => NavigationRailDestination(
                  icon: Icon(_icons[index]),
                  label: Text(_titles[index]),
                ),
              ),
            ),
          Expanded(
            child: _screens[_selectedIndex],
          ),
        ],
      ),
      bottomNavigationBar: isLargeScreen
          ? null
          : BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
              type: BottomNavigationBarType.fixed,
              selectedItemColor: Color(0xFF0078D7),
              unselectedItemColor: Colors.grey,
              items: List.generate(
                _titles.length,
                (index) => BottomNavigationBarItem(
                  icon: Icon(_icons[index]),
                  label: _titles[index],
                ),
              ),
            ),
    );
  }
}