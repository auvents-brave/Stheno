import Testing

@testable import RabFoundation

@Test("Strip HTML tags, decode HTML entities", arguments: [
    ("I told my computer I needed a break, and now it won’t stop sending me KitKat ads.", false, ""),
    ("Temperature: 37&deg;C &plusmn;0.5&deg;", true, "Temperature: 37°C ±0.5°"),
    ("&ldquo;The only way to do great work is to love what you do.&rdquo; — Steve Jobs", true, "“The only way to do great work is to love what you do.” — Steve Jobs"),
    ("My coffee intake today: <debits 3 cups>, <credits 0 productivity>.", false, ""),
    ("2 < 3 and 4 > 1", false, ""),
    ("I tried to catch some <em>fog</em> yesterday. <strong>Mist</strong>.", true, "I tried to catch some fog yesterday. Mist."),
    ("Why did the <b>chicken</b> cross the <i>road</i>? To escape the <span style=\"color:red;\">CSS</span> police!", true, "Why did the chicken cross the road? To escape the CSS police!"),
])
@MainActor
func cleanHTML(_ value: (String, Bool, String)) {
    #expect(isHTML(value.0) == value.1)
    /*
     if value.1 {
         #expect(CleanHTML(from: value.0) == value.2)
     }
     */
}
