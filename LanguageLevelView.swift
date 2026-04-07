//
//  LanguageLevelView.swift
//  KursachDuolingo
//
//  Created by Сергей Пупкевич on 18.09.25.
//

import SwiftUI

// MARK: - Экран выбора уровня языка
struct LanguageLevelView: View {
	let language: Language
	@EnvironmentObject var progressModel: ProgressModel

	var body: some View {

		ZStack {
			LinearGradient(
				colors: [Color(hex: "#F8FAFC"), Color(hex: "#EEF2FF")],
				startPoint: .top,
				endPoint: .bottom
			)
			.ignoresSafeArea()
			
			VStack(spacing: 20) {

				Text("Выбранный язык:  \(language.rawValue)")
					.lineLimit(1)
					.minimumScaleFactor(0.9)
					.font(.title2)
					.bold()
					.padding(.bottom,40)
				Text("\(language.flags)")
					.font(.system(size: 200))
					.padding(.top, -60)
					.padding(.bottom, 12)
					.bold()
				Text("Выбери свой уровень знаний:")

				VStack(spacing: 40) {
					ForEach(["Начальный", "Средний", "Продвинутый"], id: \.self) { level in
						NavigationLink {
							TasksView(language: language, level: level)
								.environmentObject(progressModel)
						} label: {
							Text(level)
								.frame(width: 260, height: 100)
								.background(level == "Начальный" ? Color(hex: "#BFDBFE", opacity: 0.7) : level == "Средний" ? Color(hex: "#60A5FA", opacity: 0.7) : Color(hex: "#2563EB", opacity: 0.7))
								.foregroundColor(.black)
								.font(.title3)
								.clipShape(Capsule())
						}
					}
				}
			}
			.padding()
			.ignoresSafeArea(.keyboard, edges: .bottom)
		}
	}
}

#Preview {
	LanguageLevelView(language: .english)
		.environmentObject(ProgressModel())
}
