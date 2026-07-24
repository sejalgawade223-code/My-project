import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

class InvoiceService {
  static Future<void> generateInvoice({
    required String userName,
    required String address,
    required String contact,
    required List items,
    required double totalAmount,
    required String paymentMethod,
    required String paymentId,
    required String receiptNo,
  }) async {
    final pdf = pw.Document();
    final date = DateFormat('dd-MM-yyyy HH:mm').format(DateTime.now());

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text("FERTISMART", style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.green900)),
                      pw.Text("Agri Solutions Provider"),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text("RECEIPT / INVOICE", style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                      pw.Text("Receipt No: $receiptNo"),
                      pw.Text("Date: $date"),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Divider(),
              pw.SizedBox(height: 10),
              pw.Text("Customer Details:", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text("Name: $userName"),
              pw.Text("Address: $address"),
              pw.Text("Contact: $contact"),
              pw.SizedBox(height: 20),
              pw.TableHelper.fromTextArray(
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.green800),
                headers: ['Product Name', 'Qty', 'Price', 'Total'],
                data: items.map((item) {
                  double price = double.parse(item['price'].toString()) * 0.75;
                  int qty = int.parse(item['quantity'].toString());
                  return [
                    item['name'],
                    qty.toString(),
                    "Rs. ${price.toStringAsFixed(2)}",
                    "Rs. ${(price * qty).toStringAsFixed(2)}"
                  ];
                }).toList(),
              ),
              pw.Divider(),
              pw.Container(
                alignment: pw.Alignment.centerRight,
                child: pw.Text("Grand Total: Rs. ${totalAmount.toStringAsFixed(2)}",
                    style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
              ),
              pw.SizedBox(height: 30),
              pw.Text("Payment Method: $paymentMethod"),
              pw.Text("Transaction ID: $paymentId"),
              pw.SizedBox(height: 50),
              pw.Center(child: pw.Text("Thank you for your order!", style: pw.TextStyle(fontStyle: pw.FontStyle.italic))),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save(), name: 'Invoice_$receiptNo.pdf');
  }
}