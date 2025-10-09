import 'package:flutter/material.dart';
import 'package:herdapp/features/social/chat_messaging/data/models/message/message_model.dart';

class SwipeableMessage extends StatefulWidget {
  final MessageModel message;
  final bool isCurrentUser;
  final VoidCallback onReply;
  final Function(String, String) onReplyCallback;
  final Widget child;

  const SwipeableMessage({
    super.key,
    required this.message,
    required this.isCurrentUser,
    required this.onReply,
    required this.onReplyCallback,
    required this.child,
  });

  @override
  State<SwipeableMessage> createState() => SwipeableMessageState();
}

class SwipeableMessageState extends State<SwipeableMessage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  double _dragExtent = 0.0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _slideAnimation = Tween<double>(
      begin: 0.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragExtent += details.primaryDelta ?? 0;
      _dragExtent = _dragExtent.clamp(-80.0, 80.0);
    });
  }

  void _handleDragEnd(DragEndDetails details) {
    final shouldReply = _dragExtent.abs() > 50;

    if (shouldReply) {
      widget.onReply();
    }

    _animationController.duration = const Duration(milliseconds: 200);
    _slideAnimation = Tween<double>(
      begin: _dragExtent,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward(from: 0.0).then((_) {
      setState(() {
        _dragExtent = 0.0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: _handleDragUpdate,
      onHorizontalDragEnd: _handleDragEnd,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          final offset = _animationController.isAnimating
              ? _slideAnimation.value
              : _dragExtent;

          return Stack(
            children: [
              // Reply icon indicator (for swipe)
              if (offset.abs() > 20)
                Positioned.fill(
                  child: Align(
                    alignment: widget.isCurrentUser
                        ? Alignment.centerLeft
                        : Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 100),
                        opacity: offset.abs() / 80,
                        child: Icon(
                          Icons.reply,
                          color: Theme.of(context).colorScheme.primary,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ),

              // Message content
              Transform.translate(
                offset: Offset(offset, 0),
                child: widget.child,
              ),
            ],
          );
        },
      ),
    );
  }
}
