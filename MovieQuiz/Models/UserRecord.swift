import Foundation

struct UserRecord {
    let numberOfCorrectAnswers: Int
    let date: Date

    init(_ numberOfCorrectAnswers: Int) {
        self.numberOfCorrectAnswers = numberOfCorrectAnswers
        date = Date()
    }
}
