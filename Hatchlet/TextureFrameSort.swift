/// Returns the numeric index embedded in a texture atlas frame name.
/// e.g. "bird_042.png" → 42, "frame3" → 3
func frameIndex(from textureName: String) -> Int {
    let digits = textureName.filter(\.isNumber)
    return Int(digits) ?? 0
}

/// Sorts texture atlas frame names in ascending frame order, parsing each
/// name's numeric index only once to avoid repeated work during comparison.
/// Names with equal numeric indices are ordered lexicographically for determinism.
func sortedByFrameIndex(_ names: [String]) -> [String] {
    names
        .map { ($0, frameIndex(from: $0)) }
        .sorted { lhs, rhs in
            if lhs.1 != rhs.1 {
                return lhs.1 < rhs.1
            }
            return lhs.0 < rhs.0
        }
        .map { $0.0 }
}
