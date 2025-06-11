import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Enhanced TypewriterText với proper timer management to prevent infinite rebuilds
class TypewriterText extends StatefulWidget {
  final String text;
  final Duration speed;
  final TextStyle? style;
  final VoidCallback? onCompleted;
  final bool showCursor;
  final Color? cursorColor;
  final bool autoStart;
  final TextAlign textAlign;
  final int? maxLines;

  const TypewriterText({
    Key? key,
    required this.text,
    this.speed = const Duration(milliseconds: 50),
    this.style,
    this.onCompleted,
    this.showCursor = false,
    this.cursorColor,
    this.autoStart = true,
    this.textAlign = TextAlign.start,
    this.maxLines,
  }) : super(key: key);

  @override
  State<TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<TypewriterText> {
  String _displayText = '';
  int _currentIndex = 0;
  bool _isCompleted = false;
  Timer? _timer;
  String? _previousText;

  @override
  void initState() {
    super.initState();
    _previousText = widget.text;
    if (widget.autoStart && widget.text.isNotEmpty) {
      _startTyping();
    }
  }

  @override
  void didUpdateWidget(TypewriterText oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Reset if text changed
    if (oldWidget.text != widget.text) {
      _resetTyping();
      _previousText = widget.text;
      if (widget.autoStart && widget.text.isNotEmpty) {
        _startTyping();
      }
    }
  }

  void _resetTyping() {
    _timer?.cancel();
    _timer = null;
    _currentIndex = 0;
    _displayText = '';
    _isCompleted = false;
  }

  void _startTyping() {
    if (!mounted || _timer != null || widget.text.isEmpty) return;
    
    _timer = Timer.periodic(widget.speed, (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      
      if (_currentIndex < widget.text.length) {
        setState(() {
          _currentIndex++;
          _displayText = widget.text.substring(0, _currentIndex);
        });
      } else {
        // Animation completed
        timer.cancel();
        _timer = null;
        if (!_isCompleted && mounted) {
          _isCompleted = true;
          widget.onCompleted?.call();
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timer = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Đảm bảo có content để tránh empty size
    String displayText = _displayText.isEmpty ? " " : _displayText;
    
    return Text(
      displayText,
      style: widget.style,
      textAlign: widget.textAlign,
      maxLines: widget.maxLines,
      overflow: widget.maxLines != null ? TextOverflow.ellipsis : TextOverflow.visible,
    );
  }
}

/// Enhanced TypewriterAnimatedContainer với proper sizing
class TypewriterAnimatedContainer extends StatefulWidget {
  final String text;
  final Duration typewriterSpeed;
  final Duration slideDelay;
  final TextStyle? textStyle;
  final VoidCallback? onCompleted;
  final EdgeInsetsGeometry? padding;
  final Decoration? decoration;
  final Widget? child;

  const TypewriterAnimatedContainer({
    Key? key,
    required this.text,
    this.typewriterSpeed = const Duration(milliseconds: 30),
    this.slideDelay = const Duration(milliseconds: 100),
    this.textStyle,
    this.onCompleted,
    this.padding,
    this.decoration,
    this.child,
  }) : super(key: key);

  @override
  State<TypewriterAnimatedContainer> createState() => _TypewriterAnimatedContainerState();
}

class _TypewriterAnimatedContainerState extends State<TypewriterAnimatedContainer>
    with SingleTickerProviderStateMixin {
  bool _showContent = false;
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  Timer? _delayTimer;

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Create slide animation
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    // Create fade animation
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    // Start animation after delay
    _delayTimer = Timer(widget.slideDelay, () {
      if (mounted) {
        setState(() {
          _showContent = true;
        });
        _animationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _delayTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: _slideAnimation.value * 20,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              width: double.infinity,
              // Thêm minimum height để tránh zero-size issues
              constraints: BoxConstraints(
                minHeight: widget.child != null ? 0 : 40.h,
              ),
              padding: widget.padding,
              decoration: widget.decoration,
              child: _showContent
                  ? (widget.child ?? TypewriterText(
                      text: widget.text,
                      speed: widget.typewriterSpeed,
                      style: widget.textStyle,
                      onCompleted: widget.onCompleted,
                    ))
                  : SizedBox(
                      height: widget.child != null ? 20.h : 40.h,
                      child: Center(
                        child: Container(
                          width: 20.w,
                          height: 20.h,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).primaryColor.withOpacity(0.3),
                            ),
                          ),
                        ),
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }
}