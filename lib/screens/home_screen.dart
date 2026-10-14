
import 'package:expenzia/widgets/credit.dart';
import 'package:expenzia/widgets/profile.dart';
import 'package:expenzia/widgets/transaction_history.dart';
import 'package:expenzia/widgets/transactions.dart';
import 'package:flutter/material.dart';
import 'package:expenzia/theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  void _navigateToPage(int index) {
    if (index == 0) {
      return;
    }

    late final Widget page;

    switch (index) {
      case 1:
        page = const TransactionHistoryScreen();
        break;

      case 2:
        page = const CreditScreen();
        break;

      case 3:
        page = const ProfileScreen();
        break;

      default:
        return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    ).then((_) {
      if (mounted) {
        setState(() {
          selectedIndex = 0;
        });
      }
    });
  }

  int selectedIndex = 0;

  final List<Map<String, String>> transactions = [
    {
      'title': 'Upwork',
      'date': 'Today',
      'amount': '+ \$ 850.00',
      'type': 'income',
    },
    {
      'title': 'Transfer',
      'date': 'Yesterday',
      'amount': '- \$ 85.00',
      'type': 'expense',
    },
    {
      'title': 'Paypal',
      'date': 'Jan 30, 2022',
      'amount': '+ \$ 1,406.00',
      'type': 'income',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 20, 18, 90),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Good afternoon,',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF424747),
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'Sahal Muhammed',
                style: TextStyle(
                  fontSize: 16,
                  height: 1.1,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF171A19),
                ),
              ),

              const SizedBox(height: 14),

              // Total balance card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(14, 18, 14, 18),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withValues(alpha: 0.20),
                      blurRadius: 9,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Balance',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '₹ 2,548.00',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Income and expenses
                    Row(
                      children: [
                        Expanded(
                          child: _buildBalanceItem(
                            icon: Icons.arrow_downward,
                            label: 'Income',
                            amount: '₹ 1,840.00',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildBalanceItem(
                            icon: Icons.arrow_upward,
                            label: 'Expenses',
                            amount: '₹ 284.00',
                            alignEnd: true,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Daily and weekly average cards
              Row(
                children: [
                  Expanded(
                    child: _buildAverageCard(
                      title: 'DAILY AVERAGE',
                      amount: '₹ 1,548.00',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildAverageCard(
                      title: 'WEEKLY',
                      amount: '₹ 548.00',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Transaction history heading
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Transactions History',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF222625),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => TransactionHistoryScreen()));
                    },
                    child: const Text(
                      'See all',
                      style: TextStyle(
                        fontSize: 10,
                        color: Color(0xFF777F7D),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              if (transactions.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(30),
                    child: Text('No transactions available'),
                  ),
                )
              else
                ...transactions.map(
                      (transaction) => _buildTransaction(transaction),
                ),
            ],
          ),
        ),
      ),

      // Floating add button
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
            heroTag: 'addExpenseButton',
            elevation: 3,
            backgroundColor: AppTheme.accentColor,
            foregroundColor: Colors.white,
            shape: const CircleBorder(),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TransactionScreen(),
                ),
              );
            },
            child: const Icon(Icons.add, size: 30),
          ),
        ),
      ),

      // Bottom navigation bar
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // Balance card income / expense details
  Widget _buildBalanceItem({
    required IconData icon,
    required String label,
    required String amount,
    bool alignEnd = false,
  }) {
    return Column(
      crossAxisAlignment:
      alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment:
          alignEnd ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: const BoxDecoration(
                color: Color(0xFF66A7A1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 11,
              ),
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFFD8EAE8),
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: alignEnd ? Alignment.centerRight : Alignment.centerLeft,
          child: Text(
            amount,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  // Average amount cards
  Widget _buildAverageCard({
    required String title,
    required String amount,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 9,
            letterSpacing: 0.7,
            color: Color(0xFF777F7D),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            vertical: 13,
            horizontal: 6,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: const Color(0xFFD9DEDC),
            ),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              amount,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Color(0xFF171A19),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Individual transaction row
  Widget _buildTransaction(Map<String, String> transaction) {
    final bool isIncome = transaction['type'] == 'income';

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction['title']!,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF171A19),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  transaction['date']!,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF929997),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            transaction['amount']!,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isIncome
                  ? const Color(0xFF08B86A)
                  : const Color(0xFFFF4545),
            ),
          ),
        ],
      ),
    );
  }

  // Bottom navigation bar
  Widget _buildBottomNavigationBar() {
    const List<IconData> icons = [
      Icons.home_outlined,
      Icons.history,
      Icons.account_balance_wallet_outlined,
      Icons.person_outline,
    ];

    const List<String> labels = [
      'Home',
      'History',
      'Wallet',
      'Profile',
    ];

    return Container(
      height: 100,
      decoration: const BoxDecoration(
        color: AppTheme.accentColor,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(icons.length, (index) {
          return IconButton(
            onPressed: () {
              if (index == 0) {
                setState(() {
                  selectedIndex = 0;
                });
                return;
              }

              setState(() {
                selectedIndex = index;
              });

              _navigateToPage(index);
            },
            icon: Icon(
              icons[index],
              size: 23,
              color: selectedIndex == index
                  ? Colors.white
                  : const Color(0xFF356E69),
            ),
            tooltip: labels[index],
          );
        }),
      ),
    );
  }}
