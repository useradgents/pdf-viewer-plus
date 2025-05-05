import 'package:flutter/material.dart';
import 'package:pdf_viewer_plus/pdf_viewer_plus.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PDF Viewer Plus Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const PdfViewerExample(),
    );
  }
}

class PdfViewerExample extends StatelessWidget {
  const PdfViewerExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Viewer Plus Example'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: const PdfViewer(
        pdfPath:
            'https://ontheline.trincoll.edu/images/bookdown/sample-local-pdf.pdf',
        initialSidebarOpen: false,
        sidebarWidth: 180,
        thumbnailHeight: 160,
        sidebarBackgroundColor: Color(0xFFEEEEEE),
      ),
    );
  }
}
