import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import 'translated_text.dart';

class AdminOrderDetailPage extends StatefulWidget {
  final Map<String, dynamic> order;

  const AdminOrderDetailPage({super.key, required this.order});

  @override
  State<AdminOrderDetailPage> createState() => _AdminOrderDetailPageState();
}

class _AdminOrderDetailPageState extends State<AdminOrderDetailPage> {
  late String selectedStatus;
  late String selectedRefundStatus;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    selectedStatus = widget.order['status'] ?? 'Pending';
    selectedRefundStatus = widget.order['refund_status'] ?? 'Pending';
  }


  Future<void> updateStatus() async {
    setState(() => _isUpdating = true);
    try {
      await http.post(
        Uri.parse('${ApiConfig.baseUrl}admin_update_order_status.php'),
        body: {
          'order_id': widget.order['order_id'].toString(),
          'status': selectedStatus,
        },
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: TText("Status updated successfully!")),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint("Update error: $e");
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }


  Future<void> updateRefundStatus(String newRefundStatus) async {
    try {
      await http.post(
        Uri.parse('${ApiConfig.baseUrl}admin_update_refund_status.php'),
        body: {
          'order_id': widget.order['order_id'].toString(),
          'refund_status': newRefundStatus,
        },
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Refund Status Updated!")),
        );
      }
    } catch (e) {
      debugPrint("Refund Update error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final o = widget.order;

    final bool isCancelled = selectedStatus == 'Cancelled';
    final bool isOnline = o['payment_method']?.toString().toLowerCase() == 'online';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Row(
          children: [
            const TText("Order", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            Text(' #${o['order_id']}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          ],
        ),
        backgroundColor: isCancelled ? Colors.red[700] : Colors.green[700],
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            _buildSectionCard(
              icon: Icons.person_pin,
              title: "Customer Info",
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(o['customer_name'] ?? '', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  _infoRow(Icons.phone, "Phone", o['customer_contact'] ?? ''),
                  const SizedBox(height: 4),
                  _infoRow(Icons.location_on, "Address", o['customer_address'] ?? ''),
                ],
              ),
            ),


            _buildSectionCard(
              icon: Icons.list_alt,
              title: "Order Details",
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _infoRow(Icons.payment, "Payment", o['payment_method'] ?? ''),
                  _infoRow(Icons.currency_rupee, "Total", "₹${o['total_amount'] ?? ''}"),
                  _infoRow(Icons.calendar_today, "Date", o['created_at'] ?? ''),
                  const Divider(height: 30),
                  const TText("Order Status", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 10),

                  DropdownButtonFormField<String>(
                    value: selectedStatus,
                    items: ['Pending', 'Confirmed', 'Delivered', 'Cancelled'].map((status) {
                      return DropdownMenuItem(
                        value: status,
                        child: FutureBuilder<String>(
                          future: TranslationService.translate(status),
                          builder: (context, snapshot) => Text(snapshot.data ?? status),
                        ),
                      );
                    }).toList(),
                    onChanged: (v) => setState(() => selectedStatus = v!),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[50],
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ],
              ),
            ),


            if (isCancelled)
              _buildSectionCard(
                icon: Icons.cancel,
                title: "Cancellation Info",
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _infoRow(Icons.help_outline, "Reason", o['cancellation_reason'] ?? 'Other'),
                    _infoRow(Icons.date_range, "Cancelled On", o['cancel_date'] ?? 'N/A'),

                    if (isOnline) ...[
                      const Divider(height: 20),
                      const TText("Refund Status", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: selectedRefundStatus,
                        items: ['Pending', 'Processing', 'Refunded'].map((val) => DropdownMenuItem(value: val, child: Text(val))).toList(),
                        onChanged: (v) {
                          setState(() => selectedRefundStatus = v!);
                          updateRefundStatus(v!);
                        },
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.red[50],
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

            const SizedBox(height: 20),


            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isUpdating ? null : updateStatus,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isCancelled ? Colors.red[700] : Colors.green[700],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
                child: _isUpdating
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const TText('Update Status', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildSectionCard({required IconData icon, required String title, required Widget child}) {
    bool isRed = title == "Cancellation Info";
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: isRed ? Colors.red[700] : Colors.green[700], size: 20),
                const SizedBox(width: 8),
                TText(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isRed ? Colors.red[700] : Colors.green[700])),
              ],
            ),
            const SizedBox(height: 15),
            child,
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          TText("$label: ", style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black54)),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 14, color: Colors.black87))),
        ],
      ),
    );
  }
}
