import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/transaction_service.dart';
import '../../utils/app_theme.dart';

class CategoryDetailScreen extends StatefulWidget {
  final Map<String, dynamic> category;
  const CategoryDetailScreen({super.key, required this.category});

  @override
  State<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen> {
  List<dynamic> _transactions = [];
  bool _loading = true;
  double _balance = 0.0;

  Future<void> _loadTransactions() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final catId = widget.category['_id'] ?? widget.category['id'];
    final tx = await TransactionService.getTransactions(auth.token, catId);
    setState(() {
      _transactions = tx ?? [];
      _loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _balance = (widget.category['balance'] ?? 0).toDouble();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadTransactions());
  }

  Future<void> _showAmountDialog(bool isAdd) async {
    final controller = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (isAdd ? AppColors.success : AppColors.error).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                isAdd ? Icons.add_rounded : Icons.remove_rounded,
                color: isAdd ? AppColors.success : AppColors.error,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(isAdd ? 'Add Money' : 'Subtract Money'),
          ],
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            hintText: 'Enter amount',
            prefixIcon: Icon(Icons.attach_money_rounded),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: isAdd
                ? ElevatedButton.styleFrom(backgroundColor: AppColors.success)
                : ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(isAdd ? 'Add' : 'Subtract'),
          ),
        ],
      ),
    );

    if (ok == true && controller.text.isNotEmpty) {
      final amt = double.tryParse(controller.text);
      if (amt == null) return;
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final catId = widget.category['_id'] ?? widget.category['id'];

      final res = isAdd
          ? await TransactionService.addMoney(auth.token, catId, amt)
          : await TransactionService.subtractMoney(auth.token, catId, amt);

      if (res != null && res['category'] != null) {
        setState(() {
          _balance = (res['category']['balance'] ?? _balance).toDouble();
        });
        await _loadTransactions();
      }
    }
  }

  String _formatDate(String? dateRaw) {
    if (dateRaw == null || dateRaw.isEmpty) return '';
    try {
      final parsed = DateTime.parse(dateRaw).toLocal();
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${months[parsed.month - 1]} ${parsed.day}, ${parsed.year} at ${parsed.hour.toString().padLeft(2, '0')}:${parsed.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.category['name'] ?? 'Category';

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(name),
      ),
      body: RefreshIndicator(
        onRefresh: _loadTransactions,
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Balance Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Current Balance',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Rs. ${_balance.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: AppColors.success,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              onPressed: () => _showAmountDialog(true),
                              icon: const Icon(Icons.add_rounded),
                              label: const Text('Add'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white.withOpacity(0.2),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              onPressed: () => _showAmountDialog(false),
                              icon: const Icon(Icons.remove_rounded),
                              label: const Text('Subtract'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // Transactions Header
                const Text('Recent Transactions', style: AppTextStyles.heading3),
                const SizedBox(height: 16),

                // Transactions List
                if (_loading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (_transactions.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(40),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: const Icon(
                            Icons.receipt_long_outlined,
                            size: 40,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No transactions yet',
                          style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add or subtract money to see your transaction history',
                          style: AppTextStyles.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _transactions.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final t = _transactions[index];
                      final amount = (t['amount'] ?? 0).toDouble();
                      final type = t['type'] ?? '';
                      final isAdd = type == 'ADD';
                      final date = _formatDate(t['date']);

                      return Container(
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.divider),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: (isAdd ? AppColors.success : AppColors.error).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              isAdd ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                              color: isAdd ? AppColors.success : AppColors.error,
                            ),
                          ),
                          title: Text(
                            isAdd ? 'Money Added' : 'Money Subtracted',
                            style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            date,
                            style: AppTextStyles.bodySmall,
                          ),
                          trailing: Text(
                            '${isAdd ? '+' : '-'}Rs. ${amount.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: isAdd ? AppColors.success : AppColors.error,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}