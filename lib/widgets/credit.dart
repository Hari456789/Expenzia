
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CreditScreen extends StatefulWidget {
  const CreditScreen({super.key});

  @override
  State<CreditScreen> createState() => _CreditScreenState();
}

class _CreditScreenState extends State<CreditScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _toController =
  TextEditingController(text: 'Netflix');

  String _creditType = 'Subscriptions';
  String _planType = 'Monthly';
  DateTime _selectedDate = DateTime(2026, 2, 22);

  int _selectedIndex = 2;

  final List<Map<String, dynamic>> _savedCredits = [
    {
      'name': 'Netflix',
      'plan': 'Monthly',
      'amount': 850.00,
      'due': 'Today',
      'type': 'Subscriptions',
      'date': DateTime(2026, 2, 22),
    },
    {
      'name': 'Rohith',
      'plan': 'One-Time',
      'amount': 18500.00,
      'due': 'On 10/12/26',
      'type': 'Personal',
      'date': DateTime(2026, 12, 10),
    },
    {
      'name': 'Electricity Bill',
      'plan': 'Monthly',
      'amount': 850.00,
      'due': 'On 05/11/26',
      'type': 'Bills',
      'date': DateTime(2026, 11, 5),
    },
  ];

  @override
  void dispose() {
    _toController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    const weekdays = [
      'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun',
    ];
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];

    return '${weekdays[date.weekday - 1]}, '
        '${date.day.toString().padLeft(2, '0')} '
        '${months[date.month - 1]} ${date.year}';
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF202624),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Widget _fieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontSize: 9,
          letterSpacing: 0.6,
          fontWeight: FontWeight.w500,
          color: AppTheme.secondaryColor,
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      icon: const Icon(
        Icons.keyboard_arrow_down_rounded,
        size: 19,
        color: AppTheme.secondaryColor,
      ),
      decoration: const InputDecoration(
        contentPadding: EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 0,
        ),
      ),
      style: const TextStyle(
        fontSize: 11,
        color: AppTheme.secondaryColor,
      ),
      items: items.map((item) {
        return DropdownMenuItem(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  void _saveCredit() {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _savedCredits.insert(0, {
        'name': _toController.text.trim(),
        'plan': _planType,
        'amount': 850.00,
        'due': 'On ${_selectedDate.day.toString().padLeft(2, '0')}/'
            '${_selectedDate.month.toString().padLeft(2, '0')}/'
            '${(_selectedDate.year % 100).toString().padLeft(2, '0')}',
        'type': _creditType,
        'date': _selectedDate,
      });
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Credit saved successfully'),
      ),
    );

    _toController.clear();
  }

  Widget _buildSavedCredit(Map<String, dynamic> credit) {
    final bool dueToday = credit['due'] == 'Today';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  credit['name'].toString(),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF202624),
                  ),
                ),
                const SizedBox(height: 3),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 9,
                      color: AppTheme.secondaryColor,
                    ),
                    children: [
                      const TextSpan(text: 'Due '),
                      TextSpan(
                        text: credit['due'].toString(),
                        style: TextStyle(
                          color: dueToday
                              ? AppTheme.expenseColor
                              : AppTheme.secondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                credit['plan'].toString(),
                style: const TextStyle(
                  fontSize: 9,
                  color: AppTheme.secondaryColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '₹ ${((credit['amount'] as num).toDouble()).toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF202624),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, int index) {
    return IconButton(
      onPressed: () {
        setState(() => _selectedIndex = index);

        // Connect Home, History, Wallet and Profile navigation here.
      },
      icon: Icon(
        icon,
        size: 23,
        color: _selectedIndex == index
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
            _navItem(Icons.account_balance_wallet_outlined, 2),
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
        toolbarHeight: 80,
        automaticallyImplyLeading: false,
        title: const Text('Credit'),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(15, 14, 15, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Credit form
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _fieldLabel('Credit Type'),
                          _buildDropdown(
                            value: _creditType,
                            items: const [
                              'Subscriptions',
                              'Bills',
                              'Personal',
                              'Shopping',
                              'Other',
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => _creditType = value);
                              }
                            },
                          ),

                          const SizedBox(height: 12),

                          _fieldLabel('To'),
                          TextFormField(
                            controller: _toController,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppTheme.secondaryColor,
                            ),
                            decoration: const InputDecoration(
                              hintText: 'Enter name',
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 0,
                              ),
                            ),
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty) {
                                return 'Please enter a name';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 12),

                          _fieldLabel('Date'),
                          InkWell(
                            onTap: _pickDate,
                            borderRadius: BorderRadius.circular(8),
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 0,
                                ),
                                suffixIcon: Icon(
                                  Icons.calendar_month,
                                  size: 16,
                                  color: AppTheme.secondaryColor,
                                ),
                              ),
                              child: Text(
                                _formatDate(_selectedDate),
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppTheme.secondaryColor,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          _fieldLabel('Plan Type'),
                          _buildDropdown(
                            value: _planType,
                            items: const [
                              'Monthly',
                              'Weekly',
                              'Yearly',
                              'One-Time',
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => _planType = value);
                              }
                            },
                          ),

                          const SizedBox(height: 12),

                          SizedBox(
                            width: double.infinity,
                            height: 44,
                            child: ElevatedButton(
                              onPressed: _saveCredit,
                              child: const Text('Save'),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    const Text(
                      'Your Saved Lists',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF202624),
                      ),
                    ),

                    const SizedBox(height: 5),

                    ..._savedCredits.map(_buildSavedCredit),
                  ],
                ),
              ),
            ),
          ],
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
            heroTag: 'creditAddButton',
            onPressed: () {
              _toController.clear();
              setState(() {
                _creditType = 'Subscriptions';
                _planType = 'Monthly';
                _selectedDate = DateTime.now();
              });
            },
            elevation: 3,
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
            shape: const CircleBorder(),
            child: const Icon(Icons.add, size: 30),
          ),
        ),
      ),

      bottomNavigationBar: _buildBottomNavigation(),
    );
  }
}
