import SwiftUI

struct ContentView: View {
    @State private var selectedPitchType = ""
    @State private var selectedPitchResult = ""
    @State private var valueA: Int? = nil
    @State private var valueB: Int? = nil
    @State private var numberInputA: String = ""
    @State private var numberInputB: String = ""
    @State private var FPS = false
    @State private var F2PS = false
    @State private var CSOOP = false
    @State private var LOM = false
    
    struct CustomTextFieldStyle: ViewModifier {
        let activeColor: Color
        let inactiveColor: Color
        
        func body(content: Content) -> some View {
            content
                .foregroundColor(activeColor)
                .accentColor(activeColor)  // This makes the cursor color match
                .padding()
                .frame(width: 220, height: 60)
                .background(inactiveColor)
                .cornerRadius(15)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(activeColor, lineWidth: 2)
                )
                .tint(activeColor)  // This affects the placeholder color
        }
    }
    
    
    func validateInteger(_ input: String) -> String {
        let filtered = input.filter { $0.isNumber }
        return filtered
    }
    
    let pitchTypes = ["Fastball", "Curveball", "Slider", "Changeup"]
    let pitchResults = ["In Play No Out", "Called Strike", "Swinging Strike", "Ball"]
    
    // Custom colors
    let customGreen = Color(hex: "#0d3222")
    let customYellow = Color(hex: "#f5c84e")
    
    func clearSelections() {
           selectedPitchType = ""
           selectedPitchResult = ""
           numberInputA = ""
           numberInputB = ""

           FPS = false
           F2PS = false
           CSOOP = false
           LOM = false
       }
    
    
    var body: some View {
        ZStack {
            customGreen
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("Pitch Tracking")
                    .font(.largeTitle)
                    .foregroundColor(customYellow)
                    .padding()
                
                HStack(spacing: 20) {
                    // Left Column
                    VStack(spacing: 20) {
                        Text("Pitch Type")
                            .font(.headline)
                            .foregroundColor(customYellow)
                        
                        VStack(spacing: 15) {
                            ForEach(pitchTypes, id: \.self) { pitchType in
                                RadioButtonLarge(
                                    text: pitchType,
                                    isSelected: selectedPitchType == pitchType,
                                    action: { selectedPitchType = pitchType },
                                    activeColor: customYellow,
                                    inactiveColor: customGreen
                                )
                            }
                            TextField("Enter first number", text: $numberInputA)
                                .keyboardType(.numberPad)
                                .onChange(of: numberInputA) { _, newValue in
                                    numberInputA = validateInteger(newValue)
                                    valueA = Int(numberInputA)
                                }
                                .modifier(CustomTextFieldStyle(
                                    activeColor: customYellow,
                                    inactiveColor: customGreen
                                ))
                                .padding()
                        }
                    }
                    .frame(width: 220)
                    
                    // Right Column
                    VStack(spacing: 20) {
                        Text("Pitch Result")
                            .font(.headline)
                            .foregroundColor(customYellow)
                        
                        VStack(spacing: 15) {
                            ForEach(pitchResults, id: \.self) { result in
                                RadioButtonLarge(
                                    text: result,
                                    isSelected: selectedPitchResult == result,
                                    action: { selectedPitchResult = result },
                                    activeColor: customYellow,
                                    inactiveColor: customGreen
                                )
                            }
                            TextField("Enter first number", text: $numberInputB)
                                .keyboardType(.numberPad)
                                .onChange(of: numberInputA) { _, newValue in
                                    numberInputA = validateInteger(newValue)
                                    valueA = Int(numberInputA)
                                }
                                .modifier(CustomTextFieldStyle(
                                    activeColor: customYellow,
                                    inactiveColor: customGreen
                                ))
                                .padding()
                        }
                    }
                    .frame(width: 220)
                }
                
                // Row of checkboxes
                HStack(spacing: 15) {
                    Toggle("FPS", isOn: $FPS)
                        .toggleStyle(ButtonToggleStyle(activeColor: customYellow, inactiveColor: customGreen))
                    
                    Toggle("F2PS", isOn: $F2PS)
                        .toggleStyle(ButtonToggleStyle(activeColor: customYellow, inactiveColor: customGreen))
                    
                    Toggle("CSOOP", isOn: $CSOOP)
                        .toggleStyle(ButtonToggleStyle(activeColor: customYellow, inactiveColor: customGreen))
                    
                    Toggle("LOM", isOn: $LOM)
                        .toggleStyle(ButtonToggleStyle(activeColor: customYellow, inactiveColor: customGreen))
                }
                .padding()
                
                // Selection feedback
                if !selectedPitchType.isEmpty {
                    Text("Selected Pitch: \(selectedPitchType)")
                        .foregroundColor(customYellow)
                        .padding(.top)
                }
                if !selectedPitchResult.isEmpty {
                    Text("Selected Result: \(selectedPitchResult)")
                        .foregroundColor(customYellow)
                        .padding(.bottom)
                }
                
                Button(action: {
                                   clearSelections()
                               }) {
                                   Text("Record Pitch")
                                       .font(.headline)
                                       .foregroundColor(customGreen)
                                       .padding()
                                       .frame(width: 200, height: 50)
                                       .background(customYellow)
                                       .cornerRadius(15)
                               }
                
                Spacer()
            }
            .padding()
        }
    }
}

// Color extension to support hex colors
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// Custom Radio Button View with Button-like appearance
struct RadioButtonLarge: View {
    let text: String
    let isSelected: Bool
    let action: () -> Void
    let activeColor: Color
    let inactiveColor: Color
    
    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.headline)
                .foregroundColor(isSelected ? inactiveColor : activeColor)
                .padding()
                .frame(width: 220, height: 60)
                .background(isSelected ? activeColor : inactiveColor)
                .cornerRadius(15)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(activeColor, lineWidth: 2)
                )
        }
    }
}

// Custom button-style toggle
struct ButtonToggleStyle: ToggleStyle {
    let activeColor: Color
    let inactiveColor: Color
    
    func makeBody(configuration: Configuration) -> some View {
        Button(action: { configuration.isOn.toggle() }) {
            HStack {
                configuration.label
                    .font(.headline)
                    .foregroundColor(configuration.isOn ? inactiveColor : activeColor)
                    .padding()
                    .frame(width: 120, height: 45)
                    .background(configuration.isOn ? activeColor : inactiveColor)
                    .cornerRadius(15)
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(activeColor, lineWidth: 2)
                    )
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
