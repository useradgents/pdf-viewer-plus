# PDF Viewer Plus

`pdf_viewer_plus` is a Flutter package that provides a comprehensive PDF viewer with a collapsible thumbnail sidebar for easy navigation between pages.

## Features

- **Complete PDF Viewer**: View PDF documents with smooth page transitions
- **Collapsible Thumbnail Sidebar**: Navigate through PDF pages using thumbnails in a sidebar that can be shown or hidden
- **Flexible Source Support**: Load PDFs from URLs or local assets
- **Customizable Appearance**: Customize sidebar width, thumbnail height, background color, and more
- **Optimized Performance**: PDF data is loaded only once and shared between viewer and thumbnails

## Installation

Add this line to your `pubspec.yaml` file:
```yaml
dependencies:
  pdf_viewer_plus: ^1.0.0
```

Then, run the following command:
```bash
flutter pub get
```

## Usage

Here's a simple example of how to use the package:

```dart
import 'package:flutter/material.dart';
import 'package:pdf_viewer_plus/pdf_viewer_plus.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('PDF Viewer with Thumbnails')),
      body: PdfViewer(
        pdfPath: 'https://example.com/sample.pdf', // URL or asset path
        initialSidebarOpen: true,                  // Start with sidebar open
        sidebarWidth: 180,                         // Custom sidebar width
        thumbnailHeight: 160,                      // Custom thumbnail height
        sidebarBackgroundColor: Colors.grey[300]!, // Custom sidebar color
      ),
    );
  }
}
```

## Customization Options

The `PdfViewer` widget supports these customization options:

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `pdfPath` | String | required | URL or asset path to the PDF file |
| `initialSidebarOpen` | bool | false | Whether the sidebar is initially open |
| `sidebarWidth` | double | 160 | Width of the sidebar |
| `thumbnailHeight` | double | 150 | Height of each thumbnail |
| `sidebarBackgroundColor` | Color | Colors.grey | Background color of the sidebar |
| `selectedPageDecoration` | BoxDecoration? | null | Custom decoration for the selected page thumbnail |

## Dependencies

This package uses:
- [pdfx](https://pub.dev/packages/pdfx) for rendering PDFs
- [http](https://pub.dev/packages/http) for downloading remote PDF files

## Contributing

Contributions are welcome! Feel free to open an issue or submit a pull request.

## License

This package is distributed under the MIT License. See the [LICENSE](./LICENSE) file for more information.

---

## About UserAgents

UserAgents is a company specialized in developing high-quality mobile applications with Flutter using Lean & Agile methodologies. If you need a solution tailored to your requirements, don't hesitate to contact us via email or through our contact form!

We'd be delighted to discuss your projects and support you in your development journey 😊
