import Foundation

final class StatisticServiceImplementation: StatisticServiceProtocol {
    private enum Keys: String { case correct, total, bestGame, gamesCount }
    private let userDefaults = UserDefaults.standard

    private(set) var totalAccuracy: Double {
        get {
            userDefaults.double(forKey: Keys.total.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.total.rawValue)
        }
    }

    private(set) var gameCount: Int {
        get {
            userDefaults.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }

    private(set) var bestGame: GameRecord {
        get {
            guard let data = userDefaults.data(forKey: Keys.bestGame.rawValue),
                  let record = try? JSONDecoder().decode(GameRecord.self, from: data) else {
                return .init(correct: 0, total: 0, date: Date())
            }
            return record
        }
        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                print("Невозможно сохранить результат")
                return
            }
            userDefaults.set(data, forKey: Keys.bestGame.rawValue)
        }
    }


    func store(correct count: Int, total amount: Int) {
        gameCount += 1

        let currentRecord = GameRecord(correct: count, total: amount, date: Date())
        if currentRecord.isBetter(than: bestGame) {
            bestGame = currentRecord
        }
        print(totalAccuracy)
        totalAccuracy += Double(count) / Double(amount)
    }
}
