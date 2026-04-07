//
//  WordTranslationView.swift
//  KursachDuolingo
//
//  Created by Сергей Пупкевич on 18.09.25.
//

import SwiftUI
import Combine

// MARK: -  Word Translation View
struct WordTranslationView: View {
	let task: WordTranslationTask
	@ObservedObject var viewModel: TaskViewModel
    @FocusState private var isTextFieldFocused: Bool
	
	var body: some View {
		VStack(spacing: 20) {
			Text("Переведите слово:")
				.font(.headline)
			
			Text(task.word)
				.font(.largeTitle)
				.bold()
				.padding()
				.background(Color(hex: "#F0F8FF"))
				.cornerRadius(15)
			
			TextField("Введите перевод", text: $viewModel.userAnswer)
				.textFieldStyle(RoundedBorderTextFieldStyle())
				.font(.title2)
				.multilineTextAlignment(.center)
                .focused($isTextFieldFocused)
				.onSubmit {
					viewModel.checkTranslationAnswer()
                    isTextFieldFocused = false
				}
			
			Button("Проверить") {
                isTextFieldFocused = false
				viewModel.checkTranslationAnswer()
			}
			.buttonStyle(GrowingButton())
			.disabled(viewModel.userAnswer.isEmpty)
			
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
