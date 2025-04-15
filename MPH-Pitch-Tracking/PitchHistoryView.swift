import SwiftUI

struct PitchHistoryView: View {
    @State private var pitches: [[String: Any]] = []
    @State private var showConfirmDelete = false
    @State private var showingExportSuccess = false
    @State private var exportURL: URL? = nil
    
    // Custom colors
    let customGreen = Color(hex: "#0d3222")
    let customYellow = Color(hex: "#f5c84e")
    
    var body: some View {
        ZStack {
            // Background
            customGreen
                .ignoresSafeArea()
            
            VStack {
                Text("Pitch History")
                    .font(.largeTitle)
                    .foregroundColor(customYellow)
                    .padding()
                
                if pitches.isEmpty {
                    Spacer()
                    Text("No pitches recorded yet")
                        .foregroundColor(customYellow)
                        .font(.headline)
                    Spacer()
                } else {
                    // Pitch list
                    List {
                        ForEach(0..<pitches.count, id: \.self) { index in
                            pitchRow(for: pitches[index])
                        }
                        .listRowBackground(customGreen)
                    }
                    .listStyle(PlainListStyle())
                    .background(customGreen)
                }
                
                HStack(spacing: 20) {
                    // Export button
                    Button(action: {
                        if let url = DatabaseManager.shared.exportToCSV() {
                            exportURL = url
                            showingExportSuccess = true
                        }
                    }) {
                        Text("Export to CSV")
                            .font(.headline)
                            .foregroundColor(customGreen)
                            .padding()
                            .frame(minWidth: 150)
                            .background(customYellow)
                            .cornerRadius(15)
                    }
                    
                    // Clear button
                    Button(action: {
                        showConfirmDelete = true
                    }) {
                        Text("Clear All Data")
                            .font(.headline)
                            .foregroundColor(customGreen)
                            .padding()
                            .frame(minWidth: 150)
                            .background(customYellow)
                            .cornerRadius(15)
                    }
                }
                .padding()
            }
        }
        .onAppear {
            loadPitches()
        }
        .confirmationDialog(
            "Are you sure you want to delete all pitch data?",
            isPresented: $showConfirmDelete,
            titleVisibility: .visible
        ) {
            Button("Delete All", role: .destructive) {
                if DatabaseManager.shared.deleteAllPitches() {
                    loadPitches()
                }
            }
            Button("Cancel", role: .cancel) {}
        }
        .sheet(isPresented: $showingExportSuccess) {
            if let url = exportURL {
                ShareSheet(items: [url])
            }
        }
    }
    
    private func loadPitches() {
        pitches = DatabaseManager.shared.getAllPitches()
    }
    
    private func pitchRow(for pitch: [String: Any]) -> some View {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let timestamp = pitch["timestamp"] as! Date
        let formattedDate = dateFormatter.string(from: timestamp)
        
        return VStack(alignment: .leading, spacing: 4) {
            Text("\(pitch["pitchType"] as? String ?? "") - \(pitch["pitchResult"] as? String ?? "")")
                .font(.headline)
                .foregroundColor(customYellow)
            
            Text(formattedDate)
                .font(.subheadline)
                .foregroundColor(customYellow.opacity(0.8))
            
            if let valueA = pitch["valueA"] as? Int {
                Text("Value A: \(valueA)")
                    .font(.subheadline)
                    .foregroundColor(customYellow)
            }
            
            if let ttpValue = pitch["ttpValue"] as? Int {
                Text("TTP: \(ttpValue)")
                    .font(.subheadline)
                    .foregroundColor(customYellow)
            }
            
            HStack {
                if pitch["fps"] as? Bool == true {
                    Text("FPS")
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(customYellow)
                        .foregroundColor(customGreen)
                        .cornerRadius(8)
                }
                
                if pitch["f2ps"] as? Bool == true {
                    Text("F2PS")
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(customYellow)
                        .foregroundColor(customGreen)
                        .cornerRadius(8)
                }
                
                if pitch["csoop"] as? Bool == true {
                    Text("CSOOP")
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(customYellow)
                        .foregroundColor(customGreen)
                        .cornerRadius(8)
                }
                
                if pitch["lom"] as? Bool == true {
                    Text("LOM")
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(customYellow)
                        .foregroundColor(customGreen)
                        .cornerRadius(8)
                }
            }
        }
        .padding(.vertical, 8)
    }
}

struct PitchHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        PitchHistoryView()
    }
}
