//
//  SentenceBuilderView.swift
//  KursachDuolingo
//
//  Created by Сергей Пупкевич on 18.09.25.
//

import SwiftUI
import Combine

// MARK: -  Sentence Builder View
struct SentenceBuilderView: View {
	let task: SentenceBuilderTask
	@ObservedObject var viewModel: TaskViewModel
	@State private var selectedWords: [String] = []
	
	var body: some View {
		ScrollView() {
		VStack(spacing: 20) {
			Text("Составьте предложение, выбирая слова по порядку:")
				.font(.headline)
				.multilineTextAlignment(.center)
			
			// Построенное предложение
			Text(selectedWords.isEmpty ? "Нажимайте на слова ниже" : selectedWords.joined(separator: " "))
				.font(.title2)
				.padding()
				.frame(minHeight: 60)
				.background(Color(hex: "#F8F9FA"))
				.cornerRadius(10)
				.overlay(
					RoundedRectangle(cornerRadius: 10)
						.stroke(Color.gray.opacity(0.3), lineWidth: 1)
				)
			
			// Доступные слова
			LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 10) {
				ForEach(task.shuffledWords, id: \.self) { word in
					Button(word) {
						if !selectedWords.contains(word) {
							selectedWords.append(word)
						}
					}
					.padding()
					.background(selectedWords.contains(word) ? Color.gray.opacity(0.3) : Color(hex: "#E3F2FD"))
					.cornerRadius(8)
					.disabled(selectedWords.contains(word))
					.lineLimit(1)
					.minimumScaleFactor(0.8)
					.gridCellColumns(2)
				}
			}
			
			VStack {
				
				Button("Проверить") {
					viewModel.droppedWords = selectedWords
					viewModel.checkSentenceOrder()
				}
				.buttonStyle(GrowingButton())
				.disabled(selectedWords.count != task.correctSentence.count)
				
				Button("Очистить") {
					selectedWords = []
				}
				.foregroundStyle(Color.red.opacity(0.7))
				.buttonStyle(.borderless)
				.padding(.top, 10)
			}
			
			if viewModel.showCorrectAnswer {
				VStack() {
					HStack {
						Image(systemName: viewModel.isAnswerCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
							.foregroundColor(viewModel.isAnswerCorrect ? .green : .red)
							.font(.title)
						
						VStack(alignment: .leading) {
							Text(viewModel.isAnswerCorrect ? "Правильно!" : "Правильный порядок:")
							if !viewModel.isAnswerCorrect {
								Text(task.correctSentence.joined(separator: " "))
									.font(.title3)
									.italic()
							}
						}
					}
					.padding()
					.background(Color(hex: viewModel.isAnswerCorrect ? "#D4EDDA" : "#F8D7DA"))
					.cornerRadius(10)
				} .padding(.bottom, 10)
			}
		}
		.safeAreaInset(edge: .bottom) {
			Color.clear.frame(height: 20) // new
		}
	}
		.ignoresSafeArea(.keyboard, edges: .bottom)
		.padding()
	}
}
