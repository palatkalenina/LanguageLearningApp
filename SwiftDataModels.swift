//
//  SwiftDataModels.swift
//  KursachDuolingo
//
//  Created by Сергей Пупкевич on 7.10.25.
//

import Foundation
import SwiftData
import CryptoKit

// MARK: - User Entity
@Model
final class UserEntity {
	@Attribute(.unique) var email: String
	var username: String
	var passwordHash: String
	var passwordSalt: String
	var createdAt: Date
	var lastLoginAt: Date?
	
	@Relationship(deleteRule: .cascade, inverse: \ProgressEntity.user)
	var progressRecords: [ProgressEntity]? = []
	
	init(email: String, username: String, password: String) {
		// Генерируем соль СНАЧАЛА в локальной переменной
		let salt = UserEntity.generateSalt()
		
		// Теперь можем безопасно использовать соль для хеширования
		let hash = UserEntity.hashPassword(password, salt: salt)
		
		// Только ТЕПЕРЬ присваиваем stored properties
		self.email = email.lowercased()
		self.username = username
		self.passwordSalt = salt
		self.passwordHash = hash
		self.createdAt = Date()
		self.lastLoginAt = nil
	}
	
	// MARK: - Password Hashing with Salt
	static func hashPassword(_ password: String, salt: String) -> String {
		let combined = password + salt
		let inputData = Data(combined.utf8)
		let hashed = SHA256.hash(data: inputData)
		return hashed.compactMap { String(format: "%02x", $0) }.joined()
	}
	
	static func generateSalt() -> String {
		let saltData = Data((0..<32).map { _ in UInt8.random(in: 0...255) })
		return saltData.base64EncodedString()
	}
	
	func verifyPassword(_ password: String) -> Bool {
		let hash = UserEntity.hashPassword(password, salt: self.passwordSalt)
		return hash == self.passwordHash
	}
	
	func updateLastLogin() {
		self.lastLoginAt = Date()
	}
}

// MARK: - Progress Entity
@Model
final class ProgressEntity {
	var language: String
	var level: String
	var levelNumber: Int
	var completedAt: Date
	
	@Relationship var user: UserEntity?
	
	init(language: String, level: String, levelNumber: Int, user: UserEntity) {
		self.language = language
		self.level = level
		self.levelNumber = levelNumber
		self.completedAt = Date()
		self.user = user
	}
	
	// Уникальный идентификатор для сравнения
	var uniqueKey: String {
		"\(language)_\(level)_\(levelNumber)"
	}
}
