import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import 'translated_text.dart';

class AdminPaymentHistory extends StatefulWidget {
  const AdminPaymentHistory({super.key});

  @override
  State<AdminPaymentHistory> createState() => _AdminPaymentHistoryState();
}

class _AdminPaymentHistoryState extends State<AdminPaymentHistory> {
  List payments = [];
  bool isLoading = true;
  String selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    fetchPayments();
  }

  Future<void> fetchPayments() async {
    if (!mounted) return;
    setState(() => isLoading = true);

    try {
      final response = await http.get(
        Uri.parse("${ApiConfig.baseUrl}admin_get_payments.php?filter=$selectedFilter"),
      );

      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);
        if (mounted) {
          setState(() {
            payments = (decodedData is List) ? decodedData : [];
            isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
          payments = [];
        });
        _showSnack("Error: $e");
      }
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: TText(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const TText("Payment History",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.green[700],
        elevation: 0,
      ),
      body: Column(
        children: [
          // Filter Section
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const TText("Filter Payment:",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                DropdownButton<String>(
                  value: selectedFilter,
                  underline: Container(),
                  dropdownColor: Colors.white,
                  items: ['All', 'Online', 'COD'].map((value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    if (newValue != null) {
                      setState(() => selectedFilter = newValue);
                      fetchPayments();
                    }
                  },
                ),
              ],
            ),
          ),

          // Payments List
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.green))
                : payments.isEmpty
                ? const Center(child: TText("No transactions found.",
                style: TextStyle(color: Colors.grey)))
                : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 10),
              itemCount: payments.length,
              itemBuilder: (context, index) {
                final item = payments[index];
                bool isOnline = item['payment_method'] == 'Online';
                String status = item['payment_status'] ?? 'Unpaid';

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
                  elevation: 1,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        CircleAvatar(
                          radius: 25,
                          backgroundColor: isOnline ? Colors.blue[50] : Colors.orange[50],
                          child: Icon(
                            isOnline ? Icons.account_balance : Icons.payments_outlined,
                            color: isOnline ? Colors.blue : Colors.orange,
                          ),
                        ),
                        const SizedBox(width: 12),


                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${item['customer_name']}",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 5),
                              _infoRow("Order ID", "#${item['order_id']}"),
                              _infoRow("Ref", "${item['payment_id']}"),
                              _infoRow("Date", "${item['created_at']}"),
                            ],
                          ),
                        ),


                        const SizedBox(width: 8),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "₹${item['amount']}",
                              style: TextStyle(
                                  color: Colors.green[700],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: status.toLowerCase() == 'paid'
                                    ? Colors.green[600]
                                    : Colors.red[400],
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: TText(
                                status,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }


  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TText("$label: ",
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 11, color: Colors.black87),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}