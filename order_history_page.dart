import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'session_manager.dart';
import 'api_config.dart';
import 'translated_text.dart';

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({super.key});

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  List<Map<String, dynamic>> orders = [];
  bool isLoading = true;
  int? expandedIndex;

  final ScrollController _scrollController = ScrollController();


  final List<String> reasons = [
    'Ordered by mistake',
    'Found better price',
    'Delivery is too late',
    'Changed my mind',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> fetchOrders() async {
    final uId = await SessionManager.getUserId();
    try {
      final res = await http.post(
        Uri.parse("${ApiConfig.baseUrl}order_actions.php"),
        body: {"action": "fetch_orders", "u_id": uId.toString()},
      );
      debugPrint("Full Response: ${res.body}");
      final decoded = json.decode(res.body);
      if (decoded is List) {
        orders = decoded.cast<Map<String, dynamic>>();
      }
    } catch (e) {
      debugPrint("Fetch Error: $e");
    }
    if (mounted) setState(() => isLoading = false);
  }

  Future<void> deleteOrder(String orderId, String reason) async {
    try {
      final res = await http.post(
        Uri.parse("${ApiConfig.baseUrl}order_actions.php"),
        body: {
          "action": "delete_order",
          "order_id": orderId,
          "reason": reason,
        },
      );

      final response = json.decode(res.body);
      if (response['status'] == true) {
        setState(() {
          int index = orders.indexWhere((o) => o['order_id'].toString() == orderId);
          if (index != -1) {
            orders[index]['status'] = 'Cancelled';
          }
          expandedIndex = null;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: TText("Order cancelled successfully")),
          );
        }
      }
    } catch (e) {
      debugPrint("Delete Error: $e");
    }
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'confirmed':
      case 'delivered': return Colors.green;
      case 'pending': return Colors.orange;
      case 'cancelled': return Colors.red;
      default: return Colors.black45;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F2),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const TText("Order History", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : Scrollbar(
        controller: _scrollController,
        thumbVisibility: true,
        thickness: 6.0,
        radius: const Radius.circular(10),
        child: ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          itemCount: orders.length,
          itemBuilder: (_, i) => _buildExpandableOrderCard(orders[i], i),
        ),
      ),
    );
  }


  Widget _buildExpandableOrderCard(Map<String, dynamic> order, int index) {
    bool isExpanded = expandedIndex == index;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Order #${order['order_id']}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                  Text(order['created_at'] ?? '', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: _getStatusColor(order['status']).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: TText(
                    order['status'] ?? "Confirmed",
                    style: TextStyle(color: _getStatusColor(order['status']), fontWeight: FontWeight.bold)
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const TText("Total Amount", style: TextStyle(fontWeight: FontWeight.w600)),
              Text(": ₹${order['total_amount']}", style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
          if (isExpanded) ...[
            const Divider(height: 30),
            const TText("Products", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: (order['items'] as List).length,
              itemBuilder: (context, i) {
                final item = order['items'][i];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // TText(item['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                            TText(
                                item['name']?.toString() ?? 'Unknown Product',
                                style: const TextStyle(fontWeight: FontWeight.bold)
                            ),
                            Row(
                              children: [
                                const TText("Qty", style: TextStyle(color: Colors.grey, fontSize: 13)),
                                // Text(": ${item['quantity']} x ₹${item['price']}", style: const TextStyle(color: Colors.grey, fontSize: 13)),
                                Text(
                                    ": ${item['quantity']?.toString() ?? '0'} x ₹${item['price']?.toString() ?? '0'}",
                                    style: const TextStyle(color: Colors.grey, fontSize: 13)
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (order['status']?.toLowerCase() == 'pending' || order['status']?.toLowerCase() == 'confirmed')
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => _confirmDelete(order['order_id'].toString(), order['payment_method'] ?? 'COD'),
                  )
              ],
            )
          ],
          Center(
            child: TextButton(
              onPressed: () => setState(() => expandedIndex = isExpanded ? null : index),
              child: TText(isExpanded ? "Hide Details" : "View Details"),
            ),
          )
        ],
      ),
    );
  }


  void _confirmDelete(String id, String paymentMethod) {
    String selectedValue = reasons[0];
    bool isOnline = paymentMethod.toLowerCase() == 'online';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const TText("Cancel Order?"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const TText("Reason for cancellation:", style: TextStyle(fontSize: 14)),
                const SizedBox(height: 10),
                DropdownButton<String>(
                  value: selectedValue,
                  isExpanded: true,
                  items: reasons.map((e) => DropdownMenuItem(value: e, child: TText(e))).toList(),
                  onChanged: (val) {
                    setDialogState(() => selectedValue = val!);
                  },
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const TText("Keep Order")),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  if (isOnline) {
                    _showRefundInfoDialog(id, selectedValue);
                  } else {
                    deleteOrder(id, selectedValue);
                  }
                },
                child: const TText("Cancel Order", style: TextStyle(color: Colors.red)),
              )
            ],
          );
        },
      ),
    );
  }

  void _showRefundInfoDialog(String id, String reason) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const TText("Refund Process"),
        content: const TText("Since you paid online, your refund will be processed within 5-7 days."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              deleteOrder(id, reason);
            },
            child: const TText("OK", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}