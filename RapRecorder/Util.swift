import Foundation

class Util {
    class func initRecordsDirectory() -> URL {
        let fileManager = FileManager.default
        let recordsPath = self.documentsDirectory().appendingPathComponent("raprecords")
        
        if !fileManager.fileExists(atPath: recordsPath.path) {
            // Create new raprecords directory.
            do {
                try fileManager.createDirectory(atPath: recordsPath.path, withIntermediateDirectories: true, attributes: nil)
            } catch {
                NSLog("Could not create documents directory.")
            }
        } else {
            // Clear raprecords directory.
            do {
                let files = try fileManager.contentsOfDirectory(atPath: recordsPath.path)
                for file in files {
                    try fileManager.removeItem(at: recordsPath.appendingPathComponent(file))
                }
            } catch {
                print("Could not clear raprecords folder")
            }
        }
        
        return recordsPath
    }
    
    class func initRapsDirectory() -> URL {
        let fileManager = FileManager()
        let rapsPath = self.documentsDirectory().appendingPathComponent("raps")
        
        if !fileManager.fileExists(atPath: rapsPath.path) {
            // Create new raprecords directory.
            do {
                try fileManager.createDirectory(atPath: rapsPath.path, withIntermediateDirectories: true, attributes: nil)
            } catch {
                NSLog("Could not create documents directory.")
            }
        }
        
        return rapsPath
    }
    
    class func documentsDirectory() -> URL {
        let documentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask)
        return (documentsDirectory.first)!
    }
    
    class func beatPath(file: String) -> URL? {
        guard let path = Bundle.main.url(forResource: file, withExtension: "mp3") else {
            return nil
        }
        return path
    }
    
    class func generateFileNameUsingCurDateTime(withExtension ext: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d-M-yyyy_h:m:s"
        let datetime: String = dateFormatter.string(from: Date())
        let filename: String = datetime + ext
        return filename
    }
    
    class func generateTempFilePath(withExtension ext: String) -> URL {
        let path = "\(NSTemporaryDirectory())\(self.generateFileNameUsingCurDateTime(withExtension: ext))"
        return URL(fileURLWithPath: path)
    }
    
    class func generateDocumentFilePath(withExtension ext: String) -> URL {
        let path = "\(self.documentsDirectory().path)/\(self.generateFileNameUsingCurDateTime(withExtension: ext))"
        return URL(fileURLWithPath: path)
    }
}

