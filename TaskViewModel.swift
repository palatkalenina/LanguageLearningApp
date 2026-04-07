//
//  TaskViewModel.swift
//  KursachDuolingo
//
//  Created by Сергей Пупкевич on 18.09.25.
//

import Foundation
import SwiftUI
import Combine

// MARK: - Task View Model
class TaskViewModel: ObservableObject {
	@Published var userAnswer = ""
	@Published var showCorrectAnswer = false
	@Published var isAnswerCorrect = false
	@Published var draggedWords: [String] = []
	@Published var droppedWords: [String] = []
	@Published var selectedOption = ""

	let currentTask: Any
	let taskType: TaskType
	let level: String // Сохраняем уровень для использования

	enum TaskType {
		case translation
		case sentence
		case multipleChoice // Новый тип для продвинутого уровня
	}

	init(language: Language, level: String, levelNumber: Int) {
		self.level = level
		
		// Определяем тип задания в зависимости от уровня сложности
		switch level {
		case "Начальный":
			// Только переводы для всех 6 уровней
			taskType = .translation
			currentTask = TaskViewModel.generateTranslationTask(for: language, level: level, levelNumber: levelNumber)
			
		case "Средний":
			// Переводы (1-3) + предложения (4-6)
			if levelNumber <= 3 {
				taskType = .translation
				currentTask = TaskViewModel.generateTranslationTask(for: language, level: level, levelNumber: levelNumber)
			} else {
				taskType = .sentence
				currentTask = TaskViewModel.generateSentenceTask(for: language, level: level, levelNumber: levelNumber)
			}
			
		case "Продвинутый":
			// Переводы (1-2), предложения (3-4), множественный выбор (5-6)
			switch levelNumber {
			case 1...2:
				taskType = .translation
				currentTask = TaskViewModel.generateTranslationTask(for: language, level: level, levelNumber: levelNumber)
			case 3...4:
				taskType = .sentence
				currentTask = TaskViewModel.generateSentenceTask(for: language, level: level, levelNumber: levelNumber)
			case 5...6:
				taskType = .multipleChoice
				currentTask = TaskViewModel.generateMultipleChoiceTask(for: language, level: level, levelNumber: levelNumber)
			default:
				taskType = .translation
				currentTask = TaskViewModel.generateTranslationTask(for: language, level: level, levelNumber: levelNumber)
			}
			
		default:
			taskType = .translation
			currentTask = TaskViewModel.generateTranslationTask(for: language, level: level, levelNumber: levelNumber)
		}
	}

	// Обновленная генерация переводов с учетом уровня
	static func generateTranslationTask(for language: Language, level: String, levelNumber: Int) -> WordTranslationTask {
		let wordsByLevel: [String: [(Int, String, String)]]
		
		switch language {
		case .english:
			wordsByLevel = [
				"Начальный": [
					(1, "Cat", "Кот"), (2, "Dog", "Собака"), (3, "Home", "Дом"),
					(4, "Book", "Книга"), (5, "Water", "Вода"), (6, "Food", "Еда")
				],
				"Средний": [
					(1, "Travel", "Путешествие"), (2, "Friend", "Друг"), (3, "School", "Школа"),
					(4, "Family", "Семья"), (5, "Nature", "Природа"), (6, "Health", "Здоровье")
				],
				"Продвинутый": [
					(1, "Philosophy", "Философия"), (2, "Architecture", "Архитектура"),
					(3, "Democracy", "Демократия"), (4, "Technology", "Технология"),
					(5, "Psychology", "Психология"), (6, "Economics", "Экономика")
				]
			]
			
		case .spanish:
			wordsByLevel = [
				"Начальный": [
					(1, "Gato", "Кот"), (2, "Perro", "Собака"), (3, "Casa", "Дом"),
					(4, "Libro", "Книга"), (5, "Agua", "Вода"), (6, "Comida", "Еда")
				],
				"Средний": [
					(1, "Viajar", "Путешествие"), (2, "Amigo", "Друг"), (3, "Escuela", "Школа"),
					(4, "Familia", "Семья"), (5, "Naturaleza", "Природа"), (6, "Salud", "Здоровье")
				],
				"Продвинутый": [
					(1, "Filosofía", "Философия"), (2, "Arquitectura", "Архитектура"),
					(3, "Democracia", "Демократия"), (4, "Tecnología", "Технология"),
					(5, "Psicología", "Психология"), (6, "Economía", "Экономика")
				]
			]
			
		case .belarussian:
			wordsByLevel = [
				"Начальный": [
					(1, "Кот", "Кот"), (2, "Сабака", "Собака"), (3, "Дом", "Дом"),
					(4, "Кніга", "Книга"), (5, "Вада", "Вода"), (6, "Ежа", "Еда")
				],
				"Средний": [
					(1, "Падарожжа", "Путешествие"), (2, "Сябар", "Друг"), (3, "Школа", "Школа"),
					(4, "Сям'я", "Семья"), (5, "Прырода", "Природа"), (6, "Здароўе", "Здоровье")
				],
				"Продвинутый": [
					(1, "Філасофія", "Философия"), (2, "Архітэктура", "Архитектура"),
					(3, "Дэмакратыя", "Демократия"), (4, "Тэхналогія", "Технология"),
					(5, "Псіхалогія", "Психология"), (6, "Эканоміка", "Экономика")
				]
			]
		}

		let words = wordsByLevel[level] ?? wordsByLevel["Начальный"]!
		let wordData = words.first { $0.0 == levelNumber } ?? words[0]
		return WordTranslationTask(word: wordData.1, correctTranslation: wordData.2, language: language)
	}

	// Обновленная генерация предложений с учетом уровня
	static func generateSentenceTask(for language: Language, level: String, levelNumber: Int) -> SentenceBuilderTask {
		let sentencesByLevel: [String: [(Int, [String])]]
		
		switch language {
		case .english:
			sentencesByLevel = [
				"Средний": [
					(4, ["I", "am", "learning", "English"]),
					(5, ["She", "reads", "interesting", "books", "daily"]),
					(6, ["We", "will", "travel", "to", "Europe", "tomorrow"])
				],
				"Продвинутый": [
					(3, ["The", "philosophical", "discussion", "was", "fascinating", "and", "thought-provoking"]),
					(4, ["Advanced", "technology", "shapes", "our", "modern", "democratic", "society", "significantly"])
				]
			]
			
		case .spanish:
			sentencesByLevel = [
				"Средний": [
					(4, ["Yo", "estoy", "aprendiendo", "español"]),
					(5, ["Ella", "lee", "libros", "interesantes", "diariamente"]),
					(6, ["Nosotros", "viajaremos", "a", "Europa", "mañana"])
				],
				"Продвинутый": [
					(3, ["La", "discusión", "filosófica", "fue", "fascinante", "y", "provocativa"]),
					(4, ["La", "tecnología", "avanzada", "forma", "nuestra", "sociedad", "democrática", "moderna"])
				]
			]
			
		case .belarussian:
			sentencesByLevel = [
				"Средний": [
					(4, ["Я", "вывучаю", "беларускую", "мову"]),
					(5, ["Яна", "чытае", "цікавыя", "кнігі", "штодня"]),
					(6, ["Мы", "будзем", "падарожнічаць", "па", "Еўропе", "заўтра"])
				],
				"Продвинутый": [
					(3, ["Філасофская", "дыскусія", "была", "захапляючай", "і", "навуковай"]),
					(4, ["Сучасныя", "тэхналогіі", "фармуюць", "наша", "дэмакратычнае", "грамадства"])
				]
			]
		}
		
		let sentences = sentencesByLevel[level] ?? sentencesByLevel["Средний"]!
		let sentenceData = sentences.first { $0.0 == levelNumber } ?? sentences[0]
		return SentenceBuilderTask(correctSentence: sentenceData.1, language: language)
	}

	// Новый метод для множественного выбора
	static func generateMultipleChoiceTask(for language: Language, level: String, levelNumber: Int) -> MultipleChoiceTask {
		let tasks: [(Int, String, String, [String])]
		
		switch language {
		case .english:
			tasks = [
				(5, "Philosophical", "Философский", ["Философский", "Физический", "Финансовый", "Фантастический"]),
				(6, "Architecture", "Архитектура", ["Архитектура", "Арифметика", "Артистизм", "Археология"])
			]
			
		case .spanish:
			tasks = [
				(5, "Filosófico", "Философский", ["Философский", "Физический", "Финансовый", "Фантастический"]),
				(6, "Arquitectura", "Архитектура", ["Архитектура", "Арифметика", "Артистизм", "Археология"])
			]
			
		case .belarussian:
			tasks = [
				(5, "Філасофскі", "Философский", ["Философский", "Физический", "Финансовый", "Фантастический"]),
				(6, "Архітэктура", "Архитектура", ["Архитектура", "Арифметика", "Артистизм", "Археология"])
			]
		}
		
		let taskData = tasks.first { $0.0 == levelNumber } ?? tasks[0]
		return MultipleChoiceTask(word: taskData.1, correctTranslation: taskData.2, options: taskData.3, language: language)
	}

	// Новый метод проверки множественного выбора
	func checkMultipleChoiceAnswer() {
		guard let task = currentTask as? MultipleChoiceTask else { return }
		isAnswerCorrect = selectedOption == task.correctTranslation
		showCorrectAnswer = true
	}

	// Остальные методы остаются без изменений...
	func checkTranslationAnswer() {
		guard let task = currentTask as? WordTranslationTask else { return }
		let cleanUserAnswer = userAnswer.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
		let cleanCorrectAnswer = task.correctTranslation.lowercased()
		isAnswerCorrect = cleanUserAnswer == cleanCorrectAnswer
		showCorrectAnswer = true
	}

	func checkSentenceOrder() {
		guard let task = currentTask as? SentenceBuilderTask else { return }
		isAnswerCorrect = droppedWords == task.correctSentence
		showCorrectAnswer = true
	}

	func resetTask() {
		userAnswer = ""
		showCorrectAnswer = false
		isAnswerCorrect = false
		droppedWords = []
		selectedOption = ""

		if let sentenceTask = currentTask as? SentenceBuilderTask {
			draggedWords = sentenceTask.shuffledWords
		}
	}
}


