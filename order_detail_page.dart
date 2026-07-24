import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:razorpay_flutter/razorpay_flutter.dart';

import 'session_manager.dart';
import 'edit_profile.dart';
import 'order_history_page.dart';
import 'api_config.dart';
import 'invoice_service.dart';
import 'translated_text.dart';

class OrderDetailPage extends StatefulWidget {
  final List cartItems;
  final double totalAmount;

  const OrderDetailPage({
    super.key,
    required this.cartItems,
    required this.totalAmount,
  });

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  String paymentMethod = "COD";
  Map<String, dynamic> user = {};
  bool loading = true;

  late Razorpay _razorpay;
  double grandTotalGlobal = 0;
  String currentReceiptNo = "";


  @override
  void initState() {
    super.initState();
    fetchUser();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, (PaymentSuccessResponse res) => saveOrder(res.paymentId, res.orderId));
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, (PaymentFailureResponse res) => _showPaymentError(res.message.toString()));
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  Future<void> fetchUser() async {
    try {
      final uid = await SessionManager.getUserId();
      final res = await http.get(Uri.parse("${ApiConfig.baseUrl}get_profile.php?u_id=$uid"));
      final decoded = jsonDecode(res.body);
      if (decoded["success"] == true) {
        setState(() => user = Map<String, dynamic>.from(decoded["user"]));
      }
    } catch (e) {
      debugPrint("PROFILE ERROR: $e");
    }
    setState(() => loading = false);
  }

  Future<void> saveOrder(String? paymentId, String? razorpayOrderId) async {
    final uid = await SessionManager.getUserId();
    Map<String, String> body = {
      "u_id": uid.toString(),
      "customer_name": user['name'] ?? 'Guest',
      "customer_address": user['address'] ?? 'N/A',
      "customer_contact": user['contact_no'] ?? 'N/A',
      "payment_method": paymentMethod,
      "total_amount": grandTotalGlobal.toStringAsFixed(2),
      "payment_id": paymentId ?? "",
      "razorpay_order_id": razorpayOrderId ?? "",
      "cart_items": jsonEncode(widget.cartItems),
    };

    try {
      final res = await http.post(Uri.parse("${ApiConfig.baseUrl}place_order_dummy.php"), body: body);
      final data = json.decode(res.body);
      if (data['status'] == "success") {
        setState(() => currentReceiptNo = data['receipt_no']);
        showOrderSuccessPopup(paymentId ?? "COD-TXN");
      }
    } catch (e) {
      _showPaymentError("Server Error: $e");
    }
  }

  void showOrderSuccessPopup(String txnId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Icon(Icons.check_circle, color: Colors.green, size: 60),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const TText("Order placed successfully!", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            ElevatedButton.icon(
              onPressed: () => InvoiceService.generateInvoice(
                userName: user['name'] ?? 'Customer',
                address: user['address'] ?? 'N/A',
                contact: user['contact_no'] ?? 'N/A',
                items: widget.cartItems,
                totalAmount: grandTotalGlobal,
                paymentMethod: paymentMethod,
                paymentId: txnId,
                receiptNo: currentReceiptNo,
              ),
              icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
              label: const TText("Download Bill", style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            )
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const OrderHistoryPage()));
            },
            child: const TText("View Orders"),
          )
        ],
      ),
    );
  }

  void _showPaymentError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: TText(msg), backgroundColor: Colors.red));
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    double subtotal = widget.totalAmount;
    double deliveryFee = subtotal > 500 ? 0.0 : 45.0;
    double gst = subtotal * 0.05;
    double grandTotal = subtotal + deliveryFee + gst;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F2),
      appBar: AppBar(
        title: const TText("Checkout", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.black),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const OrderHistoryPage()));
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _sectionHeader("Shipping Address"),
          _buildAddressCard(),
          const SizedBox(height: 20),
          _sectionHeader("Order Summary"),
          _buildOrderSummary(),
          const SizedBox(height: 20),
          _sectionHeader("Payment Method"),
          _buildPaymentOptions(),
          const SizedBox(height: 20),
          _sectionHeader("Bill Details"),
          _buildBillDetails(subtotal, deliveryFee, gst, grandTotal),
          const SizedBox(height: 100),
        ]),
      ),
      bottomSheet: _buildBottomButton(grandTotal),
    );
  }

  Widget _buildAddressCard() {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          const Icon(Icons.home_outlined, color: Colors.green),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user['name'] ?? 'User', style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(user['address'] ?? 'Add address in profile', style: const TextStyle(color: Colors.black54)),
                Text(user['contact_no'] ?? '', style: const TextStyle(color: Colors.black54, fontSize: 12)),
              ],
            ),
          ),
          IconButton(
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EditProfilePage())
              ).then((_) => fetchUser()),
              icon: const Icon(Icons.chevron_right)
          )
        ],
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: ListView.separated(
        shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
        itemCount: widget.cartItems.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final item = widget.cartItems[index];
          double price = double.tryParse(item['price'].toString()) ?? 0;
          return ListTile(
            title: TText(item['name'], style: const TextStyle(fontSize: 14)),
            subtitle: Row(
              children: [
                const TText("Qty"),
                Text(": ${item['quantity']}"),
              ],
            ),
            trailing: Text("₹${(price * 0.75).toStringAsFixed(0)}", style: const TextStyle(fontWeight: FontWeight.bold)),
          );
        },
      ),
    );
  }

  Widget _buildPaymentOptions() {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(children: [
        RadioListTile(value: "COD", groupValue: paymentMethod, activeColor: Colors.green, title: const TText("Cash on Delivery (COD)"), onChanged: (val) => setState(() => paymentMethod = val!)),
        RadioListTile(value: "Online", groupValue: paymentMethod, activeColor: Colors.green, title: const TText("Online Payment / UPI"), onChanged: (val) => setState(() => paymentMethod = val!)),
      ]),
    );
  }

  Widget _buildBillDetails(double sub, double dev, double gst, double grand) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(children: [
        _priceRow("Item Total", "₹${sub.toStringAsFixed(2)}"),
        _priceRow("Delivery Fee", dev == 0 ? "FREE" : "₹$dev", isGreen: dev == 0),
        _priceRow("GST (5%)", "₹${gst.toStringAsFixed(2)}"),
        const Divider(),
        _priceRow("To Pay", "₹${grand.toStringAsFixed(2)}", isBold: true),
      ]),
    );
  }

  Widget _buildBottomButton(double total) {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: ElevatedButton(
        onPressed: () {
          grandTotalGlobal = total;
          if (paymentMethod == "Online") {
            _razorpay.open({
              'key': 'rzp_test_SJWTklpQhWQcfM',
              'amount': (total * 100).round(),
              'name': 'Fertismart',
              'prefill': {'contact': user['contact_no'] ?? '', 'email': user['email'] ?? ''}
            });
          } else {
            saveOrder(null, null);
          }
        },
        style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade800, minimumSize: const Size(double.infinity, 55)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const TText("PLACE ORDER", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            Text(" • ₹${total.toStringAsFixed(2)}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) => Padding(padding: const EdgeInsets.only(bottom: 8, left: 4), child: TText(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)));

  Widget _priceRow(String label, String value, {bool isBold = false, bool isGreen = false}) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      TText(label, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
      isGreen ? TText(value, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: Colors.green)) : Text(value, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
    ]));
  }
}