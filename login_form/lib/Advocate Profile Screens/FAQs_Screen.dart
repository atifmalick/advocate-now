import 'package:flutter/material.dart';

class FAQScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('FAQs'),
        elevation: 1,
      ),
      body: ListView(
        children: [
          SectionHeader(
            title: 'General Questions',
            icon: Icons.help_outline,
            iconColor: Colors.blue[800]!,
          ),
          _buildExpansionTile(
            'How do I verify a lawyer\'s credentials?',
            'All legal professionals on Advocate Now undergo a rigorous 3-step verification process:\n\n'
                '1. Bar Council registration validation\n'
                '2. Practice certificate authentication\n'
                '3. Background check through legal directories\n\n'
                'You can view verification badges directly on lawyer profiles.',
          ),
          _buildExpansionTile(
            'What types of legal issues can I consult about?',
            'Our platform covers 25+ legal specialties including:\n'
                '• Corporate Law\n• Criminal Defense\n• Family Law\n• IP Rights\n• Civil Disputes\n• Property Matters\n\n'
                'If you\'re unsure about your legal category, use our "Guidance Assistant" feature.',
          ),
          _buildExpansionTile(
            'How quickly can I get a consultation?',
            'Availability depends on the lawyer\'s schedule:\n\n'
                '- Emergency consultations: Within 2 hours (premium rate)\n'
                '- Standard appointments: Next available slot\n'
                '- Scheduled meetings: Up to 7 days in advance\n\n'
                'Use our "Urgent Request" filter for immediate availability.',
          ),

          _buildExpansionTile(
            'Can I reschedule or cancel a booking?',
            'Rescheduling policies:\n\n'
                '• Free changes up to 24 hours before appointment\n'
                '• 50% charge for changes within 12-24 hours\n'
                '• No refunds within 12 hours of meeting\n\n'
                'Modify bookings through "Upcoming Appointments" section.',
          ),
          _buildExpansionTile(
            'What happens if my lawyer misses the appointment?',
            'In rare cases of professional no-shows:\n\n'
                '1. Automatic 15-minute grace period\n'
                '2. Platform-initiated rescheduling\n'
                '3. Full refund if not resolved in 48 hours\n\n'
                'All incidents affect lawyer ratings.',
          ),
          _buildExpansionTile(
            'Are consultations confidential?',
            'We enforce strict confidentiality measures:\n\n'
                '• End-to-end encrypted video calls\n'
                '• Secure document storage (ISO 27001 certified)\n'
                '• No third-party data sharing\n'
                '• Automatic chat history deletion after 30 days\n\n'
                'Review our Privacy Policy for details.',
          ),

          _buildExpansionTile(
            'What payment methods are accepted?',
            'We support multiple secure payment options:\n\n'
                '• Credit/Debit Cards (Visa, MasterCard, Amex)\n'
                '• UPI Payments (GPay, PhonePe, Paytm)\n'
                '• Net Banking (All major Indian banks)\n'
                '• Wallet Credits (Platform balance)\n\n'
                'All transactions are PCI-DSS compliant.',
          ),
          _buildExpansionTile(
            'How do I get receipts for tax purposes?',
            'Automated GST invoices are:\n\n'
                '• Generated immediately after payment\n'
                '• Available in "Billing History" section\n'
                '• Customizable with firm/personal details\n'
                '• Valid for IT filing and business expenses\n\n'
                'Download as PDF or share via email.',
          ),
          _buildExpansionTile(
            'Is my financial data secure?',
            'We employ bank-grade security measures:\n\n'
                '• Tokenized payment processing\n'
                '• PCI-DSS Level 1 certification\n'
                '• 3D Secure authentication\n'
                '• Regular security audits\n\n'
                'Never store raw card information.',
          ),
         
          _buildExpansionTile(
            'How to delete my account permanently?',
            'Account deletion process:\n\n'
                '1. Go to Settings > Privacy\n'
                '2. Request Data Erasure\n'
                '3. Verify identity via OTP\n'
                '4. Confirm deletion (irreversible)\n\n'
                'Note: Ongoing cases must be resolved first.',
          ),
          _buildExpansionTile(
            'Can I use multiple devices simultaneously?',
            'Device management features:\n\n'
                '• 3 active devices allowed\n'
                '• Real-time session monitoring\n'
                '• Remote logout capability\n'
                '• Suspicious activity alerts\n\n'
                'Manage devices in Security Settings.',
          ),
        ],
      ),
    );
  }

  ExpansionTile _buildExpansionTile(String question, String answer) {
    return ExpansionTile(
      title: Text(question, style: TextStyle(fontWeight: FontWeight.w500)),
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Text(answer,
              style: TextStyle(height: 1.4, color: Colors.grey[700])),
        ),
      ],
    );
  }
}

// Reusable Section Header Component
class SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;

  const SectionHeader({
    required this.title,
    required this.icon,
    this.iconColor = Colors.blue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!, width: 1),
        ),
      ),
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 24),
          SizedBox(width: 16),
          Text(title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
                letterSpacing: 0.5,
              )),
        ],
      ),
    );
  }
}