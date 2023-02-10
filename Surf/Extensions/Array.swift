extension Array where Element: Equatable {

    mutating func move(_ element: Element, to newIndex: Index) {
        guard let oldIndex: Int = firstIndex(of: element) else { return }
        move(from: oldIndex, to: newIndex)
    }
}

extension Array {

    mutating func move(from oldIndex: Index, to newIndex: Index) {
        guard oldIndex != newIndex else { return }
        insert(remove(at: oldIndex), at: newIndex)
    }
}
