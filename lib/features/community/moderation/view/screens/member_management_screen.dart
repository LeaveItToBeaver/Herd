import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/features/community/moderation/view/widgets/batch_action_sheet_widget.dart';
import 'package:herdapp/features/community/moderation/view/widgets/member_action_sheet_widget.dart';
import 'package:herdapp/features/community/moderation/view/widgets/member_tile_widget.dart';
import 'package:herdapp/features/community/moderation/view/providers/role_providers.dart';
import 'package:herdapp/features/community/moderation/data/models/herd_role.dart';
import '../../../herds/data/models/herd_member_info.dart';
import '../../../herds/view/providers/herd_providers.dart';
import '../../../../user/auth/view/providers/auth_provider.dart';

class MemberManagementScreen extends ConsumerStatefulWidget {
  final String herdId;

  const MemberManagementScreen({
    super.key,
    required this.herdId,
  });

  @override
  ConsumerState<MemberManagementScreen> createState() =>
      _MemberManagementScreenState();
}

class _MemberManagementScreenState
    extends ConsumerState<MemberManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final Set<String> _selectedMembers = {};
  bool _isMultiSelectMode = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSelectAll(List<HerdMemberInfo> filteredMembers) {
    setState(() {
      if (_selectedMembers.length == filteredMembers.length) {
        _selectedMembers.clear();
      } else {
        _selectedMembers.clear();
        _selectedMembers.addAll(filteredMembers.map((m) => m.userId));
      }
    });
  }

  void _exitMultiSelect() {
    setState(() {
      _selectedMembers.clear();
      _isMultiSelectMode = false;
    });
  }

  List<HerdMemberInfo> _filterMembers(List<HerdMemberInfo> members) {
    if (_searchQuery.isEmpty) return members;

    final query = _searchQuery.toLowerCase();
    return members.where((member) {
      return member.displayUsername.toLowerCase().contains(query) ||
          (member.bio?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(authProvider);
    final canViewMembers = ref.watch(
      hasPermissionProvider(
        PermissionRequest(
          herdId: widget.herdId,
          permission: HerdPermission.viewMembers,
        ),
      ),
    );
    final membersAsync = ref.watch(herdMembersWithInfoProvider(widget.herdId));

    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: Text('Please log in to access member management')),
      );
    }

    return canViewMembers.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        body: Center(child: Text('Error: $error')),
      ),
      data: (hasPermission) {
        if (!hasPermission) {
          return const Scaffold(
            body: Center(
              child: Text('You do not have permission to manage members'),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: _isMultiSelectMode
                ? Text('${_selectedMembers.length} selected')
                : const Text('Manage Members'),
            actions: _isMultiSelectMode
                ? [
                    IconButton(
                      icon: const Icon(Icons.select_all),
                      onPressed: () => membersAsync.whenData((members) {
                        final filtered = _filterMembers(members);
                        _toggleSelectAll(filtered);
                      }),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: _exitMultiSelect,
                    ),
                  ]
                : null,
          ),
          body: Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search members...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),
              // Members List
              Expanded(
                child: membersAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Center(
                    child: Text('Error loading members: $error'),
                  ),
                  data: (members) {
                    final filteredMembers = _filterMembers(members);

                    if (filteredMembers.isEmpty) {
                      return Center(
                        child: Text(
                          _searchQuery.isEmpty
                              ? 'No members found'
                              : 'No members match your search',
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: filteredMembers.length,
                      itemBuilder: (context, index) {
                        final member = filteredMembers[index];
                        final isSelected =
                            _selectedMembers.contains(member.userId);

                        return MemberTile(
                          member: member,
                          herdId: widget.herdId,
                          currentUserId: currentUser.uid,
                          isSelected: isSelected,
                          isMultiSelectMode: _isMultiSelectMode,
                          onTap: () {
                            if (_isMultiSelectMode) {
                              setState(() {
                                if (isSelected) {
                                  _selectedMembers.remove(member.userId);
                                  if (_selectedMembers.isEmpty) {
                                    _isMultiSelectMode = false;
                                  }
                                } else {
                                  _selectedMembers.add(member.userId);
                                }
                              });
                            } else {
                              _showMemberActions(context, member);
                            }
                          },
                          onLongPress: () {
                            if (!_isMultiSelectMode) {
                              setState(() {
                                _isMultiSelectMode = true;
                                _selectedMembers.add(member.userId);
                              });
                            }
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          floatingActionButton:
              _isMultiSelectMode && _selectedMembers.isNotEmpty
                  ? FloatingActionButton.extended(
                      onPressed: () => _showBatchActions(context),
                      icon: const Icon(Icons.more_horiz),
                      label: const Text('Batch Actions'),
                    )
                  : null,
        );
      },
    );
  }

  void _showMemberActions(BuildContext context, HerdMemberInfo member) {
    showModalBottomSheet(
      context: context,
      builder: (context) => MemberActionSheet(
        member: member,
        herdId: widget.herdId,
      ),
    );
  }

  void _showBatchActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => BatchActionSheet(
        selectedUserIds: _selectedMembers.toList(),
        herdId: widget.herdId,
        onComplete: _exitMultiSelect,
      ),
    );
  }
}
