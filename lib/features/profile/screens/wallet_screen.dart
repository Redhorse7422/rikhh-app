import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
// import 'package:share_plus/share_plus.dart';
import '../../../core/theme/app_colors.dart';
import '../../../features/auth/bloc/auth_bloc.dart';
import '../services/wallet_api_service.dart';
import '../models/wallet_models.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final WalletApiService _walletService = WalletApiService();
  WalletBalance? _walletBalance;
  List<Transaction> _transactions = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _referralLink = 'https://www.Rikhh.com/invites/FO62EE6';

  @override
  void initState() {
    super.initState();
    _loadWalletData();
  }

  Future<void> _loadWalletData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authState = context.read<AuthBloc>().state;

      if (authState is AuthAuthenticated) {
        final userId = authState.user['id'] as String?;

        if (userId != null) {
          final balanceResponse = await _walletService.getWalletBalance(
            userId: userId,
          );

          final transactionsResponse = await _walletService
              .getTransactionHistory(userId: userId);

          setState(() {
            _walletBalance = balanceResponse.data;
            _transactions = transactionsResponse.transactions;
            _isLoading = false;
          });

        } else {
          setState(() {
            _errorMessage = 'User ID not found';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = 'User not authenticated';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _withdrawNow() {
    // TODO: Implement withdraw functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Withdraw functionality coming soon!'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _shareReferralLink() {
    final shareText =
        'Join me on Rikhh! Use my referral link: $_referralLink\n\nDownload the app and start shopping today!';
    // Share.share(shareText);
  }

  void _copyReferralLink() {
    // You can use clipboard package here if needed
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Referral link copied: $_referralLink'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Feather.arrow_left, color: AppColors.heading),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'My Wallet',
          style: TextStyle(
            color: AppColors.heading,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
            ? _buildErrorState()
            : _buildContent(),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Feather.alert_circle, size: 64, color: Colors.red.shade300),
          const SizedBox(height: 16),
          Text(
            'Error',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.heading,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage!,
            style: TextStyle(fontSize: 16, color: AppColors.body),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadWalletData,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Account Balance Card
          _buildAccountBalanceCard(),

          const SizedBox(height: 20),

          // Statistics Row
          // Row(
          //   children: [
          //     Expanded(
          //       child: _buildStatCard(
          //         'Total Link Clicks',
          //         '120',
          //         Feather.mouse_pointer,
          //         Colors.green,
          //       ),
          //     ),
          //     const SizedBox(width: 12),
          //     Expanded(
          //       child: _buildStatCard(
          //         'Total Purchases',
          //         '23',
          //         Feather.shopping_bag,
          //         Colors.green,
          //       ),
          //     ),
          //   ],
          // ),

          // const SizedBox(height: 20),

          // Total Link Shared Card
          // _buildTotalLinkSharedCard(),

          // const SizedBox(height: 20),

          // Refer your friend Card
          // _buildReferFriendCard(),

          // const SizedBox(height: 20),

          // Transaction History Card
          _buildTransactionHistoryCard(),
        ],
      ),
    );
  }

  Widget _buildAccountBalanceCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your account Balance',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.heading,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                '₹',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade600,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${_walletBalance?.balance.toStringAsFixed(2) ?? '0.00'}',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.heading,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'You can redeem your credits monthly into cash, straight into your bank account. So enjoy your earnings while others shop from your links.',
            style: TextStyle(fontSize: 14, color: AppColors.body, height: 1.4),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _withdrawNow,
              icon: const Icon(Feather.arrow_right, size: 18),
              label: const Text('Withdraw Now'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.heading,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: AppColors.body),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTotalLinkSharedCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Link Shared',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.heading,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '220',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.heading,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // Profile pictures row
              SizedBox(
                height: 32,
                width: 5 * 20.0, // Total width for 5 overlapping avatars
                child: Stack(
                  children: List.generate(5, (index) {
                    return Positioned(
                      left: index * 20.0, // Overlap by 4px (20 - 16*2 = 4)
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.grey.shade300,
                        child: Icon(
                          Feather.user,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '+119',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReferFriendCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Feather.gift, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'Refer your friend',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.heading,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Earn upto 10 credits every purchase your referral make!',
            style: TextStyle(fontSize: 14, color: AppColors.body),
          ),
          const SizedBox(height: 16),

          // Referral Link Input
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _referralLink,
                    style: TextStyle(fontSize: 14, color: AppColors.heading),
                  ),
                ),
                TextButton(
                  onPressed: _copyReferralLink,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Feather.copy, size: 16, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text(
                        'Copy Link',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Text(
            'Share via',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.heading,
            ),
          ),
          const SizedBox(height: 12),

          // Social Media Icons
          Row(
            children: [
              _buildSocialIcon(Feather.facebook, Colors.blue, 'Facebook'),
              const SizedBox(width: 16),
              _buildSocialIcon(
                Feather.linkedin,
                Colors.blue.shade700,
                'LinkedIn',
              ),
              const SizedBox(width: 16),
              _buildSocialIcon(Feather.twitter, Colors.black, 'X'),
              const SizedBox(width: 16),
              _buildSocialIcon(
                Feather.message_circle,
                Colors.green,
                'WhatsApp',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSocialIcon(IconData icon, Color color, String platform) {
    return GestureDetector(
      onTap: _shareReferralLink,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 20, color: color),
      ),
    );
  }

  Widget _buildTransactionHistoryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Transactions',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.heading,
                ),
              ),
              TextButton(
                onPressed: () {
                  // TODO: Navigate to full transaction history
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Full transaction history coming soon!'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                },
                child: Text(
                  'View All',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_transactions.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(Feather.arrow_up, size: 48, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'No transactions yet',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.heading,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your transaction history will appear here',
                    style: TextStyle(fontSize: 14, color: AppColors.body),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            ..._transactions
                .take(3)
                .map((transaction) => _buildTransactionItem(transaction)),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(Transaction transaction) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getTransactionColor(
                transaction.type,
              ).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getTransactionIcon(transaction.type),
              size: 20,
              color: _getTransactionColor(transaction.type),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getTransactionTitle(transaction.type),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.heading,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  transaction.description,
                  style: TextStyle(fontSize: 12, color: AppColors.body),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  _formatTransactionDate(transaction.createdAt),
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${transaction.amount > 0 ? '+' : ''}${transaction.amount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: transaction.amount > 0 ? Colors.green : Colors.red,
                ),
              ),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _getStatusColor(
                    transaction.status,
                  ).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  transaction.status.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: _getStatusColor(transaction.status),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getTransactionColor(String type) {
    switch (type) {
      case 'referral_commission':
        return Colors.green;
      case 'withdrawal':
        return Colors.blue;
      case 'purchase':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getTransactionIcon(String type) {
    switch (type) {
      case 'referral_commission':
        return Feather.gift;
      case 'withdrawal':
        return Feather.credit_card;
      case 'purchase':
        return Feather.shopping_bag;
      default:
        return Feather.dollar_sign;
    }
  }

  String _getTransactionTitle(String type) {
    switch (type) {
      case 'referral_commission':
        return 'Referral Commission';
      case 'withdrawal':
        return 'Withdrawal';
      case 'purchase':
        return 'Purchase';
      default:
        return 'Transaction';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatTransactionDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }
}
