import 'package:flutter/material.dart';

enum BottomNavItem {
  altFeed,
  create,
  publicFeed,
}

final bottomNavItems = [
  BottomNavItem.altFeed,
  BottomNavItem.create,
  BottomNavItem.publicFeed,
];

final bottomNavIcons = {
  BottomNavItem.altFeed: Icons.home_filled,
  BottomNavItem.create: Icons.add,
  BottomNavItem.publicFeed: Icons.home,
};

final bottomNavRoutes = {
  BottomNavItem.altFeed: 'altFeed',
  BottomNavItem.create: 'create',
  BottomNavItem.publicFeed: 'publicFeed',
};