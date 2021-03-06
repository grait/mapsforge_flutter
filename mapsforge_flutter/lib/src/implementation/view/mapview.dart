import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:logging/logging.dart';
import 'package:mapsforge_flutter/src/input/fluttergesturedetector.dart';
import 'package:mapsforge_flutter/src/layer/job/job.dart';
import 'package:mapsforge_flutter/src/layer/tilelayer.dart';
import 'package:mapsforge_flutter/src/marker/markerdatastore.dart';
import 'package:mapsforge_flutter/src/marker/markerpainter.dart';
import 'package:mapsforge_flutter/src/marker/markerrenderer.dart';
import 'package:mapsforge_flutter/src/model/mapmodel.dart';
import 'package:mapsforge_flutter/src/view/mapview.dart';
import 'package:provider/provider.dart';

import '../../../core.dart';
import 'backgroundpainter.dart';
import 'contextmenu.dart';
import 'tilepainter.dart';

class FlutterMapView extends StatefulWidget implements MapView {
  final MapModel mapModel;

  const FlutterMapView({
    Key key,
    @required this.mapModel,
  })  : assert(mapModel != null),
        super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _FlutterMapState();
  }
}

/////////////////////////////////////////////////////////////////////////////

class _FlutterMapState extends State<FlutterMapView> {
  static final _log = new Logger('_FlutterMapState');

  TileLayer _tileLayer;

  List<MarkerRenderer> _markerRenderer = List();

  GlobalKey _keyView = GlobalKey();

  @override
  void initState() {
    super.initState();
    _tileLayer = TileLayer(
      displayModel: widget.mapModel.displayModel,
      jobRenderer: widget.mapModel.renderer,
      bitmapCache: widget.mapModel.bitmapCache,
      graphicFactory: widget.mapModel.graphicsFactory,
    );
    widget.mapModel.markerDataStores.forEach((MarkerDataStore dataStore) {
      MarkerRenderer markerRenderer = MarkerRenderer(widget.mapModel.graphicsFactory, widget.mapModel.displayModel, dataStore);
      _markerRenderer.add(markerRenderer);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<MapViewPosition>(
      stream: widget.mapModel.observePosition,
      builder: (BuildContext context, AsyncSnapshot<MapViewPosition> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.hasPosition()) {
//            _log.info("I have a new position ${snapshot.data.toString()}");
            return _buildMapView(snapshot.data);
          }
          return _buildNoPositionView();
        }
        if (widget.mapModel.mapViewPosition != null && widget.mapModel.mapViewPosition.hasPosition()) {
//          _log.info("I have an old position ${widget.mapModel.mapViewPosition.toString()}");
          return _buildMapView(widget.mapModel.mapViewPosition);
        }
        return _buildNoPositionView();
      },
    );
  }

  Widget _buildNoPositionView() {
    return widget.mapModel.noPositionView.buildNoPositionView(context, widget.mapModel);
  }

  Widget _buildMapView(MapViewPosition position) {
    List<Widget> _widgets;

    _widgets = List();
    if (widget.mapModel.displayModel.backgroundColor != Colors.transparent.value) {
      _widgets.add(
        CustomPaint(
          foregroundPainter: BackgroundPainter(
              mapViewDimension: widget.mapModel.mapViewDimension, position: position, displayModel: widget.mapModel.displayModel),
          child: Container(),
        ),
      );
    }

    _widgets.add(
      StreamBuilder<Job>(
        stream: _tileLayer.observeJob,
        builder: (BuildContext context, AsyncSnapshot<Job> snapshot) {
          if (snapshot.hasData) {
            _tileLayer.jobResult(snapshot.data);
          }
          return CustomPaint(
            foregroundPainter: TilePainter(widget.mapModel.mapViewDimension, _tileLayer, position),
            child: Container(),
          );
        },
      ),
    );

    _widgets.addAll(_markerRenderer
        .map(
          (MarkerRenderer markerRenderer) => ChangeNotifierProvider<MarkerDataStore>.value(
            child: Consumer<MarkerDataStore>(
              builder: (BuildContext context, MarkerDataStore value, Widget child) {
                return CustomPaint(
                  foregroundPainter: MarkerPainter(
                      mapViewDimension: widget.mapModel.mapViewDimension,
                      position: position,
                      displayModel: widget.mapModel.displayModel,
                      markerRenderer: markerRenderer),
                  child: Container(),
                );
              },
            ),
            value: markerRenderer.dataStore,
          ),
        )
        .toList());

    return Stack(
      key: _keyView,
      children: <Widget>[
        FlutterGestureDetector(
          mapModel: widget.mapModel,
          position: position,
          child: Stack(
            children: _widgets,
          ),
        ),
        StreamBuilder<TapEvent>(
          stream: widget.mapModel.observeTap,
          builder: (BuildContext context, AsyncSnapshot<TapEvent> snapshot) {
            if (!snapshot.hasData) return Container();
            TapEvent event = snapshot.data;
            return ContextMenu(
              mapModel: widget.mapModel,
              position: position,
              event: event,
              contextMenuBuilder: widget.mapModel.contextMenuBuilder,
            );
          },
        ),
      ],
    );
  }
}
