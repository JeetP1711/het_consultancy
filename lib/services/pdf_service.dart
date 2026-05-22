import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/quotation_model.dart';

class PdfService {
  PdfService._();

  static Future<Uint8List> generateQuotationPdf(QuotationModel q) async {
    final pdf = pw.Document();

    // Use Helvetica as standard font
    final font = pw.Font.helvetica();
    final fontBold = pw.Font.helveticaBold();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        theme: pw.ThemeData.withFont(
          base: font,
          bold: fontBold,
        ),
        header: (context) {
          return pw.Column(
            children: [
              pw.Row(
                mainpw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crosspw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'HET CONSULTANCY',
                        style: pw.TextStyle(
                          fontSize: 20,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColor.fromHex('#0F2027'),
                        ),
                      ),
                      pw.Text(
                        'Solar Energy Solutions Provider',
                        style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                      ),
                    ],
                  ),
                  pw.Column(
                    crosspw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('Proposal No: ${q.proposalNumber}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                      pw.Text('Date: ${q.date.day}/${q.date.month}/${q.date.year}', style: const pw.TextStyle(fontSize: 10)),
                    ],
                  ),
                ],
              ),
              pw.Divider(thickness: 1, color: PdfColors.grey400),
              pw.SizedBox(height: 10),
            ],
          );
        },
        footer: (context) {
          return pw.Column(
            children: [
              pw.Divider(thickness: 0.5, color: PdfColors.grey300),
              pw.Row(
                mainpw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('HET Consultancy | info@het.com | +91 98765 43210', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
                  pw.Text('Page ${context.pageNumber} of ${context.pagesCount}', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
                ],
              ),
            ],
          );
        },
        build: (context) => [
          // PAGE 1: Intro & Customer Details
          pw.SizedBox(height: 10),
          pw.Text('To,', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
          pw.Text(q.clientName, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
          pw.Text('Phone: ${q.clientPhone}', style: const pw.TextStyle(fontSize: 10)),
          pw.Text('Email: ${q.clientEmail}', style: const pw.TextStyle(fontSize: 10)),
          pw.Text('Site Address: ${q.clientAddress}', style: const pw.TextStyle(fontSize: 10)),
          
          pw.SizedBox(height: 24),
          pw.Text(
            'Subject: Proposal for Design, Engineering & Commissioning of ${q.capacity} kWp Rooftop Solar PV Power Plant',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12, decoration: pw.TextDecoration.underline),
          ),
          pw.SizedBox(height: 16),
          
          pw.Text(
            'Dear Sir/Madam,\n\nWe are pleased to submit our technical and commercial proposal for the installation of a rooftop solar photovoltaic power plant at your premises. Our proposal has been customized based on your site conditions, roof feasibility, and daily energy requirements.\n\nSolar energy represents a sustainable, cost-effective method to hedge against rising commercial grid tariffs while drastically reducing your carbon footprint. Below is our comprehensive proposal, bill of material deliverables, pricing details, and warranty specifications.',
            style: const pw.TextStyle(fontSize: 11, lineHeight: 1.4),
          ),
          
          pw.SizedBox(height: 32),
          pw.Row(
            mainpw.MainAxisAlignment.end,
            children: [
              pw.Column(
                crosspw.CrossAxisAlignment.end,
                children: [
                  pw.Text('For HET Consultancy', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
                  pw.SizedBox(height: 40),
                  pw.Text('Managing Partner Signature', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                ],
              ),
            ],
          ),
          
          pw.NewPage(),

          // PAGE 2: Deliverables & BOM
          pw.Text('1. BILL OF MATERIAL & TECHNICAL DELIVERABLES', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
          pw.SizedBox(height: 16),
          
          pw.TableHelper.fromTextArray(
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey900),
            cellAlignment: pw.Alignment.centerLeft,
            cellStyle: const pw.TextStyle(fontSize: 9),
            border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
            headers: ['SR NO', 'DESCRIPTION', 'QTY'],
            data: [
              ['1', 'Solar PV Modules (${q.panelBrand} - ${q.panelWattage}Wp Mono PERC)', '${q.panelQty} Nos'],
              ['2', 'On-Grid Solar String Inverter (${q.inverterBrand})', '${q.inverterQty} Nos'],
              ['3', q.structure.isNotEmpty ? q.structure : 'Hot-Dip Galvanized MS Structure', '1 Set'],
              ['4', q.dcdb.isNotEmpty ? q.dcdb : 'DCDB Box with SPD & Fuses', '1 Set'],
              ['5', q.acdb.isNotEmpty ? q.acdb : 'ACDB Box with MCB & SPD', '1 Set'],
              ['6', q.lightningArrestor.isNotEmpty ? q.lightningArrestor : 'Chemical Lightning Arrestor', '1 Set'],
              ['7', q.earthing.isNotEmpty ? q.earthing : 'Chemical Gel Earthing Electrode & pit', '3 Sets'],
              ['8', q.cable.isNotEmpty ? q.cable : 'DC/AC Power Cable runs', '1 Lot'],
              ['9', q.accessories.isNotEmpty ? q.accessories : 'Conduits, glands, MC4 couplers, fasteners', '1 Lot'],
            ],
          ),
          
          pw.NewPage(),

          // PAGE 3: Commercial Proposal & Bank Details
          pw.Text('2. COMMERCIAL PROPOSAL & PAYMENT DETAILS', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
          pw.SizedBox(height: 16),
          
          pw.TableHelper.fromTextArray(
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey900),
            cellAlignment: pw.Alignment.centerLeft,
            cellStyle: const pw.TextStyle(fontSize: 10),
            border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
            headers: ['DESCRIPTION', 'AMOUNT (INR)'],
            data: [
              ['Base System Cost (Supply, Civil & Electrical Installation)', 'Rs. ${q.price.toStringAsFixed(2)}'],
              ['Applicable Tax / GST (${q.taxRate}%)', 'Rs. ${q.taxAmount.toStringAsFixed(2)}'],
              ['Gross Total Proposal Value', 'Rs. ${q.totalAmount.toStringAsFixed(2)}'],
              ['Estimated Central Government Subsidy (PM-Surya Ghar)', '- Rs. ${q.subsidy.toStringAsFixed(2)}'],
              ['Net Investment Post Subsidy Benefit', 'Rs. ${q.netPayableAmount.toStringAsFixed(2)}'],
            ],
          ),

          pw.SizedBox(height: 24),
          pw.Text('Default Beneficiary Bank Account Details', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
          pw.SizedBox(height: 8),
          pw.Bullet(text: 'Account Name: ${q.accountName.isNotEmpty ? q.accountName : "HET CONSULTANCY SERVICES"}'),
          pw.Bullet(text: 'Bank Name: ${q.bankName.isNotEmpty ? q.bankName : "SBI Main"}'),
          pw.Bullet(text: 'Account Number: ${q.accountNumber.isNotEmpty ? q.accountNumber : "1234567890"}'),
          pw.Bullet(text: 'IFSC Code: ${q.ifscCode.isNotEmpty ? q.ifscCode : "SBIN0001234"}'),
          pw.Bullet(text: 'Branch: ${q.branch.isNotEmpty ? q.branch : "Pune"}'),

          pw.SizedBox(height: 24),
          pw.Text('Expected Installation Delivery: ${q.installationTime} working days post material mobilization.', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
          
          pw.NewPage(),

          // PAGE 4: Terms & Conditions
          pw.Text('3. STANDARD TERMS & WARRANTY POLICY', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
          pw.SizedBox(height: 16),
          
          pw.Text('Terms & Conditions:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
          pw.SizedBox(height: 8),
          pw.Text(q.terms.isNotEmpty ? q.terms : '1. Net-metering approval depends on local DISCOM grid feasibility.\n2. Civil structure guarantees 150 km/h wind resilience.'),
          
          pw.SizedBox(height: 24),
          pw.Text('Warranty Policy:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
          pw.SizedBox(height: 8),
          pw.Text(q.warranty.isNotEmpty ? q.warranty : 'Inverter: 5 Years\nModules: 10 Years product & 25 Years performance'),

          pw.SizedBox(height: 24),
          pw.Text('Customer Acceptance Signature', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
          pw.SizedBox(height: 48),
          pw.Row(
            mainpw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crosspw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Client Authorized Signatory', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                  pw.Text('Date: ____/____/________', style: const pw.TextStyle(fontSize: 10)),
                ],
              ),
              pw.Column(
                crosspw.CrossAxisAlignment.end,
                children: [
                  pw.Text('For HET Consultancy', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                  pw.Text('Authorized Signatory', style: const pw.TextStyle(fontSize: 10)),
                ],
              ),
            ],
          ),
        ],
      ),
    );

    return pdf.save();
  }

  static Future<void> printQuotation(QuotationModel q) async {
    final pdfBytes = await generateQuotationPdf(q);
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
      name: 'Proposal_${q.proposalNumber}.pdf',
    );
  }
}
