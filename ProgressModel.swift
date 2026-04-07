//
// ProgressModel.swift
// KursachDuolingo
//
// Created by Сергей Пупкевич on 18.09.25.
//

import Foundation
import SwiftUI
import Combine

// MARK: - ProgressModel с гибридным режимом (Guest + SwiftData)
@MainActor
class ProgressModel: ObservableObject {
	@Published private(set) var completedLevelsCache: Set<String> = []
	
	private var currentUser: UserEntity?
	private var isGuestMode: Bool = true
	private let totalLevels = 6
	
	init() {
		// Стартуем в гостевом режиме
		loadGuestProgress()
	}
	
	// MARK: - User Management
	
	func setUser(_ user: UserEntity?) {
		guard let user = user else {
			// Возврат в гостевой режим
			currentUser = nil
			isGuestMode = true
			loadGuestProgress()
			return
		}
		
		// Переключение на режим пользователя
		currentUser = user
		isGuestMode = false
		loadUserProgress()
	}
	
	// MARK: - Progress Operations
	
	func isLevelCompleted(language: Language, level: String, levelNumber: Int) -> Bool {
		let key = makeKey(language: language, level: level, levelNumber: levelNumber)
		return completedLevelsCache.contains(key)
	}
	
	func markLevelCompleted(language: Language, level: String, levelNumber: Int) {
		let key = makeKey(language: language, level: level, levelNumber: levelNumber)
		completedLevelsCache.insert(key)
		
		if isGuestMode {
			saveGuestProgress()
		} else if let user = currentUser {
			saveUserProgress(user: user, language: language, level: level, levelNumber: levelNumber)
		}
		
		objectWillChange.send()
	}
	
	func overallProgress(language: Language, level: String) -> Double {
		let prefix = "\(language.rawValue)_\(level)_"
		let count = completedLevelsCache.filter { $0.hasPrefix(prefix) }.count
		return Double(count) / Double(totalLevels)
	}
	
	func resetProgress() {
		completedLevelsCache = []
		
		if isGuestMode {
			UserDefaults.standard.removeObject(forKey: "completedLevels_guest")
		} else if let user = currentUser {
			do {
				try DataManager.shared.resetProgress(for: user)
			} catch {
				print("Ошибка сброса прогресса: \(error)")
			}
		}
		
		objectWillChange.send()
	}
	
	// MARK: - Guest Mode (UserDefaults)
	
	private func loadGuestProgress() {
		if let array = UserDefaults.standard.stringArray(forKey: "completedLevels_guest") {
			completedLevelsCache = Set(array)
		} else {
			completedLevelsCache = []
		}
		objectWillChange.send()
	}
	
	private func saveGuestProgress() {
		let array = Array(completedLevelsCache)
		UserDefaults.standard.set(array, forKey: "completedLevels_guest")
	}
	
	// MARK: - User Mode (SwiftData)
	
	private func loadUserProgress() {
		guard let user = currentUser else { return }
		
		do {
			let allProgress = try DataManager.shared.fetchAllProgress(for: user)
			completedLevelsCache = Set(allProgress.map { $0.uniqueKey })
			objectWillChange.send()
		} catch {
			print("Ошибка загрузки прогресса: \(error)")
		}
	}
	
	private func saveUserProgress(user: UserEntity, language: Language, level: String, levelNumber: Int) {
		do {
			try DataManager.shared.markLevelCompleted(
				user: user,
				language: language.rawValue,
				level: level,
				levelNumber: levelNumber
			)
		} catch {
			print("Ошибка сохранения прогресса: \(error)")
		}
	}
	
	// MARK: - Migration from Guest to User
	
	func migrateGuestProgressToUser(_ user: UserEntity) {
		guard isGuestMode else { return }
		
		// Сохраняем текущий гостевой прогресс
		let guestProgress = completedLevelsCache
		
		// Переключаемся на пользователя
		currentUser = user
		isGuestMode = false
		
		// Переносим прогресс
		for key in guestProgress {
			let components = key.split(separator: "_")
			if components.count >= 3,
			   let languageRaw = components.first,
			   let language = Language.allCases.first(where: { $0.rawValue == String(languageRaw) }),
			   let levelNumber = Int(components.last ?? "") {
				let level = String(components.dropFirst().dropLast().joined(separator: "_"))
				
				do {
					try DataManager.shared.markLevelCompleted(
						user: user,
						language: language.rawValue,
						level: level,
						levelNumber: levelNumber
					)
				} catch {
					print("Ошибка миграции прогресса: \(error)")
				}
			}
		}
		
		// Очищаем гостевой прогресс
		UserDefaults.standard.removeObject(forKey: "completedLevels_guest")
		
		// Загружаем прогресс пользователя
		loadUserProgress()
	}
	
	// MARK: - Private Helpers
	
	private func makeKey(language: Language, level: String, levelNumber: Int) -> String {
		"\(language.rawValue)_\(level)_\(levelNumber)"
	}
}

// MARK: - Структура для данных прогресса
struct LanguageProgress: Identifiable {
	let id = UUID()
	let language: Language
	let beginnerProgress: Double
	let intermediateProgress: Double
	let advancedProgress: Double
	
	var overallProgress: Double {
		(beginnerProgress + intermediateProgress + advancedProgress) / 3.0
	}
}

// MARK: - Расширение ProgressModel для получения прогресса по всем языкам
extension ProgressModel {
	func progressForAllLanguages() -> [LanguageProgress] {
		return Language.allCases.map { language in
			LanguageProgress(
				language: language,
				beginnerProgress: overallProgress(language: language, level: "Начальный"),
				intermediateProgress: overallProgress(language: language, level: "Средний"),
				advancedProgress: overallProgress(language: language, level: "Продвинутый")
			)
		}
	}
}
