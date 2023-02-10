import Foundation

enum TagDatabase {
    static let collection: [TagSectionViewModel] = [
        TagSectionViewModel(
            id: UUID(),
            tag: .adaptive,
            title: "Работай над реальными задачами под руководством опытного наставника и получи возможность стать частью команды мечты.",
            tags: [
                TagViewModel(title: "iOS", state: Bool.random()),
                TagViewModel(title: "Android", state: Bool.random()),
                TagViewModel(title: "DevOps", state: Bool.random()),
                TagViewModel(title: "Flutter", state: Bool.random()),
                TagViewModel(title: "PM", state: Bool.random()),
                TagViewModel(title: "Java", state: Bool.random()),
                TagViewModel(title: ".NET", state: Bool.random()),
                TagViewModel(title: "Ruby", state: Bool.random()),
                TagViewModel(title: "JavaScript", state: Bool.random()),
                TagViewModel(title: "C++", state: Bool.random()),
                TagViewModel(title: "React Native", state: Bool.random())
            ]
        ),
        TagSectionViewModel(
            id: UUID(),
            tag: .loop,
            title: "Получай стипендию, выстраивай удобный график, работай на современном железе.",
            tags: [
                TagViewModel(title: "iOS", state: Bool.random()),
                TagViewModel(title: "Android", state: Bool.random()),
                TagViewModel(title: "DevOps", state: Bool.random()),
                TagViewModel(title: "Flutter", state: Bool.random()),
                TagViewModel(title: "PM", state: Bool.random()),
                TagViewModel(title: "Java", state: Bool.random()),
                TagViewModel(title: ".NET", state: Bool.random()),
                TagViewModel(title: "Ruby", state: Bool.random()),
                TagViewModel(title: "JavaScript", state: Bool.random()),
                TagViewModel(title: "C++", state: Bool.random()),
                TagViewModel(title: "React Native", state: Bool.random())
            ]
        )
    ]
}
