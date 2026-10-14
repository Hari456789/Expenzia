
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../database/transaction_database.dart';

class EditTransaction extends StatefulWidget {
  final Map<String, dynamic> initialTransaction;

  const EditTransaction({
    super.key,
    required this.initialTransaction,
  });

  @override
  State<EditTransaction> createState() =>
      _EditTransactionScreenState();
}

class _EditTransactionScreenState
    extends State<EditTransaction> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _amountController;

  late String _transactionType;
  late DateTime _selectedDate;

  static const List<String> _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  @override
  void initState() {
    super.initState();

    final transaction = widget.initialTransaction;

    _nameController = TextEditingController(
      text: transaction['name']?.toString() ?? '',
    );

    _amountController = TextEditingController(
      text: ((transaction['amount'] as num?) ?? 0)
          .toStringAsFixed(2),
    );

    final type = transaction['type']?.toString() ?? 'Expense';
    _transactionType =
    type.toLowerCase() == 'income' ? 'Income' : 'Expense';

    _selectedDate = _parseTransactionDate(
      transaction['date']?.toString() ?? '',
    );
  }

  DateTime _parseTransactionDate(String value) {
    final now = DateTime.now();

    if (value.toLowerCase() == 'today') {
      return DateTime(now.year, now.month, now.day);
    }

    if (value.toLowerCase() == 'yesterday') {
      final yesterday = now.subtract(const Duration(days: 1));
      return DateTime(
        yesterday.year,
        yesterday.month,
        yesterday.day,
      );
    }

    final isoDate = DateTime.tryParse(value);
    if (isoDate != null) {
      return isoDate;
    }

    // Supports dates such as "Jan 30, 2022".
    final match = RegExp(
      r'^([A-Za-z]{3})\s+(\d{1,2}),\s*(\d{4})$',
    ).firstMatch(value);

    if (match != null) {
      final month = _months.indexOf(
        '${match.group(1)![0].toUpperCase()}'
            '${match.group(1)!.substring(1).toLowerCase()}',
      );

      if (month >= 0) {
        return DateTime(
          int.parse(match.group(3)!),
          month + 1,
          int.parse(match.group(2)!),
        );
      }
    }

    // Fallback for dates that cannot be parsed.
    return DateTime(now.year, now.month, now.day);
  }

  String _formatDate(DateTime date) {
    const weekdays = [
      'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun',
    ];

    return '${weekdays[date.weekday - 1]}, '
        '${date.day.toString().padLeft(2, '0')} '
        '${_months[date.month - 1]} ${date.year}';
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
      setState(() {
        _selectedDate = picked;
      });
    }
  }


  Future<void> _saveTransaction() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.tryParse(_amountController.text.trim());

    if (amount == null || amount <= 0) return;

    final id = widget.initialTransaction['id'];

    if (id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Transaction ID is missing'),
        ),
      );
      return;
    }

    final updatedTransaction = <String, dynamic>{
      'name': _nameController.text.trim(),
      'type': _transactionType,
      'amount': amount,
      'date': _selectedDate.toIso8601String(),
    };

    try {
      await TransactionDatabase.instance.updateTransaction(
        id as int,
        updatedTransaction,
      );

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update transaction: $e')),
      );
    }
  }

  Widget _fieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.65,
          color: AppTheme.secondaryColor,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        toolbarHeight: 66,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 18,
          ),
        ),
        title: const Text('Edit Transaction'),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 20),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(
                    13, 20, 13, 20,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.cardColor,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.045),
                        blurRadius: 20,
                        offset: const Offset(0, 7),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _fieldLabel('Transaction Type'),
                        DropdownButtonFormField<String>(
                          value: _transactionType,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 0,
                            ),
                          ),
                          icon: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 19,
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'Expense',
                              child: Text('Expense'),
                            ),
                            DropdownMenuItem(
                              value: 'Income',
                              child: Text('Income'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _transactionType = value;
                              });
                            }
                          },
                        ),

                        const SizedBox(height: 12),

                        _fieldLabel('Name'),
                        TextFormField(
                          controller: _nameController,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.secondaryColor,
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Enter transaction name',
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 0,
                            ),
                          ),
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty) {
                              return 'Enter a transaction name';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        _fieldLabel('Amount'),
                        TextFormField(
                          controller: _amountController,
                          keyboardType:
                          const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.primaryColor,
                          ),
                          decoration: InputDecoration(
                            prefixText: '₹ ',
                            prefixStyle: const TextStyle(
                              fontSize: 11,
                              color: AppTheme.primaryColor,
                            ),
                            contentPadding:
                            const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 0,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide: const BorderSide(
                                color: AppTheme.primaryColor,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide: const BorderSide(
                                color: AppTheme.primaryColor,
                                width: 1.2,
                              ),
                            ),
                            suffixIcon: TextButton(
                              onPressed: _amountController.clear,
                              child: const Text(
                                'Clear',
                                style: TextStyle(fontSize: 9),
                              ),
                            ),
                          ),
                          validator: (value) {
                            final amount = double.tryParse(
                              value?.trim() ?? '',
                            );

                            if (amount == null || amount <= 0) {
                              return 'Enter a valid amount';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 18),

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
                      ],
                    ),
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 44),
              child: SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  onPressed: _saveTransaction,
                  child: const Text('Save'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
