import Foundation

// Set user defaults for locale
UserDefaults.standard.set(["fr"], forKey: "AppleLanguages")
UserDefaults.standard.set("fr_FR", forKey: "AppleLocale")
UserDefaults.standard.synchronize()

// Try to force the locale through multiple approaches
setlocale(LC_ALL, "fr_FR.UTF-8")

// Create and set the French locale
let frenchLocale = Locale(identifier: "fr_FR")
print("Configured locale identifier: \(frenchLocale.identifier)")
print("Current locale identifier: \(Locale.current.identifier)")
print("Preferred languages: \(Locale.preferredLanguages)")

// Test some locale-specific formatting
let date = Date()
let numberFormatter = NumberFormatter()
numberFormatter.locale = frenchLocale
numberFormatter.numberStyle = .decimal

let number = 1234.56
print("Number formatting test: \(numberFormatter.string(from: NSNumber(value: number)) ?? "")")

// Print environment variables
print("\nEnvironment Variables:")
print("LANG: \(ProcessInfo.processInfo.environment["LANG"] ?? "not set")")
print("LC_ALL: \(ProcessInfo.processInfo.environment["LC_ALL"] ?? "not set")")
print("LANGUAGE: \(ProcessInfo.processInfo.environment["LANGUAGE"] ?? "not set")")