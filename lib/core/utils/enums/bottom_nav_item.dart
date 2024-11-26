import 'package:flutter/material.dart';

enum BottomNavItem {
  search,
  privateFeed,
  create,
  publicFeed,
  profile,
}

final bottomNavItems = [
  BottomNavItem.search,
  BottomNavItem.privateFeed,
  BottomNavItem.create,
  BottomNavItem.publicFeed,
  BottomNavItem.profile,
];

final bottomNavIcons = {
  BottomNavItem.search: Icons.search,
  BottomNavItem.privateFeed: Icons.home_filled,
  BottomNavItem.create: Icons.add,
  BottomNavItem.publicFeed: Icons.home,
  BottomNavItem.profile: Icons.person,
};

final bottomNavRoutes = {
  BottomNavItem.search: 'search',
  BottomNavItem.privateFeed: 'privateFeed',
  BottomNavItem.create: 'create',
  BottomNavItem.publicFeed: 'publicFeed',
  BottomNavItem.profile: 'profile',
};