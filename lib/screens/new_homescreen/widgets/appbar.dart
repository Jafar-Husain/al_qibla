import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:al_qibla/app_theme.dart';
import 'package:al_qibla/provider/app_provider.dart';

class HomeAppBar extends StatefulWidget {
  const HomeAppBar({super.key, required this.isDarkMode});

  final bool isDarkMode;

  @override
  State<HomeAppBar> createState() => _HomeAppBarState();
}

class _HomeAppBarState extends State<HomeAppBar> {
  bool _isRefreshing = false;

  Future<void> _refreshLocation() async {
    if (_isRefreshing) return;
    setState(() => _isRefreshing = true);
    try {
      await Provider.of<AppProvider>(context, listen: false)
          .getPrayerTimes(refresh: true);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Location updated successfully'),
          backgroundColor: AppTheme.getCurrentPrimaryColor(widget.isDarkMode),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update location'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    } finally {
      if (mounted) setState(() => _isRefreshing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(color: Colors.transparent),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Empty space for symmetry
          const SizedBox(width: 40),

          // Title
          Text(
            'Al Qibla',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: widget.isDarkMode
                      ? Colors.white
                      : const Color(0xFF0F3D3E),
                  fontSize: 20,
                ),
          ),

          // Location button
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: _isRefreshing ? null : _refreshLocation,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: widget.isDarkMode
                      ? AppTheme.darkSmallContainer
                      : AppTheme.smallContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: _isRefreshing
                    ? Padding(
                        padding: const EdgeInsets.all(10),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppTheme.getCurrentPrimaryColor(widget.isDarkMode),
                          ),
                        ),
                      )
                    : Icon(
                        Icons.location_on,
                        color:
                            AppTheme.getCurrentPrimaryColor(widget.isDarkMode),
                        size: 20,
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
