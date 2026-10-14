
import 'package:expenzia/widgets/edit_transaction.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../theme/app_theme.dart';
import 'package:expenzia/widgets/transactions.dart';
import '../database/transaction_database.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState
    extends State<TransactionHistoryScreen> {
  int _selectedIndex = 1;

  List<Map<String, dynamic>> _transactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    try {
      final data = await TransactionDatabase.instance.getTransactions();

      if (!mounted) return;

      setState(() {
        _transactions = data;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load transactions: $e')),
      );
    }
  }
  String _formatAmount(Map<String, dynamic> transaction) {
    final amount = (transaction['amount'] as num).toDouble();
    final isIncome =
        transaction['type'].toString().toLowerCase() == 'income';

    final sign = isIncome ? '+' : '-';

    return '$sign ₹ ${amount.toStringAsFixed(2)}';
  }

  // EDIT TRANSACTION
  Future<void> _editTransaction(int index) async {
    final transaction = _transactions[index];

    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => EditTransaction(
          initialTransaction:
          Map<String, dynamic>.from(transaction),
        ),
      ),
    );

    if (result == true && mounted) {
      await _loadTransactions();
    }
  }
  // DELETE TRANSACTION WITH CONFIRMATION
  Future<void> _confirmDeleteTransaction(int index) async {
    final transaction = _transactions[index];

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete transaction?'),
          content: Text(
            'Are you sure you want to delete '
                '${transaction['name']}?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text(
                'Delete',
                style: TextStyle(
                  color: AppTheme.expenseColor,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    try {
      await TransactionDatabase.instance.deleteTransaction(
        transaction['id'] as int,
      );

      if (!mounted) return;

      await _loadTransactions();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${transaction['name']} deleted'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete transaction: $e')),
      );
    }

    setState(() {
      _transactions.remove(transaction);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${transaction['name']} deleted'),
        action: SnackBarAction(
          label: 'UNDO',
          onPressed: () {
            if (!mounted) return;

            setState(() {
              _transactions.insert(
                index.clamp(0, _transactions.length),
                transaction,
              );
            });
          },
        ),
      ),
    );
  }

  // ADD TRANSACTION

  Future<void> _addTransaction() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => const TransactionScreen(),
      ),
    );

    if (result == true && mounted) {
      await _loadTransactions();
    }
  }

  // TRANSACTION ITEM WITH SWIPE ACTIONS
  Widget _buildTransactionItem(int index) {
    final transaction = _transactions[index];

    final isIncome =
        transaction['type'].toString().toLowerCase() == 'income';

    return Slidable(
      key: ObjectKey(transaction),

      // Swipe left to reveal Edit and Delete on the right.
      endActionPane: ActionPane(
        motion: const BehindMotion(),
        extentRatio: 0.45,
        children: [
          // EDIT BUTTON
          SlidableAction(
            onPressed: (_) {
              _editTransaction(index);
            },
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
            icon: Icons.edit_outlined,
            label: 'Edit',
            borderRadius: BorderRadius.circular(8),
          ),

          // DELETE BUTTON
          SlidableAction(
            onPressed: (_) {
              _confirmDeleteTransaction(index);
            },
            backgroundColor: AppTheme.expenseColor,
            foregroundColor: Colors.white,
            icon: Icons.delete_outline,
            label: 'Delete',
            borderRadius: BorderRadius.circular(8),
          ),
        ],
      ),

      // TRANSACTION DETAILS
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction['name'].toString(),
                    style: const TextStyle(
                      color: Color(0xFF202624),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    _displayDate(transaction['date']),
                    style: const TextStyle(
                      color: AppTheme.secondaryColor,
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              _formatAmount(transaction),
              style: TextStyle(
                color: isIncome
                    ? AppTheme.incomeColor
                    : AppTheme.expenseColor,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // BOTTOM NAVIGATION
  Widget _buildBottomNavigation() {
    return BottomAppBar(
      color: AppTheme.primaryColor,
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

  Widget _navItem(IconData icon, int index) {
    final isSelected = _selectedIndex == index;

    return IconButton(
      onPressed: () {
        if (index == _selectedIndex) return;

        // Add navigation to your other pages here.
        setState(() {
          _selectedIndex = index;
        });

        if (index == 0) {
          Navigator.pop(context);
        }
      },
      icon: Icon(
        icon,
        size: 24,
        color: isSelected
            ? Colors.white
            : const Color(0xFF205F5B),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        toolbarHeight: 78,
        title: const Text('Transaction History'),
        automaticallyImplyLeading: false,
      ),

      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _transactions.isEmpty
          ? const Center(
        child: Text('No transactions yet'),
      )
          : ListView.builder(
        padding: const EdgeInsets.only(
          top: 12,
          bottom: 20,
        ),
        itemCount: _transactions.length,
        itemBuilder: (context, index) =>
            _buildTransactionItem(index),
      ),

      floatingActionButtonLocation:
      FloatingActionButtonLocation.centerDocked,

      floatingActionButton: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppTheme.primaryColor,
          border: Border.all(
            color: Colors.white,
            width: 4,
          ),
        ),
        child: FloatingActionButton(
          heroTag: 'historyAddTransactionButton',
          onPressed: _addTransaction,
          elevation: 0,
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          shape: const CircleBorder(),
          child: const Icon(
            Icons.add,
            size: 30,
          ),
        ),
      ),

      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  String _displayDate(dynamic value) {
    final date = DateTime.tryParse(value.toString());

    if (date == null) return value.toString();

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final transactionDate =
    DateTime(date.year, date.month, date.day);

    if (transactionDate == today) return 'Today';
    if (transactionDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    }

    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];

    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
