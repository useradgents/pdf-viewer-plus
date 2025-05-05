import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pdf_viewer_plus/src/pdf_utils.dart';
import 'package:pdfx/pdfx.dart';

/// A widget that displays thumbnails of PDF pages in a sidebar.
/// 
/// This is an internal widget used by PdfViewer.
class PDFThumbnailViewer extends StatefulWidget {
  /// Path to the PDF file. Only used if pdfBytes is null.
  final String? pdfPath;

  /// Pre-loaded PDF bytes. If provided, pdfPath will be ignored.
  final Uint8List? pdfBytes;

  /// The current page being displayed in the main PDF viewer.
  final int currentPage;

  /// Height of each thumbnail in the sidebar.
  final double thumbnailHeight;

  /// Optional decoration for the selected page thumbnail.
  final BoxDecoration? selectedPageDecoration;

  /// Background color of the sidebar.
  final Color backgroundColor;

  /// Callback that is called when a thumbnail is tapped to change the page.
  final Function(int) onPageChanged;

  /// Creates a _PDFThumbnailViewer widget.
  /// 
  /// Either [pdfPath] or [pdfBytes] must be provided.
  /// The [currentPage] is the page currently displayed in the main PDF viewer.
  /// The [onPageChanged] callback is called when a thumbnail is tapped.
  const PDFThumbnailViewer({
    super.key,
    this.pdfPath,
    this.pdfBytes,
    required this.currentPage,
    required this.onPageChanged,
    this.thumbnailHeight = 150,
    this.backgroundColor = Colors.grey,
    this.selectedPageDecoration,
  }) : assert(
         pdfPath != null || pdfBytes != null,
         'Either pdfPath or pdfBytes must be provided',
       );

  @override
  State<PDFThumbnailViewer> createState() => _PDFThumbnailViewerState();
}

class _PDFThumbnailViewerState extends State<PDFThumbnailViewer> {
  late final ScrollController _scrollController;
  late Future<Map<int, Uint8List>> thumbnailsFuture;
  bool isUserScroll = false;
  bool isSidebarOpen = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    thumbnailsFuture = _generateThumbnails();
  }

  @override
  void didUpdateWidget(PDFThumbnailViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentPage != widget.currentPage && !isUserScroll) {
      _onPageChanged();
    }

    // Regenerate thumbnails if the PDF source changes
    if ((oldWidget.pdfPath != widget.pdfPath) ||
        (oldWidget.pdfBytes != widget.pdfBytes)) {
      thumbnailsFuture = _generateThumbnails();
    }
  }

  Future<Map<int, Uint8List>> _generateThumbnails() async {
    final Map<int, Uint8List> thumbnails = {};
    try {
      final PdfDocument document;

      // Use pre-loaded bytes if available, otherwise load from path
      if (widget.pdfBytes != null) {
        document = await PdfDocument.openData(widget.pdfBytes!);
      } else {
        // This should never happen due to the assert in the constructor
        document = await PdfDocument.openData(
          await PdfUtils.loadPDF(widget.pdfPath!),
        );
      }

      for (var i = 1; i <= document.pagesCount; i++) {
        final page = await document.getPage(i);
        try {
          final pageImage = await page.render(
            width: page.width * 0.4,
            height: page.height * 0.4,
            backgroundColor: '#FFFFFF',
          );
          if (pageImage != null) {
            thumbnails[i] = pageImage.bytes;
          }
        } finally {
          await page.close();
        }
      }
      await document.close();
    } catch (e) {
      debugPrint('Error generating thumbnails: $e');
    }
    return thumbnails;
  }

  Future<void> _onPageChanged() async {
    final targetPosition =
        (widget.currentPage - 1) * (widget.thumbnailHeight + 16);

    await _scrollController.animateTo(
      targetPosition,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    child: ColoredBox(
      color: widget.backgroundColor,
      child: FutureBuilder<Map<int, Uint8List>>(
        future: thumbnailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('Erreur de chargement des miniatures'),
            );
          }

          return ListView.builder(
            controller: _scrollController,
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final pageNumber = index + 1;
              final isCurrentPage = pageNumber == widget.currentPage;

              return Padding(
                padding: const EdgeInsets.all(8),
                child: GestureDetector(
                  onTap: () async {
                    isUserScroll = true;
                    await widget.onPageChanged(pageNumber);
                    Future.delayed(const Duration(milliseconds: 100), () {
                      if (mounted) {
                        isUserScroll = false;
                      }
                    });
                  },
                  child: Center(
                    child: Container(
                      decoration:
                          isCurrentPage
                              ? (widget.selectedPageDecoration ??
                                  BoxDecoration(
                                    border: Border.all(
                                      color: Colors.blue,
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(4),
                                  ))
                              : null,
                      child: Image.memory(
                        snapshot.data![pageNumber]!,
                        fit: BoxFit.contain,
                        height: widget.thumbnailHeight,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    ),
  );

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}