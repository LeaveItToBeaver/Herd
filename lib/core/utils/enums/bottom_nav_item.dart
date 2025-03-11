import 'package:flutter/material.dart';

enum BottomNavItem {
  privateFeed,
  create,
  publicFeed,
}

final bottomNavItems = [
  BottomNavItem.privateFeed,
  BottomNavItem.create,
  BottomNavItem.publicFeed,
];

final bottomNavIcons = {
  BottomNavItem.privateFeed: Icons.home_filled,
  BottomNavItem.create: Icons.add,
  BottomNavItem.publicFeed: Icons.home,
};

final bottomNavRoutes = {
  BottomNavItem.privateFeed: 'privateFeed',
  BottomNavItem.create: 'create',
  BottomNavItem.publicFeed: 'publicFeed',
};