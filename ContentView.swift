//
// ContentView.swift
// KursachDuolingo
//
// Created by Сергей Пупкевич on 2.09.25.
//

import SwiftUI
import Combine

// MARK: - Язык с иконкой и флагом
enum Language: String, CaseIterable, Identifiable {
	case english = "Английский"
	case spanish = "Испанский"
	case belarussian = "Белорусский"
	
	var id: String { rawValue }
	
	var icon: String {
		switch self {
		case .english: return "🇬🇧💂"
		case .spanish: return "🇪🇸💃"
		case .belarussian: return "🇧🇾🥔"
		}
	}
	
	var flags: String {
		switch self {
		case .english: return "🇬🇧"
		case .spanish: return "🇪🇸"
		case .belarussian: return "🇧🇾"
		}
	}
}

// MARK: - Task Models
struct WordTranslationTask {
	let id = UUID()
	let word: String
	let correctTranslation: String
	let language: Language
}

struct SentenceBuilderTask {
	let id = UUID()
	let correctSentence: [String]
	let language: Language
	
	var shuffledWords: [String] {
		correctSentence.shuffled()
	}
}

struct MultipleChoiceTask {
	let id = UUID()
	let word: String
	let correctTranslation: String
	let options: [String]
	let language: Language
}

// MARK: - Color Extension
extension Color {
	init(hex: String, opacity: Double = 1.0) {
		var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
		hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

		var rgb: UInt64 = 0
		Scanner(string: hexSanitized).scanHexInt64(&rgb)

		let r, g, b: Double
		switch hexSanitized.count {
		case 6:
			r = Double((rgb >> 16) & 0xFF) / 255
			g = Double((rgb >> 8) & 0xFF) / 255
			b = Double(rgb & 0xFF) / 255
		case 8:
			r = Double((rgb >> 24) & 0xFF) / 255
			g = Double((rgb >> 16) & 0xFF) / 255
			b = Double((rgb >> 8) & 0xFF) / 255
		default:
			r = 0; g = 0; b = 0
		}

		self.init(.sRGB, red: r, green: g, blue: b, opacity: opacity)
	}
}

// MARK: - Button Style

struct GrowingButton: ButtonStyle {
	var maxWidth: CGFloat = 200

	func makeBody(configuration: Configuration) -> some View {
		configuration.label
			.font(.system(size: 18, weight: .none))
			.foregroundColor(Color(hex: "#343944", opacity: 0.99))
			.multilineTextAlignment(.center)
			.lineLimit(1)
			.minimumScaleFactor(0.9)
			.padding()
			.frame(maxWidth: maxWidth, maxHeight: 64)
			.background(Color(hex: "#6aa84f", opacity: 0.7))
			.clipShape(Capsule())
			.scaleEffect(configuration.isPressed ? 1.2 : 1.1)
			.animation(.easeOut(duration: 0.4), value: configuration.isPressed)
	}
}

// MARK: - Main Content View
struct ContentView: View {
	@StateObject private var userManager = UserManager()
	@StateObject private var progressModel = ProgressModel()
	
	@State private var showAuthentication = false
	@State private var showAccountSettings = false
	@State private var showProgressModal = false
	@State private var showResetAlert = false
	
	let words = [
		"Выберите язык для изучения",
		"Choose a language to study",
		"Seleccione un idioma para estudiar"
	]
	
	var body: some View {
		ZStack {
			NavigationStack {
				ZStack {
					LinearGradient(
						colors: [Color(hex: "#F8FAFC"), Color(hex: "#EEF2FF")],
						startPoint: .top,
						endPoint: .bottom
					)
					.ignoresSafeArea()
					
					VStack(spacing: 64) {
						
						VStack() {
							// Статус пользователя вверху
							if userManager.isLoggedIn, let user = userManager.currentUser {
								Text("Добро пожаловать, \(user.username)!")
									.font(.title3)
									.scaleEffect(0.95)
									.bold()
									.padding(.top, 43)
							} else {
								Text("Гостевой режим")
									.font(.title3)
									.foregroundColor(.secondary)
									.padding(.top, 43)
							}
						}
						VStack() {
							// Иконка глобуса
							Image(systemName: "globe.europe.africa.fill")
								.resizable()
								.scaleEffect(1.8)
								.frame(width: 120, height: 120)
								.foregroundStyle(Color(hex: "#2c4d1d", opacity: 0.7))
								.padding(.top)
						}
						VStack {
							AnimatedWordsView(words: words, interval: 2)
								.padding(.horizontal, 20)
						}
						
						// Кнопки выбора языка
						VStack(spacing: 64) {
							ForEach(Language.allCases) { lang in
								NavigationLink {
									LanguageLevelView(language: lang)
										.environmentObject(progressModel)
								} label: {
									HStack {
										Text(lang.icon)
										Text(lang.rawValue)
									}
									
								}
								.buttonStyle(GrowingButton())
								.scaleEffect(1.3)
							}
						}
						.padding(.bottom, 40)
						
						Spacer()
					}
				}
				.toolbar {
					
					ToolbarItem(placement: .navigationBarLeading) {
						Button(action: {
							if userManager.isLoggedIn {
								showAccountSettings = true
							} else {
								showAuthentication = true
							}
						}) {
							Image(systemName: userManager.isLoggedIn ? "person.circle.fill" : "person.circle")
								.font(.title2)
								.foregroundColor(Color(hex: "#6aa84f"))
						}
					}
					
					ToolbarItem(placement: .navigationBarTrailing) {
						Menu {
							Button {
								showProgressModal = true
							} label: {
								Label("Прогресс", systemImage: "chart.bar.fill")
							}
							
							Button {
								showResetAlert = true
							} label: {
								Label("Сбросить прогресс", systemImage: "arrow.clockwise.circle")
							}
						} label: {
							Image(systemName: "gearshape.2.fill")
								.font(.title2)
								.foregroundColor(Color(hex: "#8b8589"))
						}
					}
				}
			}
			.sheet(isPresented: $showAuthentication) {
				AuthenticationView()
					.environmentObject(userManager)
			}
			.sheet(isPresented: $showAccountSettings) {
				AccountSettingsView()
					.environmentObject(userManager)
					.environmentObject(progressModel)
			}
			.alert("Сбросить прогресс?", isPresented: $showResetAlert) {
				Button("Отмена", role: .cancel) {}
				Button("Сбросить", role: .destructive) {
					progressModel.resetProgress()
				}
			} message: {
				Text("Весь прогресс будет удален. Это действие нельзя отменить.")
			}
			
			if showProgressModal {
				ProgressModalView(
					isPresented: $showProgressModal,
					progressModel: progressModel
				)
				.transition(.opacity)
				.zIndex(999)
			}
		}
		.environmentObject(userManager)
		.environmentObject(progressModel)
		.onAppear {
			userManager.linkProgressModel(progressModel)
			progressModel.setUser(userManager.currentUser)
		}
		.onChange(of: userManager.currentUser) { _, newUser in
			progressModel.setUser(newUser)
		}
		.animation(.easeInOut(duration: 0.3), value: showProgressModal)
	}

}

// MARK: - Progress Modal View
struct ProgressModalView: View {
	@Binding var isPresented: Bool
	@ObservedObject var progressModel: ProgressModel
	
	var body: some View {
		ZStack {
			Color.black.opacity(0.4)
				.ignoresSafeArea()
				.onTapGesture {
					isPresented = false
				}
			
			VStack(spacing: 0) {
				// Заголовок
				Text("Прогресс по языкам")
					.font(.title2)
					.bold()
					.padding()
					.frame(maxWidth: .infinity)
					.background(Color(hex: "#6aa84f", opacity: 0.7))
					.foregroundColor(.white)
					.cornerRadius(20, corners: [.topLeft, .topRight])
				
				// Содержимое с прогрессом
				ScrollView {
					VStack(spacing: 20) {
						let progressData = progressModel.progressForAllLanguages()
						ForEach(progressData) { languageData in
							VStack(alignment: .leading, spacing: 20) {
								// Название языка с общим прогрессом
								HStack {
									Text("\(languageData.language.flags) \(languageData.language.rawValue)")
										.font(.headline)
										.bold()
									Spacer()
									Text("\(Int(languageData.overallProgress * 100))%")
										.font(.subheadline)
										.foregroundColor(.secondary)
								}
								
								// Общий прогресс языка
								ProgressView(value: languageData.overallProgress)
									.progressViewStyle(LinearProgressViewStyle(tint: Color.blue))
									.scaleEffect(y: 1.5)
								
								// Детальный прогресс по уровням
								VStack(spacing: 12) {
									// Начальный уровень
									HStack {
										Text("Начальный:")
											.font(.caption)
											.foregroundColor(.secondary)
											.frame(width: 85, alignment: .leading)
										ProgressView(value: languageData.beginnerProgress)
											.progressViewStyle(LinearProgressViewStyle(tint: Color.green))
										Text("\(Int(languageData.beginnerProgress * 100))%")
											.font(.caption)
											.foregroundColor(.secondary)
											.frame(width: 35, alignment: .trailing)
									}
									
									// Средний уровень
									HStack {
										Text("Средний:")
											.font(.caption)
											.foregroundColor(.secondary)
											.frame(width: 85, alignment: .leading)
										ProgressView(value: languageData.intermediateProgress)
											.progressViewStyle(LinearProgressViewStyle(tint: Color.orange))
										Text("\(Int(languageData.intermediateProgress * 100))%")
											.font(.caption)
											.foregroundColor(.secondary)
											.frame(width: 35, alignment: .trailing)
									}
									
									// Продвинутый уровень
									HStack {
										Text("Продвинутый:")
											.font(.caption)
											.foregroundColor(.secondary)
											.frame(width: 85, alignment: .leading)
										ProgressView(value: languageData.advancedProgress)
											.progressViewStyle(LinearProgressViewStyle(tint: Color.red))
										Text("\(Int(languageData.advancedProgress * 100))%")
											.font(.caption)
											.foregroundColor(.secondary)
											.frame(width: 35, alignment: .trailing)
									}
								}
							}
							.padding()
							.background(Color(hex: "#F8F9FA"))
							.cornerRadius(12)
						}
					}
					.padding()
				}
				
				// Кнопка закрытия
				Button(action: {
					isPresented = false
				}) {
					Text("Закрыть")
						.font(.headline)
						.foregroundColor(.white)
						.frame(maxWidth: .infinity)
						.frame(height: 50)
						.background(Color(hex: "#6aa84f", opacity: 0.7))
						.cornerRadius(20, corners: [.bottomLeft, .bottomRight])
						
				}
			}
			.background(Color.white)
			.cornerRadius(20)
			.padding(30)
			.shadow(radius: 20)
		}
	}
}


// MARK: - Corner Radius Extension
extension View {
	func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
		clipShape(RoundedCorner(radius: radius, corners: corners))
	}
}

struct RoundedCorner: Shape {
	var radius: CGFloat = .infinity
	var corners: UIRectCorner = .allCorners
	
	func path(in rect: CGRect) -> Path {
		let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
		return Path(path.cgPath)
	}
}

// MARK: - Date Formatter Extension
extension Date {
	func formatted(style: DateFormatter.Style = .medium) -> String {
		let formatter = DateFormatter()
		formatter.locale = Locale(identifier: "ru_RU")
		formatter.dateStyle = style
		formatter.timeStyle = .short
		return formatter.string(from: self)
	}
	
	func relativeTime() -> String {
		let formatter = RelativeDateTimeFormatter()
		formatter.locale = Locale(identifier: "ru_RU")
		formatter.unitsStyle = .full
		return formatter.localizedString(for: self, relativeTo: Date())
	}
}


// MARK: - Account Settings View
struct AccountSettingsView: View {
	@EnvironmentObject var userManager: UserManager
	@EnvironmentObject var progressModel: ProgressModel
	@Environment(\.dismiss) private var dismiss
	
	@State private var showResetConfirmation = false
	
	var body: some View {
		NavigationStack {
			ZStack {
				LinearGradient(
					colors: [Color(hex: "#F8FAFC"), Color(hex: "#EEF2FF")],
					startPoint: .top,
					endPoint: .bottom
				)
				.ignoresSafeArea()
				
				ScrollView {
					VStack(spacing: 30) {
						if let user = userManager.currentUser {
							// MARK: - User Profile Section
							VStack(spacing: 15) {
								Image(systemName: "person.circle.fill")
									.resizable()
									.frame(width: 100, height: 100)
									.foregroundStyle(Color(hex: "#6aa84f", opacity: 0.7))
								
								Text(user.username)
									.font(.title)
									.bold()
								
								Text(user.email)
									.font(.subheadline)
									.foregroundColor(.secondary)
							}
							.padding(.top, 20)
							
							// MARK: - Account Information Section
							VStack(alignment: .leading, spacing: 15) {
								Text("Информация об аккаунте")
									.font(.headline)
									.foregroundColor(.secondary)
									.padding(.horizontal)
								
								VStack(spacing: 0) {
									// Registration Date
									HStack {
										VStack(alignment: .leading, spacing: 4) {
											Text("Дата регистрации")
												.font(.subheadline)
												.foregroundColor(.secondary)
											Text(user.createdAt.formatted(style: .medium))
												.font(.body)
												.bold()
										}
										Spacer()
										Image(systemName: "calendar.badge.plus")
											.font(.title2)
											.foregroundColor(Color(hex: "#6aa84f", opacity: 0.7))
									}
									.padding()
									.background(Color.white.opacity(0.8))
									
									Divider()
										.padding(.horizontal)
									
									// Last Login Date
									HStack {
										VStack(alignment: .leading, spacing: 4) {
											Text("Последний вход")
												.font(.subheadline)
												.foregroundColor(.secondary)
											if let lastLogin = user.lastLoginAt {
												Text(lastLogin.formatted(style: .medium))
													.font(.body)
													.bold()
												Text(lastLogin.relativeTime())
													.font(.caption)
													.foregroundColor(.secondary)
											} else {
												Text("Это первый вход")
													.font(.body)
													.italic()
													.foregroundColor(.secondary)
											}
										}
										Spacer()
										Image(systemName: "clock.arrow.circlepath")
											.font(.title2)
											.foregroundColor(Color(hex: "#6aa84f", opacity: 0.7))
									}
									.padding()
									.background(Color.white.opacity(0.8))
								}
								.cornerRadius(12)
								.shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
							}
							.padding(.horizontal)
							.padding(.top, 10)
							
							// MARK: - Action Buttons Section
							VStack(spacing: 15) {
								Button(action: {
									showResetConfirmation = true
								}) {
									Label("Сбросить прогресс", systemImage: "arrow.counterclockwise")
										.frame(maxWidth: .infinity)
										.padding()
										.background(Color.orange.opacity(0.2))
										.foregroundColor(.orange)
										.cornerRadius(10)
								}
								
								Button(action: {
									userManager.logout()
									dismiss()
								}) {
									Label("Выйти из аккаунта", systemImage: "rectangle.portrait.and.arrow.right")
										.frame(maxWidth: .infinity)
										.padding()
										.background(Color.red.opacity(0.2))
										.foregroundColor(.red)
										.cornerRadius(10)
								}
							}
							.padding(.horizontal, 30)
							.padding(.top, 20)
							.padding(.bottom, 40)
						}
					}
				}
			}
			.navigationTitle("Настройки аккаунта")
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem(placement: .navigationBarTrailing) {
					Button("Готово") {
						dismiss()
					}
				}
			}
			.alert("Сбросить прогресс?", isPresented: $showResetConfirmation) {
				Button("Отмена", role: .cancel) {}
				Button("Сбросить", role: .destructive) {
					progressModel.resetProgress()
				}
			} message: {
				Text("Весь прогресс будет удален. Это действие нельзя отменить.")
			}
		}
	}
}


// MARK: - Animated Words View
struct AnimatedWordsView: View {
	@State private var currentIndex = 0
	@State private var timer: Timer?
	
	let words: [String]
	let interval: TimeInterval
	
	init(words: [String], interval: TimeInterval = 1.8) {
		self.words = words
		self.interval = interval
	}
	
	var body: some View {
		Text(words[currentIndex])
			.font(.largeTitle)
			.bold()
			.multilineTextAlignment(.leading)
			.minimumScaleFactor(0.5)
			.lineLimit(2)
			.frame(height: 90)
			.id(currentIndex)
			.transition(.opacity.combined(with: .scale))
			.animation(.easeInOut(duration: 0.8), value: currentIndex)
			.onAppear {
				startTimer()
			}
			.onDisappear {
				stopTimer()
			}
		
	}
	
	private func startTimer() {
		timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
			withAnimation {
				currentIndex = (currentIndex + 1) % words.count
			}
		}
	}
	
	private func stopTimer() {
		timer?.invalidate()
		timer = nil
	}
}

#Preview {
	ContentView()
}
