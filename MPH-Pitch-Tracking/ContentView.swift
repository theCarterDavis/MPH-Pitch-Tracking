import SwiftUI

/// Main content view for the Pitch Tracking application
struct ContentView: View {
    // MARK: - State Properties
    
    // Pitch selection state
    @State private var selectedPitchType = ""
    @State private var selectedPitchResult = ""
    
    // Number input state
    @State private var mphValue: Int? = nil
    @State private var ttpValue: Double? = nil
    @State private var numberInputA: String = ""
    @State private var numberInputB: String = ""
    
    // Toggle button states
    @State private var FPS = false
    @State private var F2PS = false
    @State private var CSOOP = false
    @State private var LOM = false
    
    // Alert state
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    
    // Export state
    @State private var showExportSheet = false
    @State private var exportURL: URL? = nil
    
    // MARK: - Constants
    
    // Available options for selection
    let pitchTypes = ["Fastball", "Curveball", "Slider", "Changeup"]
    let pitchResults = ["In Play No Out", "Called Strike", "Swinging Strike", "Ball"]
    
    // Custom colors
    let customGreen = Color(hex: "#0d3222")
    let customYellow = Color(hex: "#f5c84e")
    
    // MARK: - Helper Methods
    
    /// Validates and filters input to ensure only numbers are entered
    /// - Parameter input: The string to validate
    /// - Returns: A filtered string containing only numeric characters
    func validateInteger(_ input: String) -> String {
        let filtered = input.filter { $0.isNumber }
        return filtered
    }
    
    /// Resets all selection and input fields to their default values
    func clearSelections() {
        selectedPitchType = ""
        selectedPitchResult = ""
        numberInputA = ""
        numberInputB = ""
        mphValue = nil
        ttpValue = nil
        
        FPS = false
        F2PS = false
        CSOOP = false
        LOM = false
    }
    
    func validateDecimal(_ input: String) -> String {
        // Allow only digits and at most one decimal point
        var hasDecimal = false
        let filteredText = input.filter { char in
            if char == "." {
                if hasDecimal {
                    return false // Reject additional decimal points
                } else {
                    hasDecimal = true
                    return true
                }
            }
            return char.isNumber
        }
        return filteredText
    }
    
    /// Records a pitch in the database
    func recordPitch() {
        // Validate required fields
        guard !selectedPitchType.isEmpty else {
            showAlert(title: "Missing Information", message: "Please select a pitch type")
            return
        }
        
        guard !selectedPitchResult.isEmpty else {
            showAlert(title: "Missing Information", message: "Please select a pitch result")
            return
        }
        
        let ttpValue = Double(numberInputB)
        // Record the pitch
        let success = DatabaseManager.shared.recordPitch(
            pitchType: selectedPitchType,
            pitchResult: selectedPitchResult,
            valueA: mphValue,
            ttpValue: ttpValue,
            fps: FPS,
            f2ps: F2PS,
            csoop: CSOOP,
            lom: LOM
        )
        
        if success {
           // showAlert(title: "Success", message: "Pitch recorded successfully")
            clearSelections()
        } else {
            showAlert(title: "Error", message: "Failed to record pitch")
        }
    }
    
    /// Shows an alert with the given title and message
    func showAlert(title: String, message: String) {
        alertTitle = title
        alertMessage = message
        showAlert = true
    }
    
    /// Exports the database to a CSV file
    func exportCSV() {
        if let url = DatabaseManager.shared.exportToCSV() {
            exportURL = url
            showExportSheet = true
        } else {
            showAlert(title: "Export Failed", message: "Unable to export data to CSV")
        }
    }
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            // Background
            customGreen
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Title
                Text("Pitch Tracking")
                    .font(.largeTitle)
                    .foregroundColor(customYellow)
                    .padding()
                
                // Main content area with two columns
                HStack(spacing: 20) {
                    // Left Column - Pitch Type
                    pitchTypeColumn
                    
                    // Right Column - Pitch Result
                    pitchResultColumn
                }
                
                // Toggle buttons row
                toggleButtonsRow
                
                // Selection feedback
                selectionFeedback
                
                HStack(spacing: 20){
                    // Action buttons
                    clearButton
                    
                    recordButton
                }
                
                // Export button
                exportButton
                
                Spacer()
            }
            .padding()
            .alert(alertTitle, isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
            .sheet(isPresented: $showExportSheet) {
                if let url = exportURL {
                    ShareSheet(items: [url])
                }
            }
        }
    }
    
    // MARK: - UI Components
    
    /// Left column containing pitch type selection and first number input
    private var pitchTypeColumn: some View {
        VStack(spacing: 20) {
            Text("Pitch Type")
                .font(.headline)
                .foregroundColor(customYellow)
            
            VStack(spacing: 15) {
                // Pitch type radio buttons
                ForEach(pitchTypes, id: \.self) { pitchType in
                    RadioButtonLarge(
                        text: pitchType,
                        isSelected: selectedPitchType == pitchType,
                        action: { selectedPitchType = pitchType },
                        activeColor: customYellow,
                        inactiveColor: customGreen
                    )
                }
                
                VStack(alignment: .leading, spacing: 5) {
                    Text("MPH")
                        .font(.headline)
                        .foregroundColor(customYellow)
                        .padding(.leading, 10)
                    
                    TextField("", text: $numberInputA)
                        .keyboardType(.numberPad)
                        .onChange(of: numberInputA) { _, newValue in
                            numberInputA = validateInteger(newValue)
                            mphValue = Int(numberInputA)
                        }
                        .modifier(CustomTextFieldStyle(
                            activeColor: customYellow,
                            inactiveColor: customGreen
                        ))
                }
                .padding(.top, 5)

            }
        }
        .frame(width: 220)
    }
    
    /// Right column containing pitch result selection and second number input
    private var pitchResultColumn: some View {
        VStack(spacing: 20) {
            Text("Pitch Result")
                .font(.headline)
                .foregroundColor(customYellow)
            
            VStack(spacing: 15) {
                // Pitch result radio buttons
                ForEach(pitchResults, id: \.self) { result in
                    RadioButtonLarge(
                        text: result,
                        isSelected: selectedPitchResult == result,
                        action: { selectedPitchResult = result },
                        activeColor: customYellow,
                        inactiveColor: customGreen
                    )
                }
                
                VStack(alignment: .leading, spacing: 5) {
                    Text("TTP")
                        .font(.headline)
                        .foregroundColor(customYellow)
                        .padding(.leading, 10)
                    
                    TextField("Enter TTP", text: $numberInputB)
                        .keyboardType(.decimalPad) // Changed to decimal pad
                        .onChange(of: numberInputB) { _, newValue in
                            numberInputB = validateDecimal(newValue) // Use decimal validation
                            // You might want to parse this as a Double instead of Int
                            // ttpValue = Int(numberInputB) - remove or modify this line
                        }
                        .modifier(CustomTextFieldStyle(
                            activeColor: customYellow,
                            inactiveColor: customGreen
                        ))
                }
                .padding(.top, 5)
            }
        }
        .frame(width: 220)
    }
    
    /// Row of toggle buttons for additional options
    private var toggleButtonsRow: some View {
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
    }
    
    /// Displays feedback about the current selections
    private var selectionFeedback: some View {
        VStack {
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
        }
    }
    
    private var clearButton: some View {
        Button(action: {
            clearSelections()
        }) {
            Text("Clear Selections")
                .font(.headline)
                .foregroundColor(customGreen)
                .padding()
                .frame(width: 200, height: 50)
                .background(customYellow)
                .cornerRadius(15)
        }
    }
    
    /// Button to record the pitch and clear selections
    private var recordButton: some View {
        Button(action: {
            recordPitch()
        }) {
            Text("Record Pitch")
                .font(.headline)
                .foregroundColor(customGreen)
                .padding()
                .frame(width: 200, height: 50)
                .background(customYellow)
                .cornerRadius(15)
        }
    }
    
    /// Button to export data to CSV
    private var exportButton: some View {
        Button(action: {
            exportCSV()
        }) {
            Text("Export to CSV")
                .font(.headline)
                .foregroundColor(customGreen)
                .padding()
                .frame(width: 200, height: 50)
                .background(customYellow)
                .cornerRadius(15)
        }
        .padding(.top)
    }
}

// MARK: - Share Sheet for Exporting Files

struct ShareSheet: UIViewControllerRepresentable {
    var items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Custom Styles and Components

/// Custom style for text input fields
struct CustomTextFieldStyle: ViewModifier {
    let activeColor: Color
    let inactiveColor: Color
    
    func body(content: Content) -> some View {
        content
            .foregroundColor(activeColor)
            .accentColor(activeColor)  // Makes the cursor color match
            .padding()
            .frame(width: 220, height: 60)
            .background(inactiveColor)
            .cornerRadius(15)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(activeColor, lineWidth: 2)
            )
            .tint(activeColor)  // Affects the placeholder color
    }
}

/// Custom radio button with button-like appearance
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

/// Custom toggle style that looks like a button
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

// MARK: - Extensions

/// Extension to allow creating colors from hex strings
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

// MARK: - Preview Provider

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
