//
//  LevelDetailView.swift
//  KursachDuolingo
//
//  Created by Сергей Пупкевич on 18.09.25.
//

import SwiftUI

// MARK: -  Level detail view
struct LevelDetailView: View {
	let language: Language
	let level: String
	let levelNumber: Int
	@EnvironmentObject var progressModel: ProgressModel
	@StateObject private var taskViewModel: TaskViewModel
	@Environment(\.dismiss) private var dismis
	
	init(language: Language, level: String, levelNumber: Int) {
		self.language = language
		self.level = level
		self.levelNumber = levelNumber
		self._taskViewModel = StateObject(wrappedValue: TaskViewModel(language: language, level: level, levelNumber: levelNumber))
	}

	var body: some View {
		ZStack {
			Color(hex: "#e6e6e6", opacity: 0.5)
				.ignoresSafeArea()

			VStack {
				// Заголовок с типом задания
				VStack {
					Text("Язык: \(language.rawValue)")
						.font(.title2)
					Text("Уровень: \(levelNumber)")
						.font(.largeTitle)
						.bold()
					
					Text({
						switch taskViewModel.taskType {
						case .translation:
							return "Задание: Перевод слова"
						case .sentence:
							return "Задание: Составление предложения" // надо сделать что бы тут ниче не было и просто тогда будет все влазить и выглядить получше
						case .multipleChoice:
							return "Задание: Множественный выбор" //вернуть обратно
						}
					}())
					.font(.subheadline)
					.foregroundColor(.secondary)
					.padding(.top, -10)
				}
				.padding(.bottom)
				
				// Контент задания
				VStack {
					VStack(spacing: 20) {
						switch taskViewModel.taskType {
						case .translation:
							if let task = taskViewModel.currentTask as? WordTranslationTask {
								WordTranslationView(task: task, viewModel: taskViewModel)
							}
						case .sentence:
							if let task = taskViewModel.currentTask as? SentenceBuilderTask {
								SentenceBuilderView(task: task, viewModel: taskViewModel)
								
							}
						case .multipleChoice:
							if let task = taskViewModel.currentTask as? MultipleChoiceTask {
								MultipleChoiceView(task: task, viewModel: taskViewModel)
							}
						}
					}
				}
				
				Spacer()
				
				
				
				VStack(alignment: .leading) {

				   Button(action: { // Кнопка завершения уровня (показываем только после правильного ответа)
					   if (taskViewModel.showCorrectAnswer && taskViewModel.isAnswerCorrect) {
						   progressModel.markLevelCompleted(language: language, level: level, levelNumber: levelNumber)
					   }
					   dismis() // Просто добавляется дисмисс и енвайромент и оно возваращет на прошлую вьюху
				   }) {
					   Text("Завершить уровень")
						   .font(.title2)
						   .frame(width: 250, height: 60)
						   .background((taskViewModel.showCorrectAnswer && taskViewModel.isAnswerCorrect) ? Color.green.opacity(0.7) : Color.blue.opacity(0.7)) // замена цвета на по результатам
						   .foregroundColor(.white)
						   .minimumScaleFactor(0.9)
						   .clipShape(Capsule())
				   }
//				   .ignoresSafeArea()
				   
				   Rectangle()
					   .fill(Color.clear)
					   .frame(width: 250, height: 30)
					   .disabled(!(taskViewModel.showCorrectAnswer && taskViewModel.isAnswerCorrect))
				}
//				.padding(.top, -64)
//				.padding()
			}
		}
		.ignoresSafeArea(.keyboard, edges: .bottom)
		.onAppear {
			taskViewModel.resetTask()
		}
	}
}

#Preview {
	//раскладка задания
	LevelDetailView(language: .english, level: "Продвинутый", levelNumber: 4)
}
