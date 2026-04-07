//
//  DataManager.swift
//  KursachDuolingo
//
//  Created by Сергей Пупкевич on 7.10.25.
//

import Foundation
import SwiftData
import SwiftUI

// MARK: - Data Manager Errors
enum DataManagerError: LocalizedError {
	case userAlreadyExists
	case userNotFound
	case invalidCredentials
	case databaseError(String)
	case contextNotAvailable
	
	var errorDescription: String? {
		switch self {
		case .userAlreadyExists:
			return "Пользователь с таким email уже существует"
		case .userNotFound:
			return "Пользователь не найден"
		case .invalidCredentials:
			return "Неверный email или пароль"
		case .databaseError(let message):
			return "Ошибка базы данных: \(message)"
		case .contextNotAvailable:
			return "Контекст базы данных недоступен"
		}
	}
}

// MARK: - Data Manager
@MainActor
class DataManager {
	static let shared = DataManager()
	
	private var modelContext: ModelContext?
	
	private init() {}
	
	func configure(with context: ModelContext) {
		self.modelContext = context
	}
	
	// MARK: - User Operations
	
	func registerUser(email: String, username: String, password: String) throws -> UserEntity {
		guard let context = modelContext else {
			throw DataManagerError.contextNotAvailable
		}
		
		// Проверка существования пользователя
		let emailLowercased = email.lowercased()
		let fetchDescriptor = FetchDescriptor<UserEntity>(
			predicate: #Predicate { $0.email == emailLowercased }
		)
		
		let existingUsers = try context.fetch(fetchDescriptor)
		if !existingUsers.isEmpty {
			throw DataManagerError.userAlreadyExists
		}
		
		// Создание нового пользователя
		let newUser = UserEntity(email: email, username: username, password: password)
		context.insert(newUser)
		
		try context.save()
		return newUser
	}
	
	func loginUser(email: String, password: String) throws -> UserEntity {
		guard let context = modelContext else {
			throw DataManagerError.contextNotAvailable
		}
		
		let emailLowercased = email.lowercased()
		let fetchDescriptor = FetchDescriptor<UserEntity>(
			predicate: #Predicate { $0.email == emailLowercased }
		)
		
		let users = try context.fetch(fetchDescriptor)
		
		guard let user = users.first else {
			throw DataManagerError.userNotFound
		}
		
		guard user.verifyPassword(password) else {
			throw DataManagerError.invalidCredentials
		}
		
		user.updateLastLogin()
		try context.save()
		
		return user
	}
	
	func fetchUser(by email: String) throws -> UserEntity? {
		guard let context = modelContext else {
			throw DataManagerError.contextNotAvailable
		}
		
		let emailLowercased = email.lowercased()
		let fetchDescriptor = FetchDescriptor<UserEntity>(
			predicate: #Predicate { $0.email == emailLowercased }
		)
		
		let users = try context.fetch(fetchDescriptor)
		return users.first
	}
	
	// MARK: - Progress Operations
	
	func markLevelCompleted(user: UserEntity, language: String, level: String, levelNumber: Int) throws {
		guard let context = modelContext else {
			throw DataManagerError.contextNotAvailable
		}
		
		// Проверяем, не завершен ли уже этот уровень
		if let existingProgress = try fetchProgress(for: user, language: language, level: level, levelNumber: levelNumber) {
			// Уровень уже завершен, ничего не делаем
			return
		}
		
		// Создаем новую запись о прогрессе
		let progress = ProgressEntity(language: language, level: level, levelNumber: levelNumber, user: user)
		context.insert(progress)
		
		try context.save()
	}
	
	func isLevelCompleted(user: UserEntity, language: String, level: String, levelNumber: Int) throws -> Bool {
		let progress = try fetchProgress(for: user, language: language, level: level, levelNumber: levelNumber)
		return progress != nil
	}
	
	func fetchAllProgress(for user: UserEntity) throws -> [ProgressEntity] {
		guard let context = modelContext else {
			throw DataManagerError.contextNotAvailable
		}
		
		let userEmail = user.email
		let fetchDescriptor = FetchDescriptor<ProgressEntity>(
			predicate: #Predicate { $0.user?.email == userEmail }
		)
		
		return try context.fetch(fetchDescriptor)
	}
	
	func fetchProgress(for user: UserEntity, language: String, level: String, levelNumber: Int) throws -> ProgressEntity? {
		guard let context = modelContext else {
			throw DataManagerError.contextNotAvailable
		}
		
		let userEmail = user.email
		let fetchDescriptor = FetchDescriptor<ProgressEntity>(
			predicate: #Predicate {
				$0.user?.email == userEmail &&
				$0.language == language &&
				$0.level == level &&
				$0.levelNumber == levelNumber
			}
		)
		
		let results = try context.fetch(fetchDescriptor)
		return results.first
	}
	
	func calculateProgress(user: UserEntity, language: String, level: String) throws -> Double {
		let totalLevels = 6.0
		
		let userEmail = user.email
		let fetchDescriptor = FetchDescriptor<ProgressEntity>(
			predicate: #Predicate {
				$0.user?.email == userEmail &&
				$0.language == language &&
				$0.level == level
			}
		)
		
		guard let context = modelContext else {
			throw DataManagerError.contextNotAvailable
		}
		
		let completedLevels = try context.fetch(fetchDescriptor)
		return Double(completedLevels.count) / totalLevels
	}
	
	func resetProgress(for user: UserEntity) throws {
		guard let context = modelContext else {
			throw DataManagerError.contextNotAvailable
		}
		
		let allProgress = try fetchAllProgress(for: user)
		
		for progress in allProgress {
			context.delete(progress)
		}
		
		try context.save()
	}
}
