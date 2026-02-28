import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/core/services/exception_logging_service.dart';
import 'package:herdapp/features/social/feed/providers/feed_type_provider.dart';
import 'package:herdapp/features/user/user_profile/data/models/user_model.dart';

final userSearchRepositoryProvider = Provider<UserSearchRepository>((ref) {
  return UserSearchRepository(FirebaseFirestore.instance);
});

class UserSearchRepository {
  final FirebaseFirestore _firestore;
  final ExceptionLoggerService _logger = ExceptionLoggerService();

  UserSearchRepository(this._firestore);

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  String capitalize(String s) {
    if (s.isEmpty) return '';
    return s[0].toUpperCase() + s.substring(1);
  }

  // Search users
  Future<List<UserModel>> searchUsers(String query,
      {FeedType profileType = FeedType.public}) async {
    if (query.isEmpty) return [];

    // Convert query to lowercase for more flexible search
    final lowerQuery = query.toLowerCase();
    final capitalizedQuery = query.isNotEmpty
        ? query[0].toUpperCase() + query.substring(1).toLowerCase()
        : "";

    // Split query for potential full name search
    final parts = query.trim().split(' ');
    final isFullNameSearch = parts.length > 1;

    final List<Future<QuerySnapshot<Map<String, dynamic>>>> searches = [];

    if (profileType == FeedType.public) {
      // For public feed, search first and last name
      if (isFullNameSearch) {
        // Full name search - combine first and last name conditions
        final firstName = parts[0].toLowerCase();
        final lastName = parts.sublist(1).join(' ').toLowerCase();

        searches.add(_users
            .where('firstName', isEqualTo: firstName)
            .where('lastName', isEqualTo: lastName)
            .limit(10)
            .get());

        // Also try capitalized versions
        searches.add(_users
            .where('firstName', isEqualTo: capitalize(firstName))
            .where('lastName', isEqualTo: capitalize(lastName))
            .limit(10)
            .get());
      } else {
        // Single word search - check first name or last name
        searches.addAll([
          _users
              .where('firstName', isGreaterThanOrEqualTo: lowerQuery)
              .where('firstName', isLessThan: '$lowerQuery\uf8ff')
              .limit(10)
              .get(),
          _users
              .where('firstName', isGreaterThanOrEqualTo: capitalizedQuery)
              .where('firstName', isLessThan: '$capitalizedQuery\uf8ff')
              .limit(10)
              .get(),
          _users
              .where('lastName', isGreaterThanOrEqualTo: lowerQuery)
              .where('lastName', isLessThan: '$lowerQuery\uf8ff')
              .limit(10)
              .get(),
          _users
              .where('lastName', isGreaterThanOrEqualTo: capitalizedQuery)
              .where('lastName', isLessThan: '$capitalizedQuery\uf8ff')
              .limit(10)
              .get(),
        ]);
      }
    } else {
      // For alt feed, only search username
      searches.add(_users
          .where('username', isGreaterThanOrEqualTo: lowerQuery)
          .where('username', isLessThan: '$lowerQuery\uf8ff')
          .limit(10)
          .get());
    }

    // Execute searches and collect results
    final results = await Future.wait(searches);
    final uniqueDocsMap =
        <String, QueryDocumentSnapshot<Map<String, dynamic>>>{};

    for (var querySnapshot in results) {
      for (var doc in querySnapshot.docs) {
        if (!uniqueDocsMap.containsKey(doc.id)) {
          uniqueDocsMap[doc.id] = doc;
        }
      }
    }

    // Convert to UserModels with appropriate filtering
    List<UserModel> users = [];
    for (var doc in uniqueDocsMap.values) {
      final user = UserModel.fromMap(doc.id, doc.data());

      // Filter based on feed type
      if (profileType == FeedType.alt) {
        if (user.username.isEmpty) continue;
      } else {
        if (user.firstName.isEmpty && user.lastName.isEmpty) continue;
      }

      users.add(user);
    }

    return users;
  }

  Future<List<UserModel>> searchAll(
    String query,
  ) async {
    if (query.isEmpty) return [];

    // Convert query to lowercase and capitalized for more flexible search
    final lowerQuery = query.toLowerCase();
    final capitalQuery = query.isNotEmpty
        ? query[0].toUpperCase() + query.substring(1).toLowerCase()
        : "";

    // Determine which fields to search based on profile type
    final List<Future<QuerySnapshot<Map<String, dynamic>>>> searches = [];

    // Only search public profile fields for public feed
    searches.addAll([
      // Search by first name - lowercase
      _users
          .where('firstName', isGreaterThanOrEqualTo: lowerQuery)
          .where('firstName', isLessThan: '$lowerQuery\uf8ff')
          .limit(10)
          .get(),

      // Search by first name - capitalized
      _users
          .where('firstName', isGreaterThanOrEqualTo: capitalQuery)
          .where('firstName', isLessThan: '$capitalQuery\uf8ff')
          .limit(10)
          .get(),

      // Search by last name - lowercase
      _users
          .where('lastName', isGreaterThanOrEqualTo: lowerQuery)
          .where('lastName', isLessThan: '$lowerQuery\uf8ff')
          .limit(10)
          .get(),

      // Search by last name - capitalized
      _users
          .where('lastName', isGreaterThanOrEqualTo: capitalQuery)
          .where('lastName', isLessThan: '$capitalQuery\uf8ff')
          .limit(10)
          .get(),
    ]);
    // Only search alt profile fields for alt feed
    searches.addAll([
      // Search by username ONLY
      _users
          .where('username', isGreaterThanOrEqualTo: lowerQuery)
          .where('username', isLessThan: '$lowerQuery\uf8ff')
          .limit(10)
          .get(),

      // Do NOT search by firstName/lastName/username for alt profiles to maintain anonymity
    ]);

    // Execute all searches in parallel
    final results = await Future.wait(searches);

    // Combine results and remove duplicates
    final uniqueDocsMap =
        <String, QueryDocumentSnapshot<Map<String, dynamic>>>{};

    for (var querySnapshot in results) {
      for (var doc in querySnapshot.docs) {
        if (!uniqueDocsMap.containsKey(doc.id)) {
          uniqueDocsMap[doc.id] = doc;
        }
      }
    }

    // Convert to UserModels but ensure profile type separation
    List<UserModel> users = [];

    for (var doc in uniqueDocsMap.values) {
      final user = UserModel.fromMap(doc.id, doc.data());
      users.add(user);
    }

    return users;
  }

  // Username-specific search that respects profile type
  Future<List<UserModel>> searchByUsername(String username,
      {FeedType profileType = FeedType.public}) async {
    if (username.isEmpty) return [];

    final lowerUsername = username.toLowerCase();

    try {
      QuerySnapshot<Map<String, dynamic>> snapshot;

      // Use different field based on the feed type
      if (profileType == FeedType.alt) {
        snapshot = await _users
            .where('username', isEqualTo: lowerUsername)
            .limit(1)
            .get();
      } else {
        snapshot = await _users
            .where('username', isEqualTo: lowerUsername)
            .limit(1)
            .get();
      }

      return snapshot.docs
          .map((doc) => UserModel.fromMap(doc.id, doc.data()))
          .toList();
    } catch (e, stack) {
      debugPrint('Error searching by username: $e');
      try {
        _logger
            .logException(
          errorMessage: e.toString(),
          stackTrace: stack.toString(),
        )
            .catchError((loggingError) {
          debugPrint('Error logging exception: $loggingError');
          return null;
        });
      } catch (loggingError) {
        debugPrint('Error logging exception: $loggingError');
      }
      return [];
    }
  }

  // Search for users by both first and last name combined (public only)
  Future<List<UserModel>> searchByFullName(String query) async {
    // This handles searching for "first last" combined pattern
    // ONLY for public profiles - not applicable to alt profiles
    if (query.isEmpty) return [];

    final queryParts = query.trim().split(' ');
    if (queryParts.length < 2) {
      // Single word query should use the regular search
      return searchUsers(query, profileType: FeedType.public);
    }

    // Get first name and last name parts for searching
    final firstName = queryParts[0];
    final lastName = queryParts.sublist(1).join(' ');

    // Get all users that match firstName
    final firstNameMatches =
        await searchUsers(firstName, profileType: FeedType.public);

    // Filter to those that also match lastName
    final lowerLastName = lastName.toLowerCase();
    return firstNameMatches
        .where((user) => user.lastName.toLowerCase().contains(lowerLastName))
        .toList();
  }

  // Username availability check
  Future<bool> isUsernameAvailable(String username) async {
    final QuerySnapshot result = await _users
        .where('username', isEqualTo: username.toLowerCase())
        .limit(1)
        .get();

    return result.docs.isEmpty;
  }

  // Get user by username
  Future<UserModel?> getUserByUsername(String username) async {
    final query = await _users
        .where('username', isEqualTo: username.toLowerCase())
        .limit(1)
        .get();

    if (query.docs.isEmpty) return null;
    final doc = query.docs.first;
    return UserModel.fromMap(doc.id, doc.data());
  }
}
