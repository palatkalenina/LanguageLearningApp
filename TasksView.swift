//
//  TaskView.swift
//  KursachDuolingo
//
//  Created by Сергей Пупкевич on 18.09.25.
//

import SwiftUI
import Combine

// MARK: -  экран заданий для каждого языка и уровня
struct TasksView: View {
	let language: Language
	let level: String
	@EnvironmentObject var progressModel: ProgressModel

	private let totalLevels = 6

	var body: some View {
		VStack() {
			ZStack {
							RoundedRectangle(cornerRadius: 30)
								.fill(Color(hex: "#91a3b0"))
								.frame(width: 340, height: 190)

							RoundedRectangle(cornerRadius: 25)
								.fill(Color(hex: "#848482"))
								.frame(width: 325, height: 175)

							VStack(spacing: 20) {
								Text("Задания для:")
									.font(.headline)
								Text("\(language.icon) \(language.rawValue)")
									.font(.title)
								Text("Уровень: \(level)")
									.font(.title2)
							}
							.foregroundColor(.white)
						}
					.padding(.bottom, 10)
					   .padding(.top, 20)
			
			VStack {
				// Прогрессбар на основе общего прогресса
				ProgressView("Progress (\(Int(progressModel.overallProgress(language: language, level: level) * 100))%)",
							 value: progressModel.overallProgress(language: language, level: level))
					.padding()

				VStack(spacing: 20) {
					let rows = [
						[1, 2],
						[3, 4],
						[5, 6]
					]

					ForEach(rows.indices, id: \.self) { rowIndex in
						HStack(spacing: 15) {
							Spacer()
							ForEach(rows[rowIndex], id: \.self) { levelNumber in
								NavigationLink(destination: LevelDetailView(language: language, level: level, levelNumber: levelNumber)
									.environmentObject(progressModel)) {
									ZStack {
										RoundedRectangle(cornerRadius: 25)
											.fill(progressModel.isLevelCompleted(language: language, level: level, levelNumber: levelNumber)
												? Color(hex: "#6aa84f")
												: Color(hex: "#848482"))
											.frame(width: 105, height: 105)
										Text("\(levelNumber)")
											.font(.largeTitle)
											.foregroundColor(.white)
									}
								}
								.buttonStyle(.bordered)
							}
							Spacer()
						}
					}
				}
				.padding(.bottom)
				Spacer()
			}
			.padding()
			.ignoresSafeArea(.keyboard, edges: .bottom)
		}
	}
}

#Preview {
//	раскладка уровней
	TasksView(language: .english, level: "1").environmentObject(ProgressModel())
}
