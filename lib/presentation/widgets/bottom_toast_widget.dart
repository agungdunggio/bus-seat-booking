import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum BottomToastType {
  success,
  error,
  info,
}

class _BottomToastManager {
  static OverlayEntry? _currentEntry;
  static final List<_ToastRequest> _queue = <_ToastRequest>[];
  static bool _isShowing = false;

  static void _enqueue(_ToastRequest req) {
    _queue.add(req);
    _drainQueue();
  }

  static void _drainQueue() {
    if (_isShowing) return;
    if (_queue.isEmpty) return;

    final overlay = _resolveOverlay();
    if (overlay == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _drainQueue());
      return;
    }

    final req = _queue.removeAt(0);
    _isShowing = true;
    _insertIntoOverlay(
      overlay,
      message: req.message,
      type: req.type,
      duration: req.duration,
      margin: req.margin,
      onFinished: () {
        _isShowing = false;
        _drainQueue();
      },
    );
  }

  static OverlayState? _resolveOverlay() {
    final overlayContext = Get.overlayContext ?? Get.context;
    final overlayFromContext = overlayContext == null
        ? null
        : Overlay.maybeOf(overlayContext, rootOverlay: true);
    return overlayFromContext ?? Get.key.currentState?.overlay;
  }

  static void show({
    required String message,
    BottomToastType type = BottomToastType.info,
    Duration duration = const Duration(milliseconds: 2400),
    EdgeInsets? margin,
  }) {
    _enqueue(
      _ToastRequest(
        message: message,
        type: type,
        duration: duration,
        margin: margin,
      ),
    );
  }

  static void _insertIntoOverlay(
    OverlayState overlay, {
    required String message,
    required BottomToastType type,
    required Duration duration,
    required EdgeInsets? margin,
    required VoidCallback onFinished,
  }) {
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) {
        return _BottomToastWidget(
          message: message,
          type: type,
          duration: duration,
          margin: margin,
          onDismissed: () {
            entry.remove();
            if (_currentEntry == entry) {
              _currentEntry = null;
            }
            onFinished();
          },
        );
      },
    );

    _currentEntry = entry;
    overlay.insert(entry);
  }
}

class _ToastRequest {
  const _ToastRequest({
    required this.message,
    required this.type,
    required this.duration,
    required this.margin,
  });

  final String message;
  final BottomToastType type;
  final Duration duration;
  final EdgeInsets? margin;
}

class BottomToast {
  static void show({
    required String message,
    BottomToastType type = BottomToastType.info,
    Duration duration = const Duration(milliseconds: 2400),
    EdgeInsets? margin,
  }) {
    _BottomToastManager.show(
      message: message,
      type: type,
      duration: duration,
      margin: margin,
    );
  }
}

class _BottomToastWidget extends StatefulWidget {
  const _BottomToastWidget({
    required this.message,
    required this.type,
    required this.duration,
    required this.onDismissed,
    this.margin,
  });

  final String message;
  final BottomToastType type;
  final Duration duration;
  final EdgeInsets? margin;
  final VoidCallback onDismissed;

  @override
  State<_BottomToastWidget> createState() => _BottomToastWidgetState();
}

class _BottomToastWidgetState extends State<_BottomToastWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
      reverseDuration: const Duration(milliseconds: 200),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 5),
      end: const Offset(0, 0),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _controller.forward();
    _autoDismiss();
  }

  Future<void> _autoDismiss() async {
    await Future<void>.delayed(widget.duration);
    if (!mounted) return;
    await _controller.reverse();
    if (mounted) widget.onDismissed();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _tintForType() {
    switch (widget.type) {
      case BottomToastType.success:
        return Colors.green;
      case BottomToastType.error:
        return Colors.red;
      case BottomToastType.info:
        return Colors.blue;
    }
  }

  IconData _iconForType() {
    switch (widget.type) {
      case BottomToastType.success:
        return Icons.check_circle_rounded;
      case BottomToastType.error:
        return Icons.error_rounded;
      case BottomToastType.info:
        return Icons.info_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tint = _tintForType();

    return IgnorePointer(
      ignoring: true,
      child: SafeArea(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: widget.margin ?? const EdgeInsets.fromLTRB(16, 0, 16, 70),
            child: SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: BackdropFilter(
                    filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            tint.withAlpha(38),
                            tint.withAlpha(20),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: tint.withAlpha(41),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 22,
                            height: 22,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: tint.withAlpha(24),
                              border: Border.all(color: tint.withAlpha(96), width: 1),
                            ),
                            child: Icon(
                              _iconForType(),
                              color: tint,
                              size: 14,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Flexible(
                            child: Text(
                              widget.message,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: tint.withAlpha(204),
                                fontWeight: FontWeight.w600,
                                height: 1.25,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
