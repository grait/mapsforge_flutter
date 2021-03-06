import '../model/latlong.dart';
import '../model/tag.dart';

/**
 * An immutable container for all data associated with a single point of interest node (POI).
 */
class PointOfInterest {
  /**
   * The layer of this POI + 5 (to avoid negative values).
   */
  final int layer;

  /**
   * The position of this POI.
   */
  final LatLong position;

  /**
   * The tags of this POI.
   */
  final List<Tag> tags;

  PointOfInterest(this.layer, this.tags, this.position);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PointOfInterest &&
          runtimeType == other.runtimeType &&
          layer == other.layer &&
          position == other.position &&
          tags == other.tags;

  @override
  int get hashCode => layer.hashCode ^ position.hashCode ^ tags.hashCode;
}
