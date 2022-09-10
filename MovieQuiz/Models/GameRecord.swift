import Foundation

struct GameRecord: Codable {
    let correct: Int
    let total: Int
    let date: Date

    func isBetter(than record: GameRecord) -> Bool {
        if correct > record.correct {
            return true
        }
        return false
    }
}
