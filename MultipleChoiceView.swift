//
//  MultipleChoiceView.swift
//  KursachDuolingo
//
//  Created by Сергей Пупкевич on 18.09.25.
//

import SwiftUI

// MARK: - Multiple Choice View
struct MultipleChoiceView: View {
	let task: MultipleChoiceTask
	@ObservedObject var viewModel: TaskViewModel

	var body: some View {
		VStack(spacing: 20) {
			Text("Выберите правильный перевод:")
				.font(.headline)
			
			Text(task.word)
				.font(.largeTitle)
				.bold()
				.padding()
				.background(Color(hex: "#F0F8FF"))
				.cornerRadius(15)
			
			VStack(spacing: 15) {
				ForEach(task.options, id: \.self) { option in
					Button(action: {
						viewModel.selectedOption = option
						viewModel.checkMultipleChoiceAnswer()
					}) {
						Text(option)
							.frame(maxWidth: .infinity)
							.padding()
							.background(viewModel.selectedOption == option ? Color.blue.opacity(0.2) : Color(hex: "#F8F9FA"))
							.contentShape(RoundedRectangle(cornerRadius: 10))
							.cornerRadius(10)
							.overlay(
								RoundedRectangle(cornerRadius: 10)
									.stroke(viewModel.selectedOption == option ? Color.blue : Color.gray.opacity(0.3), lineWidth: 2)
							)
					}
					.disabled(viewModel.showCorrectAnswer)
				}
			}
			
			if viewModel.showCorrectAnswer {
				HStack {
					Image(systemName: viewModel.isAnswerCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
						.foregroundColor(viewModel.isAnswerCorrect ? .green : .red)
						.font(.title)
					
					Text(viewModel.isAnswerCorrect ? "Правильно!" : "Правильный ответ: \(task.correctTranslation)")
						.font(.title3)
						.foregroundColor(viewModel.isAnswerCorrect ? .green : .primary)
				}
				.padding()
				.background(Color(hex: viewModel.isAnswerCorrect ? "#D4EDDA" : "#F8D7DA"))
				.cornerRadius(10)
			}
		}
		.ignoresSafeArea(.keyboard, edges: .bottom)
		.padding()
	}
}


//#Preview {
//// ну хз тут ниче не меняем просто
//	
//	
//	MultipleChoiceView(task: MultipleChoiceTask(word: "слон", correctTranslation: "слон", options: ["ssfsfs","sdfsd","слон"], language: .belarussian), viewModel: TaskViewModel(language: .belarussian, level: "начальный", levelNumber: 6))
//}
