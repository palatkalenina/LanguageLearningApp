//
//  KursachDuolingoApp.swift
//  KursachDuolingo
//
//  Created by Сергей Пупкевич on 2.09.25.
//

import SwiftUI
import SwiftData

@main
struct KursachDuolingoApp: App {
	// Настройка ModelContainer для SwiftData
	let modelContainer: ModelContainer
	
	init() {
		do {
			// Создаем контейнер с нашими моделями
			modelContainer = try ModelContainer(
				for: UserEntity.self, ProgressEntity.self,
				configurations: ModelConfiguration(isStoredInMemoryOnly: false)
			)
		} catch {
			fatalError("Не удалось создать ModelContainer: \(error)")
		}
	}
	
	var body: some Scene {
		WindowGroup {
			ContentView()
				.modelContainer(modelContainer)
                .preferredColorScheme(.light)
				.onAppear {
					// Настраиваем DataManager с контекстом
					DataManager.shared.configure(with: modelContainer.mainContext)
				}
		}
	}
}
