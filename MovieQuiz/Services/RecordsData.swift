import Foundation

struct RecordsData {
    private var records = [UserRecord]()

    mutating func addRecord(scores: Int) {
        records.append(UserRecord(scores))
    }

    func requestBestRecord() -> UserRecord? {
        guard !records.isEmpty else { return nil }
        var bestRecord = records[0]
        for record in records where record.numberOfCorrectAnswers > bestRecord.numberOfCorrectAnswers {
            bestRecord = record
        }
        return bestRecord
    }

    func requestAverageAccuracy() -> Double? {
        guard !records.isEmpty else { return nil }
        var sum = 0
        for record in records {
            sum += record.numberOfCorrectAnswers
        }
        let accuracy = ((Double(sum) / Double(records.count)) ) * 100 // не хватает деления на кол-во вопросов
        return accuracy
        // Double(quizQuestions.count
    }
}
