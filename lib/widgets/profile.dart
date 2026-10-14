
import 'package:expenzia/widgets/transactions.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _userName = 'Sahal Muhammed';
  int _selectedIndex = 3;

  void _editName() {
    final controller = TextEditingController(text: _userName);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Edit Profile Name'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Enter your name',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = controller.text.trim();

                if (name.isNotEmpty) {
                  setState(() {
                    _userName = name;
                  });
                }

                Navigator.pop(dialogContext);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    ).then((_) => controller.dispose());
  }

  Future<void> _clearStorage() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Clear Storage'),
          content: const Text(
            'Are you sure you want to clear your saved '
                'application data? This action may not be reversible.',
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.pop(dialogContext, true),
              child: const Text(
                'Clear',
                style: TextStyle(
                  color: AppTheme.expenseColor,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Connect your storage clearing logic here'),
        ),
      );
    }
  }

  void _changeProfilePhoto() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Connect your profile photo picker here'),
      ),
    );
  }

  Widget _navItem(IconData icon, int index) {
    final isSelected = _selectedIndex == index;

    return IconButton(
      onPressed: () {
        setState(() {
          _selectedIndex = index;
        });

        // Connect Home, History and Credit navigation here.
        if (index == 3) return;

        Navigator.pop(context);
      },
      tooltip: const ['Home', 'History', 'Credit', 'Profile'][0 + index],
      icon: Icon(
        icon,
        size: 24,
        color: isSelected
            ? Colors.white
            : const Color(0xFF356E69),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return BottomAppBar(
      color: AppTheme.accentColor,
      elevation: 0,
      shape: const CircularNotchedRectangle(),
      notchMargin: 7,
      child: SizedBox(
        height: 48,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(Icons.home_outlined, 0),
            _navItem(Icons.history, 1),
            const SizedBox(width: 48),
            _navItem(
              Icons.account_balance_wallet_outlined,
              2,
            ),
            _navItem(Icons.person_outline, 3),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        toolbarHeight: 86,
        leading: IconButton(
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 18,
          ),
        ),
        title: const Text('Profile'),
      ),

      body: SafeArea(
        top: false,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Profile avatar and camera button
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 84,
                    height: 84,
                    decoration: const BoxDecoration(
                      color: Color(0xFFB5B5B5),
                      shape: BoxShape.circle,
                    ),
                    child: ClipOval(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const Positioned(
                            top: 16,
                            child: CircleAvatar(
                              radius: 16,
                              backgroundColor: Color(0xFFE8E8E8),
                            ),
                          ),
                          Positioned(
                            bottom: -13,
                            child: Container(
                              width: 63,
                              height: 43,
                              decoration: const BoxDecoration(
                                color: Color(0xFFE8E8E8),
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(35),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Positioned(
                    right: -2,
                    bottom: 0,
                    child: GestureDetector(
                      onTap: _changeProfilePhoto,
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Editable profile name
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _userName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF303030),
                    ),
                  ),
                  const SizedBox(width: 5),
                  GestureDetector(
                    onTap: _editName,
                    child: const Icon(
                      Icons.edit,
                      size: 13,
                      color: AppTheme.hintColor,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 13),

              // Clear storage button
              OutlinedButton(
                onPressed: _clearStorage,
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFB0B0B0),
                  side: const BorderSide(
                    color: Color(0xFFE0E0E0),
                  ),
                  minimumSize: const Size(94, 28),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  'Clear Storage',
                  style: TextStyle(fontSize: 10),
                ),
              ),
            ],
          ),
        ),
      ),

      floatingActionButtonLocation:
      FloatingActionButtonLocation.centerDocked,

      floatingActionButton: Container(
        padding: const EdgeInsets.all(4),
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: SizedBox(
          width: 56,
          height: 56,
          child: FloatingActionButton(
            heroTag: 'profileAddButton',
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => TransactionScreen()));
            },
            elevation: 3,
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
            shape: const CircleBorder(),
            child: const Icon(
              Icons.add,
              size: 30,
            ),
          ),
        ),
      ),

      bottomNavigationBar: _buildBottomNavigation(),
    );
  }
}
