import 'package:excel/excel.dart';
import 'package:file_saver/file_saver.dart';
import 'package:intl/intl.dart';
import 'dart:typed_data';

class ExcelRowData {
  final String time;
  final String plate;
  final String model;
  final String service;
  final String staff;
  final double price;

  ExcelRowData({
    required this.time,
    required this.plate,
    required this.model,
    required this.service,
    required this.staff,
    required this.price,
  });
}

class ExcelReportService {
  static Future<void> exportWashReports(
      List<ExcelRowData> rows, String periodName) async {
    final excel = Excel.createExcel();
    final sheetName = 'Wash Report - ${periodName.toUpperCase()}';
    // Excel sheet name limit is 31 chars
    final safeSheetName =
        sheetName.length > 31 ? sheetName.substring(0, 31) : sheetName;
    final sheet = excel[safeSheetName];
    excel.delete('Sheet1'); // Remove default sheet

    // 1. Define Styles
    final CellStyle headerStyle = CellStyle(
      bold: true,
      horizontalAlign: HorizontalAlign.Center,
      backgroundColorHex:
          ExcelColor.fromHexString('#F1F5F9'), // Light Slate grey
      fontFamily: getFontFamily(FontFamily.Arial),
    );

    final CellStyle totalLabelStyle = CellStyle(
      bold: true,
      horizontalAlign: HorizontalAlign.Right,
    );

    final CellStyle totalValueStyle = CellStyle(
      bold: true,
      horizontalAlign: HorizontalAlign.Center,
      fontColorHex: ExcelColor.fromHexString('#2979FF'),
    );

    // 2. Add Headers
    final List<String> headers = [
      'Time',
      'Plate Number',
      'Car Brand/Model',
      'Service/Package',
      'Washer Staff',
      'Price (ETB)'
    ];

    sheet.appendRow(headers.map((h) => TextCellValue(h)).toList());

    // Apply header style
    for (var i = 0; i < headers.length; i++) {
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0))
          .cellStyle = headerStyle;
    }

    // 3. Add Data Rows
    double totalRevenue = 0;
    for (var row in rows) {
      totalRevenue += row.price;

      sheet.appendRow([
        TextCellValue(row.time),
        TextCellValue(row.plate),
        TextCellValue(row.model),
        TextCellValue(row.service),
        TextCellValue(row.staff),
        DoubleCellValue(row.price),
      ]);
    }

    // 4. Add Empty Row for separation
    sheet.appendRow([TextCellValue('')]);

    // 5. Add Total Row
    final totalRowIndex = rows.length + 2; // +1 for header, +1 for empty row

    // Ensure row exists by appending an empty one
    sheet.appendRow(List.generate(headers.length, (_) => TextCellValue('')));

    // Set Total Label
    final labelCell = sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: totalRowIndex));
    labelCell.value = TextCellValue('TOTAL SALES');
    labelCell.cellStyle = totalLabelStyle;

    // Set Total Value
    final valueCell = sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: totalRowIndex));
    valueCell.value = TextCellValue('${totalRevenue.toStringAsFixed(0)} ETB');
    valueCell.cellStyle = totalValueStyle;

    // 6. Column Widths
    sheet.setColumnWidth(0, 15); // Time
    sheet.setColumnWidth(1, 20); // Plate
    sheet.setColumnWidth(2, 25); // Model
    sheet.setColumnWidth(3, 30); // Service
    sheet.setColumnWidth(4, 25); // Staff
    sheet.setColumnWidth(5, 15); // Price

    // 7. Save File
    final fileBytes = excel.save();
    if (fileBytes != null) {
      final String fileName =
          'MekinaWash_Report_${periodName}_${DateFormat('yyyyMMdd').format(DateTime.now())}';

      await FileSaver.instance.saveFile(
        name: fileName,
        bytes: Uint8List.fromList(fileBytes),
        ext: 'xlsx',
        mimeType: MimeType.microsoftExcel,
      );
    }
  }
}
