import Foundation

protocol StatisticServiceProtocol {
    func store(correct count: Int, total amount: Int)
    var totalAccuracy: Double { get }
    var gameCount: Int { get }
    var bestGame: GameRecord { get }
}
