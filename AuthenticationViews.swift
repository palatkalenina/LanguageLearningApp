//
// AuthenticationViews.swift
// KursachDuolingo
//
// Created by Сергей Пупкевич on 16.09.25.
//

import SwiftUI

// MARK: - Authentication View
struct AuthenticationView: View {
	@EnvironmentObject var userManager: UserManager
	
	@State private var isLoginMode = true
	@State private var email = ""
	@State private var username = ""
	@State private var password = ""
	@State private var confirmPassword = ""
	@State private var errorMessage = ""
	@State private var showError = false
	
	@Environment(\.dismiss) private var dismiss
	
	var body: some View {
		NavigationStack {
			ZStack {
				// Фон в стиле приложения
				LinearGradient(
					colors: [Color(hex: "#F8FAFC"), Color(hex: "#EEF2FF")],
					startPoint: .top,
					endPoint: .bottom
				)
				.ignoresSafeArea()
				
				ScrollView {
					VStack(spacing: 30) {
						// Заголовок с иконкой
						VStack(spacing: 20) {
							Image(systemName: "person.circle.fill")
								.resizable()
								.frame(width: 100, height: 100)
								.foregroundStyle(Color(hex: "#6aa84f", opacity: 0.7))
							
							Text(isLoginMode ? "Вход" : "Регистрация")
								.font(.largeTitle)
								.bold()
						}
						.padding(.top, 40)
						
						// Форма
						VStack(spacing: 20) {
							// Email
							VStack(alignment: .leading, spacing: 8) {
								Text("Email")
									.font(.subheadline)
									.foregroundColor(.secondary)
								
								TextField("example@mail.com", text: $email)
									.textFieldStyle(CustomTextFieldStyle())
									.textInputAutocapitalization(.never)
									.keyboardType(.emailAddress)
									.autocorrectionDisabled()
							}
							
							// Username (только при регистрации)
							if !isLoginMode {
								VStack(alignment: .leading, spacing: 8) {
									Text("Имя пользователя")
										.font(.subheadline)
										.foregroundColor(.secondary)
									
									TextField("Username", text: $username)
										.textFieldStyle(CustomTextFieldStyle())
										.textInputAutocapitalization(.never)
										.autocorrectionDisabled()
								}
							}
							
							// Password
							VStack(alignment: .leading, spacing: 8) {
								Text("Пароль")
									.font(.subheadline)
									.foregroundColor(.secondary)
								
								SecureField("••••••••", text: $password)
									.textFieldStyle(CustomTextFieldStyle())
							}
							
							// Confirm Password (только при регистрации)
							if !isLoginMode {
								VStack(alignment: .leading, spacing: 8) {
									Text("Подтвердите пароль")
										.font(.subheadline)
										.foregroundColor(.secondary)
									
									SecureField("••••••••", text: $confirmPassword)
										.textFieldStyle(CustomTextFieldStyle())
								}
							}
						}
						.padding(.horizontal, 30)
						
						// Кнопка действия
						Button(action: handleAuthentication) {
							Text(isLoginMode ? "Войти" : "Зарегистрироваться")
								.font(.headline)
								.foregroundColor(.white)
								.frame(maxWidth: .infinity)
								.frame(height: 55)
								.background(Color(hex: "#6aa84f"))
								.cornerRadius(15)
						}
						.padding(.horizontal, 30)
						.disabled(!isFormValid)
						.opacity(isFormValid ? 1.0 : 0.6)
						
						// Переключение режима
						Button(action: {
							withAnimation {
								isLoginMode.toggle()
								clearFields()
							}
						}) {
							HStack {
								Text(isLoginMode ? "Нет аккаунта?" : "Уже есть аккаунт?")
									.foregroundColor(.secondary)
								Text(isLoginMode ? "Зарегистрироваться" : "Войти")
									.foregroundColor(Color(hex: "#6aa84f"))
									.bold()
							}
						}
						
						Spacer()
					}
				}
			}
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem(placement: .navigationBarTrailing) {
					Button("Закрыть") {
						dismiss()
					}
				}
			}
			.alert("Ошибка", isPresented: $showError) {
				Button("OK", role: .cancel) {}
			} message: {
				Text(errorMessage)
			}
		}
	}
	
	// MARK: - Helpers
	
	private var isFormValid: Bool {
		if isLoginMode {
			return !email.isEmpty && !password.isEmpty
		} else {
			return !email.isEmpty && !username.isEmpty && !password.isEmpty && password == confirmPassword && password.count >= 8
		}
	}
	
	private func handleAuthentication() {
		if isLoginMode {
			performLogin()
		} else {
			performRegistration()
		}
	}
	
	private func performLogin() {
		let result = userManager.login(email: email, password: password)
		
		switch result {
		case .success:
			dismiss()
		case .failure(let error):
			errorMessage = error.errorDescription ?? "Неизвестная ошибка"
			showError = true
		}
	}
	
	private func performRegistration() {
		guard password == confirmPassword else {
			errorMessage = "Пароли не совпадают"
			showError = true
			return
		}
		
		guard password.count >= 8 else {
			errorMessage = "Пароль должен содержать минимум 8 символов"
			showError = true
			return
		}
		
		let result = userManager.register(email: email, username: username, password: password)
		
		switch result {
		case .success:
			dismiss()
		case .failure(let error):
			errorMessage = error.errorDescription ?? "Неизвестная ошибка"
			showError = true
		}
	}
	
	private func clearFields() {
		email = ""
		username = ""
		password = ""
		confirmPassword = ""
		errorMessage = ""
	}
}

// MARK: - Custom Text Field Style
struct CustomTextFieldStyle: TextFieldStyle {
	func _body(configuration: TextField<Self._Label>) -> some View {
		configuration
			.padding()
			.background(Color.white.opacity(0.9))
			.cornerRadius(10)
			.overlay(
				RoundedRectangle(cornerRadius: 10)
					.stroke(Color.gray.opacity(0.3), lineWidth: 1)
			)
	}
}

#Preview {
	AuthenticationView()
		.environmentObject(UserManager())
}
