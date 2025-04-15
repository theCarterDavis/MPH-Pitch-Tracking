import Foundation
import SQLite

class DatabaseManager {
    static let shared = DatabaseManager()
    
    private var db: Connection?
    
    // Table definition
    private let pitchesTable = Table("pitches")
    
    // Column definitions
    private let id = Expression<Int64>("id")
    private let timestamp = Expression<Date>("timestamp")
    private let pitchType = Expression<String>("pitch_type")
    private let pitchResult = Expression<String>("pitch_result")
    private let valueA = Expression<Int?>("value_a")
    private let ttpValue = Expression<Double?>("value_b")
    private let fps = Expression<Bool>("fps")
    private let f2ps = Expression<Bool>("f2ps")
    private let csoop = Expression<Bool>("csoop")
    private let lom = Expression<Bool>("lom")
    
    private init() {
        setupDatabase()
    }
    
    private func setupDatabase() {
        do {
            // Get the document directory path
            let path = NSSearchPathForDirectoriesInDomains(
                .documentDirectory, .userDomainMask, true
            ).first!
            
            // Create database connection
            db = try Connection("\(path)/pitchTracker.sqlite3")
            
            // Create the table if it doesn't exist
            try db?.run(pitchesTable.create(ifNotExists: true) { table in
                table.column(id, primaryKey: .autoincrement)
                table.column(timestamp)
                table.column(pitchType)
                table.column(pitchResult)
                table.column(valueA)
                table.column(ttpValue)
                table.column(fps)
                table.column(f2ps)
                table.column(csoop)
                table.column(lom)
            })
            
            print("Database setup successful")
        } catch {
            print("Database setup failed: \(error)")
        }
    }
    
    // MARK: - Public Methods
    
    func recordPitch(pitchType: String, pitchResult: String, valueA: Int?, ttpValue: Double?,
                    fps: Bool, f2ps: Bool, csoop: Bool, lom: Bool) -> Bool {
        
        guard let db = db else { return false }
        
        let insert = pitchesTable.insert(
            self.timestamp <- Date(),
            self.pitchType <- pitchType,
            self.pitchResult <- pitchResult,
            self.valueA <- valueA,
            self.ttpValue <- ttpValue,
            self.fps <- fps,
            self.f2ps <- f2ps,
            self.csoop <- csoop,
            self.lom <- lom
        )
        
        do {
            try db.run(insert)
            print("Pitch recorded successfully")
            return true
        } catch {
            print("Failed to record pitch: \(error)")
            return false
        }
    }
    
    func getAllPitches() -> [[String: Any]] {
        guard let db = db else { return [] }
        
        var pitches = [[String: Any]]()
        
        do {
            let query = pitchesTable.order(timestamp.desc)
            
            for pitch in try db.prepare(query) {
                let pitchData: [String: Any] = [
                    "id": pitch[id],
                    "timestamp": pitch[timestamp],
                    "pitchType": pitch[pitchType],
                    "pitchResult": pitch[pitchResult],
                    "valueA": pitch[valueA] as Any,
                    "ttpValue": pitch[ttpValue] as Any,
                    "fps": pitch[fps],
                    "f2ps": pitch[f2ps],
                    "csoop": pitch[csoop],
                    "lom": pitch[lom]
                ]
                
                pitches.append(pitchData)
            }
        } catch {
            print("Failed to fetch pitches: \(error)")
        }
        
        return pitches
    }
    
    func exportToCSV() -> URL? {
        let pitches = getAllPitches()
        
        // Create CSV header
        var csvString = "ID,Timestamp,Pitch Type,Pitch Result,MPH,TTP,FPS,F2PS,CSOOP,LOM\n"

        // Add each pitch as a row
        for pitch in pitches {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            
            let timestamp = pitch["timestamp"] as! Date
            let formattedDate = dateFormatter.string(from: timestamp)
            
            let row = [
                "\(pitch["id"] ?? "")",
                formattedDate,
                "\(pitch["pitchType"] ?? "")",
                "\(pitch["pitchResult"] ?? "")",
                "\(pitch["valueA"] ?? "")",
                "\(pitch["tppValue"] != nil ? String(format: "%.2f", pitch["ttpValue"] as! Double) : "")",
                "\(pitch["fps"] as? Bool == true ? "Yes" : "No")",
                "\(pitch["f2ps"] as? Bool == true ? "Yes" : "No")",
                "\(pitch["csoop"] as? Bool == true ? "Yes" : "No")",
                "\(pitch["lom"] as? Bool == true ? "Yes" : "No")"
            ].joined(separator: ",")
            
            csvString.append("\(row)\n")
        }
        
        // Get document directory path
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        // Create a timestamp for the filename
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd_HHmmss"
        let timestamp = dateFormatter.string(from: Date())
        
        // Create file URL
        let fileURL = documentsDirectory.appendingPathComponent("pitch_data_\(timestamp).csv")
        
        // Write to file
        do {
            try csvString.write(to: fileURL, atomically: true, encoding: .utf8)
            print("CSV file created at: \(fileURL.path)")
            return fileURL
        } catch {
            print("Failed to create CSV file: \(error)")
            return nil
        }
    }
    
    func deleteAllPitches() -> Bool {
        guard let db = db else { return false }
        
        do {
            try db.run(pitchesTable.delete())
            print("All pitches deleted")
            return true
        } catch {
            print("Failed to delete pitches: \(error)")
            return false
        }
    }
}
