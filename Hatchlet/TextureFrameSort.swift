/// Returns the numeric index embedded in a texture atlas frame name.
/// e.g. "bird_042.png" → 42, "frame3" → 3
func frameIndex(from textureName: String) -> Int {
    let digits = textureName.filter(\.isNumber)
    return Int(digits) ?? 0
}

/// Comparator for sorting texture atlas frame names in ascending frame order.
func compareFrameNames(_ lhs: String, _ rhs: String) -> Bool {
    frameIndex(from: lhs) < frameIndex(from: rhs)
}
