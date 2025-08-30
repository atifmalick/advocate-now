import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

// ================== BILLING SCREEN ==================
class BillingScreen extends StatefulWidget {
  const BillingScreen({super.key});

  @override
  State<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> {
  final List<Invoice> invoices = [
    Invoice(
      id: "PK-2025",
      lawyer: "Adv. Ali Khan",
      date: DateTime(2025, 3, 15),
      amount: 2500,
      status: InvoiceStatus.paid,
      duration: "45 mins",
      type: ConsultationType.video,
    ),
    Invoice(
      id: "PK-22",
      lawyer: "Adv. Atif Malik",
      date: DateTime(2025, 1,),
      amount: 3500,
      status: InvoiceStatus.pending,
      duration: "1 hour",
      type: ConsultationType.inPerson,
    ),
  ];

  void _exportAllInvoices() {
    // Implement export logic
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export All Invoices'),
        content: const Text('Select export format:'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('PDF'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CSV'),
          ),
        ],
      ),
    );
  }

  void _downloadInvoice(Invoice invoice) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Downloading ${invoice.id}...'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _previewInvoice(Invoice invoice) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: Text('Invoice ${invoice.id}')),
          body: SfPdfViewer.asset(
            'assets/sample_invoice.pdf',
            initialScrollOffset: Offset.zero,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Billing & Invoices"),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_for_offline),
            onPressed: _exportAllInvoices,
            tooltip: 'Export All',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: invoices.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) => InvoiceCard(
                invoice: invoices[index],
                onDownload: () => _downloadInvoice(invoices[index]),
                onPreview: () => _previewInvoice(invoices[index]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: InvoiceStatus.values.map((status) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(status.name.toUpperCase()),
              selected: false,
              onSelected: (bool value) {},
              checkmarkColor: status.color,
              selectedColor: status.color.withOpacity(0.1),
              labelStyle: TextStyle(
                color: status.color,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ================== INVOICE CARD ==================
class InvoiceCard extends StatelessWidget {
  final Invoice invoice;
  final VoidCallback onDownload;
  final VoidCallback onPreview;

  const InvoiceCard({
    super.key,
    required this.invoice,
    required this.onDownload,
    required this.onPreview,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _InvoiceHeader(invoice: invoice),
            const SizedBox(height: 12),
            _ConsultationDetails(invoice: invoice),
            const Divider(height: 24),
            _InvoiceFooter(
              invoice: invoice,
              onPreview: onPreview,
              onDownload: onDownload,
            ),
          ],
        ),
      ),
    );
  }
}

class _InvoiceHeader extends StatelessWidget {
  final Invoice invoice;

  const _InvoiceHeader({required this.invoice});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          invoice.id,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: invoice.status.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: invoice.status.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                invoice.status.name.toUpperCase(),
                style: TextStyle(
                  color: invoice.status.color,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ConsultationDetails extends StatelessWidget {
  final Invoice invoice;

  const _ConsultationDetails({required this.invoice});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          invoice.lawyer,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        _DetailRow(
          icon: Icons.calendar_today_outlined,
          text: DateFormat('dd MMM yyyy • hh:mm a').format(invoice.date),
        ),
        _DetailRow(
          icon: invoice.type.icon,
          text: '${invoice.duration} • ${invoice.type.name}',
        ),
      ],
    );
  }
}

class _InvoiceFooter extends StatelessWidget {
  final Invoice invoice;
  final VoidCallback onPreview;
  final VoidCallback onDownload;

  const _InvoiceFooter({
    required this.invoice,
    required this.onPreview,
    required this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Total Amount',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            Text(
              'Rs,${invoice.amount}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.blue.shade800,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        //download the page
        Row(
          children: [
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                icon: Icon(Icons.download, size: 18),
                label: const Text('Download PDF'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade50,
                  foregroundColor: Colors.blue.shade800,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: onDownload,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ================== MONTHLY CHART ==================


// ================== DATA MODELS & ENUMS ==================
enum InvoiceStatus {
  paid(Colors.green),
  pending(Colors.orange);

  final Color color;
  const InvoiceStatus(this.color);

  String get name => toString().split('.').last;
}

enum ConsultationType {
  video(Icons.videocam, 'Video Call'),
  phone(Icons.phone, 'Phone Call'),
  inPerson(Icons.business, 'In-Person');

  final IconData icon;
  final String name;
  const ConsultationType(this.icon, this.name);
}

class Invoice {
  final String id;
  final String lawyer;
  final DateTime date;
  final double amount;
  final InvoiceStatus status;
  final String duration;
  final ConsultationType type;

  Invoice({
    required this.id,
    required this.lawyer,
    required this.date,
    required this.amount,
    required this.status,
    required this.duration,
    required this.type,
  });
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _DetailRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }
}