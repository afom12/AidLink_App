import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../shared/utils/app_localizations.dart';
import '../../shared/widgets/animated_gradient_background.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> with TickerProviderStateMixin {
  final PageController _controller = PageController();
  int _index = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onPageChanged(int value) {
    setState(() {
      _index = value;
      _animationController.reset();
      _animationController.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(appLocaleProvider);
    final t = AppLocalizations.tr;
    
    return Scaffold(
      body: Stack(
        children: [
          // Animated Gradient Background
          const AnimatedGradientBackground(),
          
          SafeArea(
            child: Column(
              children: [
                // Skip Button
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8, right: 16),
                    child: TextButton(
                      onPressed: () => context.go('/role'),
                      child: Text(
                        t(locale, 'skip'),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withOpacity(0.8),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    itemCount: _pages.length,
                    onPageChanged: _onPageChanged,
                    itemBuilder: (_, pageIndex) {
                      final page = _pages[pageIndex];
                      return FadeTransition(
                        opacity: _fadeAnimation,
                        child: _OnboardingPage(
                          icon: page.icon,
                          title: t(locale, page.titleKey),
                          body: t(locale, page.bodyKey),
                          color: page.color,
                          secondaryColor: page.secondaryColor,
                        ),
                      );
                    },
                  ),
                ),
                
                // Bottom Section
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.05),
                      ],
                    ),
                  ),
                  child: Column(
                    children: [
                      // Page Indicators
                      _ModernPageDots(
                        count: _pages.length,
                        index: _index,
                        activeColor: _pages[_index].color,
                      ),
                      const SizedBox(height: 32),
                      
                      // Animated Button
                      _AnimatedPrimaryButton(
                        label: t(locale, _index == _pages.length - 1 
                            ? 'get_started' 
                            : 'continue'),
                        isLastPage: _index == _pages.length - 1,
                        onPressed: () {
                          if (_index == _pages.length - 1) {
                            context.go('/role');
                          } else {
                            _controller.nextPage(
                              duration: const Duration(milliseconds: 450),
                              curve: Curves.easeInOutCubic,
                            );
                          }
                        },
                        backgroundColor: _pages[_index].color,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  final List<OnboardingPageData> _pages = [
    OnboardingPageData(
      icon: Icons.verified_outlined,
      titleKey: 'onboarding_welcome_title',
      bodyKey: 'onboarding_welcome_body',
      color: const Color(0xFF0F1E3F),
      secondaryColor: const Color(0xFFCDAA80),
    ),
    OnboardingPageData(
      icon: Icons.edit_location_alt_outlined,
      titleKey: 'onboarding_request_title',
      bodyKey: 'onboarding_request_body',
      color: const Color(0xFF0F1E3F),
      secondaryColor: const Color(0xFFCDAA80),
    ),
    OnboardingPageData(
      icon: Icons.volunteer_activism_outlined,
      titleKey: 'onboarding_help_title',
      bodyKey: 'onboarding_help_body',
      color: const Color(0xFF0F1E3F),
      secondaryColor: const Color(0xFFCDAA80),
    ),
    OnboardingPageData(
      icon: Icons.shield_outlined,
      titleKey: 'onboarding_trust_title',
      bodyKey: 'onboarding_trust_body',
      color: const Color(0xFF0F1E3F),
      secondaryColor: const Color(0xFFCDAA80),
    ),
  ];
}

class OnboardingPageData {
  final IconData icon;
  final String titleKey;
  final String bodyKey;
  final Color color;
  final Color secondaryColor;

  OnboardingPageData({
    required this.icon,
    required this.titleKey,
    required this.bodyKey,
    required this.color,
    required this.secondaryColor,
  });
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({
    required this.icon,
    required this.title,
    required this.body,
    required this.color,
    required this.secondaryColor,
  });

  final IconData icon;
  final String title;
  final String body;
  final Color color;
  final Color secondaryColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon Illustration Container
          Container(
            height: 250,
            width: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  color.withOpacity(0.15),
                  color.withOpacity(0.05),
                ],
              ),
            ),
            child: Center(
              child: Icon(
                icon,
                size: 120,
                color: secondaryColor,
              ),
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Title with Gradient
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [color, secondaryColor],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ).createShader(bounds),
            child: Text(
              title,
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 32,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Body with modern typography
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              body,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontSize: 16,
                height: 1.6,
                color: Colors.black54,
                letterSpacing: 0.3,
              ),
            ),
          ),
          
          // Decorative elements
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildDecorativeDot(color),
              const SizedBox(width: 8),
              _buildDecorativeDot(color.withOpacity(0.6)),
              const SizedBox(width: 8),
              _buildDecorativeDot(color.withOpacity(0.3)),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildDecorativeDot(Color color) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _ModernPageDots extends StatelessWidget {
  const _ModernPageDots({
    required this.count,
    required this.index,
    required this.activeColor,
  });

  final int count;
  final int index;
  final Color activeColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 12,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        scrollDirection: Axis.horizontal,
        itemCount: count,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, dotIndex) {
          final isActive = dotIndex == index;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            width: isActive ? 32 : 12,
            height: 12,
            decoration: BoxDecoration(
              color: isActive ? activeColor : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(12),
              boxShadow: isActive ? [
                BoxShadow(
                  color: activeColor.withOpacity(0.4),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ] : null,
            ),
            child: isActive
                ? Center(
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  )
                : null,
          );
        },
      ),
    );
  }
}

class _AnimatedPrimaryButton extends StatefulWidget {
  const _AnimatedPrimaryButton({
    required this.label,
    required this.onPressed,
    required this.isLastPage,
    required this.backgroundColor,
  });

  final String label;
  final VoidCallback onPressed;
  final bool isLastPage;
  final Color backgroundColor;

  @override
  State<_AnimatedPrimaryButton> createState() => _AnimatedPrimaryButtonState();
}

class _AnimatedPrimaryButtonState extends State<_AnimatedPrimaryButton> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown() => _controller.forward();
  void _onTapUp() => _controller.reverse();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _onTapDown(),
      onTapUp: (_) {
        _onTapUp();
        widget.onPressed();
      },
      onTapCancel: _onTapUp,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                widget.backgroundColor,
                Color.lerp(widget.backgroundColor, Colors.white, 0.2)!,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: widget.backgroundColor.withOpacity(0.4),
                blurRadius: 20,
                spreadRadius: 2,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.label,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                if (widget.isLastPage) ...[
                  const SizedBox(width: 12),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}