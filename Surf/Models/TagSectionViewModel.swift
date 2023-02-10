import Foundation

struct TagSectionViewModel: Identifiable {
    let id: UUID
    let tag: SectionTag
    let title: String
    let tags: [TagViewModel]
}
