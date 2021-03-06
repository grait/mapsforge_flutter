import '../../model/tag.dart';

import 'attributematcher.dart';

class NegativeMatcher implements AttributeMatcher {
  final List<String> keyList;
  final List<String> valueList;

  NegativeMatcher(this.keyList, this.valueList);

  @override
  bool isCoveredByAttributeMatcher(AttributeMatcher attributeMatcher) {
    return false;
  }

  @override
  bool matchesTagList(List<Tag> tags) {
    if (keyListDoesNotContainKeys(tags)) {
      return true;
    }

    for (int i = 0, n = tags.length; i < n; ++i) {
      if (this.valueList.contains(tags.elementAt(i).value)) {
        return true;
      }
    }
    return false;
  }

  bool keyListDoesNotContainKeys(List<Tag> tags) {
    for (int i = 0, n = tags.length; i < n; ++i) {
      if (this.keyList.contains(tags.elementAt(i).key)) {
        return false;
      }
    }
    return true;
  }

  @override
  String toString() {
    return 'NegativeMatcher{keyList: $keyList, valueList: $valueList}';
  }
}
