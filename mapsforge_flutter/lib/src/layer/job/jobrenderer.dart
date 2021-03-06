import 'dart:ui';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:mapsforge_flutter/src/graphics/tilebitmap.dart';
import 'package:mapsforge_flutter/src/implementation/graphics/fluttertilebitmap.dart';
import 'package:mapsforge_flutter/src/model/tile.dart';
import 'package:mapsforge_flutter/src/renderer/rendererjob.dart';

abstract class JobRenderer {
  FlutterTileBitmap _missingBitmap;

  FlutterTileBitmap _noDataBitmap;

  Future<TileBitmap> executeJob(RendererJob job);

  String getRenderKey();

  static final double margin = 5;

  @override
  TileBitmap getMissingBitmap(Tile tile) {
    if (_missingBitmap != null) return _missingBitmap;
    _createMissingBitmap(tile.tileSize);
    return null;
  }

  void _createMissingBitmap(double tileSize) async {
    var pictureRecorder = ui.PictureRecorder();
    var canvas = ui.Canvas(pictureRecorder);
    var paint = ui.Paint();
    paint.strokeWidth = 1;
    paint.color = ui.Color(0xffaaaaaa);
    paint.isAntiAlias = true;

    canvas.drawLine(ui.Offset(margin, margin), ui.Offset(tileSize - margin, margin), paint);
    canvas.drawLine(ui.Offset(margin, margin), ui.Offset(margin, tileSize - margin), paint);
    canvas.drawLine(ui.Offset(tileSize - margin, margin), ui.Offset(tileSize - margin, tileSize - margin), paint);
    canvas.drawLine(ui.Offset(margin, tileSize - margin), ui.Offset(tileSize - margin, tileSize - margin), paint);

    ui.ParagraphBuilder builder = ui.ParagraphBuilder(
      ui.ParagraphStyle(fontSize: 10.0, textAlign: TextAlign.center),
    )
      ..pushStyle(ui.TextStyle(color: paint.color))
      ..addText("Waiting for rendering...");
    canvas.drawParagraph(builder.build()..layout(ui.ParagraphConstraints(width: tileSize)), Offset(0, tileSize / 2));

    var pic = pictureRecorder.endRecording();
    ui.Image img = await pic.toImage(tileSize.toInt(), tileSize.toInt());
//    var byteData = await img.toByteData(format: ui.ImageByteFormat.png);
//    var buffer = byteData.buffer.asUint8List();

    _missingBitmap = FlutterTileBitmap(img);
  }

  @override
  Future<TileBitmap> getNoDataBitmap(Tile tile) async {
    if (_noDataBitmap != null) return _noDataBitmap;
    return _createNoDataBitmap(tile.tileSize);
    return null;
  }

  Future<TileBitmap> _createNoDataBitmap(double tileSize) async {
    var pictureRecorder = ui.PictureRecorder();
    var canvas = ui.Canvas(pictureRecorder);
    var paint = ui.Paint();
    paint.strokeWidth = 1;
    paint.color = ui.Color(0xffaaaaaa);
    paint.isAntiAlias = true;

    canvas.drawLine(ui.Offset(margin, margin), ui.Offset(tileSize - margin, margin), paint);
    canvas.drawLine(ui.Offset(margin, margin), ui.Offset(margin, tileSize - margin), paint);
    canvas.drawLine(ui.Offset(tileSize - margin, margin), ui.Offset(tileSize - margin, tileSize - margin), paint);
    canvas.drawLine(ui.Offset(margin, tileSize - margin), ui.Offset(tileSize - margin, tileSize - margin), paint);

    ui.ParagraphBuilder builder = ui.ParagraphBuilder(
      ui.ParagraphStyle(fontSize: 14.0, textAlign: TextAlign.center),
    )
      ..pushStyle(ui.TextStyle(color: Colors.red))
      ..addText("No data available");
    canvas.drawParagraph(builder.build()..layout(ui.ParagraphConstraints(width: tileSize)), Offset(0, tileSize / 2));

    var pic = pictureRecorder.endRecording();
    ui.Image img = await pic.toImage(tileSize.toInt(), tileSize.toInt());
//    var byteData = await img.toByteData(format: ui.ImageByteFormat.png);
//    var buffer = byteData.buffer.asUint8List();

    _noDataBitmap = FlutterTileBitmap(img);
    return _noDataBitmap;
  }

  @override
  Future<TileBitmap> getErrorBitmap(Tile tile, dynamic error) async {
    return _createErrorBitmap(tile.tileSize, error);
    return null;
  }

  Future<TileBitmap> _createErrorBitmap(double tileSize, dynamic error) async {
    var pictureRecorder = ui.PictureRecorder();
    var canvas = ui.Canvas(pictureRecorder);
    var paint = ui.Paint();
    paint.strokeWidth = 1;
    paint.color = ui.Color(0xffaaaaaa);
    paint.isAntiAlias = true;

    canvas.drawLine(ui.Offset(margin, margin), ui.Offset(tileSize - margin, margin), paint);
    canvas.drawLine(ui.Offset(margin, margin), ui.Offset(margin, tileSize - margin), paint);
    canvas.drawLine(ui.Offset(tileSize - margin, margin), ui.Offset(tileSize - margin, tileSize - margin), paint);
    canvas.drawLine(ui.Offset(margin, tileSize - margin), ui.Offset(tileSize - margin, tileSize - margin), paint);

    ui.ParagraphBuilder builder = ui.ParagraphBuilder(
      ui.ParagraphStyle(fontSize: 10.0, textAlign: TextAlign.center),
    )
      ..pushStyle(ui.TextStyle(color: Colors.black87))
      ..addText("${error?.toString() ?? "Error"}");
    canvas.drawParagraph(builder.build()..layout(ui.ParagraphConstraints(width: tileSize - margin * 2)), Offset(margin, margin));

    var pic = pictureRecorder.endRecording();
    ui.Image img = await pic.toImage(tileSize.toInt(), tileSize.toInt());
//    var byteData = await img.toByteData(format: ui.ImageByteFormat.png);
//    var buffer = byteData.buffer.asUint8List();

    FlutterTileBitmap tileBitmap = FlutterTileBitmap(img);
    return tileBitmap; //Future.value(tileBitmap);
  }
}
