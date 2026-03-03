/// Returns the numeric index embedded in a texture atlas frame name.
/// e.g. "bird_042.png" → 42, "frame3" → 3
func frameIndex(from textureName: String) -> Int {
    let digits = textureName.filter(\.isNumber)
    return Int(digits) ?? 0
}

/// Sorts texture atlas frame names in ascending frame order, parsing each
/// name's numeric index only once to avoid repeated work during comparison.
func sortedByFrameIndex(_ names: [String]) -> [String] {
    names
        .map { ($0, frameIndex(from: $0)) }
        .sorted { $0.1 < $1.1 }
        .map { $0.0 }
}

/// Comparator for sorting texture atlas frame names in ascending frame order.
func compareFrameNames(_ lhs: String, _ rhs: String) -> Bool {
    frameIndex(from: lhs) < frameIndex(from: rhs)
}
