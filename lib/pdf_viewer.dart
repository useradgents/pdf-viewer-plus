import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pdf_viewer_plus/src/pdf_thumbnail_viewer.dart';
import 'package:pdf_viewer_plus/src/pdf_utils.dart';
import 'package:pdfx/pdfx.dart';

/// A widget that displays a PDF with a thumbnail sidebar for navigation.
///
/// This widget combines a PDF viewer with a sidebar that shows thumbnails
/// of all pages. Users can navigate through the PDF by swiping or
/// by tapping on thumbnails in the sidebar.
class PdfViewer extends StatefulWidget {
  /// Path to a PDF file. Can be a URL (starting with http:// or https://) or an asset path
  final String pdfPath;

  /// Whether the sidebar should be initially open
  final bool initialSidebarOpen;

  /// Width of the sidebar containing thumbnails
  final double sidebarWidth;

  /// Height of each thumbnail in the sidebar
  final double thumbnailHeight;

  /// Background color of the sidebar
  final Color sidebarBackgroundColor;

  /// Optional decoration for the selected page thumbnail
  final BoxDecoration? selectedPageDecoration;

  /// Creates a PdfViewer widget.
  ///
  /// The [pdfPath] parameter is required and should point to a valid PDF file.
  /// It can be either a URL (starting with http:// or https://) or an asset path.
  ///
  /// The [initialSidebarOpen] parameter determines whether the thumbnail sidebar
  /// is initially visible.
  ///
  /// The [sidebarWidth] parameter sets the width of the thumbnail sidebar.
  ///
  /// The [thumbnailHeight] parameter sets the height of each thumbnail in the sidebar.
  ///
  /// The [sidebarBackgroundColor] parameter sets the background color of the sidebar.
  ///
  /// The [selectedPageDecoration] parameter sets the decoration for the selected page thumbnail.
  const PdfViewer({
    super.key,
    required this.pdfPath,
    this.initialSidebarOpen = false,
    this.sidebarWidth = 160,
    this.thumbnailHeight = 150,
    this.sidebarBackgroundColor = Colors.grey,
    this.selectedPageDecoration,
  });

  @override
  State<PdfViewer> createState() => _PdfViewerState();
}

class _PdfViewerState extends State<PdfViewer> {
  late bool isSidebarOpen;
  late PdfControllerPinch pdfController;
  late int currentPage;
  late bool isPdfLoading;
  Uint8List? pdfBytes;

  @override
  void initState() {
    super.initState();
    currentPage = 1;
    isPdfLoading = true;
    isSidebarOpen = widget.initialSidebarOpen;
    _loadPdfData();
  }

  /// Loads the PDF data once and initializes both the controller and bytes for thumbnails
  Future<void> _loadPdfData() async {
    try {
      // Load PDF data once
      pdfBytes = await PdfUtils.loadPDF(widget.pdfPath);

      // Initialize controller with the same data
      pdfController = PdfControllerPinch(
        document: PdfDocument.openData(pdfBytes!),
      );

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint('Error loading PDF: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (pdfBytes == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      children: [
        const VerticalDivider(width: 1),
        Stack(
          children: [
            PdfViewPinch(
              controller: pdfController,
              onDocumentLoaded: (document) {
                setState(() {
                  isPdfLoading = false;
                });
                debugPrint('PDF loaded with ${document.pagesCount} pages.');
              },
              onPageChanged: (page) {
                setState(() {
                  currentPage = page;
                });
              },
            ),
            if (isPdfLoading) const Center(child: CircularProgressIndicator()),
          ],
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          transform: Matrix4.translationValues(
            isSidebarOpen ? 0 : -widget.sidebarWidth,
            0,
            0,
          ),
          child: SizedBox(
            width: widget.sidebarWidth,
            child: PDFThumbnailViewer(
              pdfBytes: pdfBytes,
              currentPage: currentPage,
              thumbnailHeight: widget.thumbnailHeight,
              backgroundColor: widget.sidebarBackgroundColor,
              selectedPageDecoration: widget.selectedPageDecoration,
              onPageChanged: (page) async {
                await pdfController.animateToPage(pageNumber: page);
                setState(() {
                  currentPage = page;
                });
              },
            ),
          ),
        ),
        AnimatedPositioned(
          duration: const Duration(milliseconds: 300),
          left: isSidebarOpen ? widget.sidebarWidth : 0,
          top: 20,
          child: GestureDetector(
            onTap: () {
              setState(() {
                isSidebarOpen = !isSidebarOpen;
              });
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 30),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(25),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  isSidebarOpen ? Icons.chevron_left : Icons.chevron_right,
                  size: 20,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
