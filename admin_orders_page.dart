import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'admin_order_detail_page.dart';
import 'api_config.dart';
import 'translated_text.dart';

class AdminOrdersPage extends StatefulWidget {
  const AdminOrdersPage({super.key});

  @override
  State<AdminOrdersPage> createState() => _AdminOrdersPageState();
}

class _AdminOrdersPageState extends State<AdminOrdersPage> {
  List orders = [];
  bool loading = true;
  final ScrollController _scrollController = ScrollController();

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
    try {
      final res = await http.get(Uri.parse("${ApiConfig.baseUrl}admin_get_orders.php"));
      if (res.statusCode == 200) {
        if (mounted) {
          setState(() {
            orders = jsonDecode(res.body);
            loading = false;
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching orders: $e");
      if (mounted) setState(() => loading = false);
    }
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return Colors.orange;
      case 'completed':
      case 'delivered': return Colors.green;
      case 'cancelled': return Colors.red;
      default: return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const TText("FertiSmart Orders", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.green[700],
        elevation: 0,
        centerTitle: true,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : orders.isEmpty
          ? const Center(child: TText("No orders found", style: TextStyle(fontSize: 16, color: Colors.grey)))
          : Scrollbar(
        controller: _scrollController,
        thumbVisibility: true,
        thickness: 6,
        radius: const Radius.circular(10),
        child: ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(vertical: 12),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final o = orders[index];
            final statusStr = o['status'] ?? 'Pending';
            final statusColor = getStatusColor(statusStr);

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.green[50],
                  child: Icon(Icons.receipt_long, color: Colors.green[700]),
                ),
                title: Row(
                  children: [
                    const TText("Order", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(" #${o['order_id']}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow(Icons.person_outline, "Customer", o['customer_name'] ?? ''),
                      const SizedBox(height: 4),
                      _buildInfoRow(Icons.currency_rupee, "Amount", "₹${o['total_amount']}"),
                      const SizedBox(height: 10),

                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: statusColor.withOpacity(0.5)),
                        ),
                        child: TText(
                          statusStr,
                          style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                ),
                trailing: Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey[400]),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AdminOrderDetailPage(order: o)),
                  ).then((_) => fetchOrders());
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 6),
        TText("$label: ", style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w500)),
        Expanded(
          child: Text(value, style: const TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w500)),
        ),
      ],
    );
  }
}
