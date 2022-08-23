import Foundation


 struct ErrorViewModel {
    let title: String
    let text: String
    let buttonText: String

    init() {
        title = "Что-то пошло не так("
        text = "Невозможно загрузить данные"
        buttonText = "Попробовать еще раз"
    }
}
