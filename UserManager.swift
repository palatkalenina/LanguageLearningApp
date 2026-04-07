//
// UserManager.swift
// KursachDuolingo
//
// Created by Сергей Пупкевич on 16.09.25.
//

import Foundation
import Combine
import SwiftUI

@MainActor
class UserManager: ObservableObject {
	@Published var currentUser: UserEntity?
	@Published var isLoggedIn: Bool = false
	
	// Ссылка на ProgressModel для миграции
	weak var progressModel: ProgressModel?
	
	init() {
		loadSavedSession()
	}
	
	// MARK: - Link Progress Model
	
	func linkProgressModel(_ progressModel: ProgressModel) {
		self.progressModel = progressModel
	}
	
	// MARK: - Authentication Methods
	
	func register(email: String, username: String, password: String) -> Result<Void, DataManagerError> {
		do {
			let user = try DataManager.shared.registerUser(email: email, username: username, password: password)
			
			self.currentUser = user
			self.isLoggedIn = true
			self.saveSession(user: user)
			
			// Мигрируем гостевой прогресс
			progressModel?.migrateGuestProgressToUser(user)
			progressModel?.setUser(user)
			
			return .success(())
		} catch let error as DataManagerError {
			return .failure(error)
		} catch {
			return .failure(.databaseError(error.localizedDescription))
		}
	}
	
	func login(email: String, password: String) -> Result<Void, DataManagerError> {
		do {
			let user = try DataManager.shared.loginUser(email: email, password: password)
			
			self.currentUser = user
			self.isLoggedIn = true
			self.saveSession(user: user)
			
			// Загружаем прогресс пользователя
			progressModel?.setUser(user)
			
			return .success(())
		} catch let error as DataManagerError {
			return .failure(error)
		} catch {
			return .failure(.databaseError(error.localizedDescription))
		}
	}
	
	func logout() {
		currentUser = nil
		isLoggedIn = false
		clearSession()
		
		// Возврат в гостевой режим
		progressModel?.setUser(nil)
	}
	
	// MARK: - Session Management
	
	private func saveSession(user: UserEntity) {
		UserDefaults.standard.set(user.email, forKey: "savedUserEmail")
	}
	
	private func loadSavedSession() {
		guard let email = UserDefaults.standard.string(forKey: "savedUserEmail") else {
			return
		}
		
		do {
			if let user = try DataManager.shared.fetchUser(by: email) {
				self.currentUser = user
				self.isLoggedIn = true
				// Прогресс будет загружен в onAppear ContentView
			} else {
				clearSession()
			}
		} catch {
			print("Ошибка загрузки сессии: \(error)")
			clearSession()
		}
	}
	
	private func clearSession() {
		UserDefaults.standard.removeObject(forKey: "savedUserEmail")
	}
}
