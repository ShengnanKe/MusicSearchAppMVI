//
//  FAFileManager.swift
//  MusicSearchAppMVI
//
//  Created by KKNANXX on 7/4/24.
//

import Foundation

class FAFileManager: NSObject {
    
    static let shared: FAFileManager = {
        let instance = FAFileManager()
        return instance
    }()
    // static let shared: FAFileManager = FAFileManager()
    
    private override init() {
        super.init()
    }
    
    // URI vs URL
    // ftp://jkfjkd/dkfjd // URI
    // https://
    func getDocumentDirectory() -> URL? {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    }
    
    func getDirectory(for directoryName: String) -> URL? {
        let fileManager = FileManager.default
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        let directoryURL = documentsDirectory.appendingPathComponent(directoryName)
        if !fileManager.fileExists(atPath: directoryURL.path) {
            do {
                try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("Failed to create directory: \(error)")
                return nil
            }
        }
        return directoryURL
    }
    
    func libraryDirectoryPath() -> URL? {
        if let libraryDirectoryURL = FileManager.default.urls(for: FileManager.SearchPathDirectory.libraryDirectory, in: .userDomainMask).first {
            return libraryDirectoryURL
        }
        return nil
    }
    
    func tempDirectoryPath() -> URL {
        return FileManager.default.temporaryDirectory
    }
    
    /*
     - isWritable
     - isReadble
     - isExists
     */
    
    func isWritable(file atPath: URL) -> Bool {
        return FileManager.default.isWritableFile(atPath: atPath.path)
    }
    
    func isReadable(file atPath: URL) -> Bool {
        return FileManager.default.isReadableFile(atPath: atPath.path)
    }
    
    func isExist(file atPath: URL) -> Bool {
        return FileManager.default.fileExists(atPath: atPath.path)
    }
    
    /*
     Directory (folder)
     - create directory (folder) - DONE
     - get-all-file from directory
     - delete file -  Done
     - create file (write a file) - DONE
     - read file - Done
     - Update file (delete old file, create new file with same name)
     - move file - Done
     - rename file - Done
     - Copy file -  Done
     - changeExension (.txt, .png, .jpg, .jpeg) -  Done
     */
    
    func writeFileIn(containingString: String, to path: URL, with name: String) -> Bool {
        let filePath = path.path
        let completePath = filePath + "/" + name
        let data: Data? = containingString.data(using: .utf8)
        return FileManager.default.createFile(atPath: completePath, contents: data, attributes: nil)
    }
    
    func writeFileIn(folder: String, containingData: Data, to path: URL, with name: String) -> Bool {
        let filePath = path.path + "/" + folder + "/" + name
        if self.writeDirectory(folder: folder, to: path) {}
        return FileManager.default.createFile(atPath: filePath, contents: containingData, attributes: nil)
    }
    
    func writeFileIn(containingData: Data, to path: URL, with name: String) -> Bool {
        let filePath = path.appendingPathComponent(name)
        return FileManager.default.createFile(atPath: filePath.path, contents: containingData, attributes: nil)
    }
    
    func readFile(at path: URL, withName: String) -> Data? {
        let completePath = path.appendingPathComponent(withName)
        return FileManager.default.contents(atPath: completePath.path)
    }
    
    func writeDirectory(folder: String, to path: URL) -> Bool {
        
        _ = path.path + "/" + folder
        if let documentDirectory = self.getDocumentDirectory() {
            let path = documentDirectory.appendingPathComponent(folder)
            if !self.isExist(file: path) {
                do {
                    try FileManager.default.createDirectory(at: path, withIntermediateDirectories: true, attributes: nil)
                    return true
                }
                catch {
                    print(error)
                }
            }
        }
        
        return false
    }
    
    func readFile(at path: URL, withName: String) -> String? {
        
        let completePath = path.path + "/" + withName
        if let fileContent = FileManager.default.contents(atPath: completePath) {
            if let fileStringData = String(bytes: fileContent, encoding: .utf8) {
                return fileStringData
            }
        }
        return nil
    }
    
    func readFile(at path: URL, withNameForData: String) -> Data? {
        
        let completePath = path.path + "/" + withNameForData
        if let fileContent = FileManager.default.contents(atPath: completePath) {
            return fileContent
        }
        
        return nil
    }
    func deleteFile(at path: URL, with name: String) -> Bool {
        let filePath = path.appendingPathComponent(name)
        do {
            try FileManager.default.removeItem(at: filePath)
            return true
        } catch {
            print("Error deleting file: \(error.localizedDescription)")
            return false
        }
    }
    
    func deleteFile(at path: URL,withfolder fname: String, withfile name: String) -> Bool
    {
        var makeFilePath = path.appendingPathComponent(fname)
        makeFilePath = makeFilePath.appendingPathComponent(name)
        do {
            try FileManager.default.removeItem(at: makeFilePath)
            
            return true
        }
        catch {
            print(error)
        }
        
        return false
    }
    func moveFile(from originURL: URL, to destinationURL: URL) -> Bool {
        do {
            try FileManager.default.moveItem(at: originURL, to: destinationURL)
            return true
        } catch {
            print("Error moving file: \(error.localizedDescription)")
            return false
        }
    }
    
    func moveFile(withFile name: String, inDirectory inPath: URL, toDirectory outPath: URL) -> Bool {
        
        let originPath = inPath.appendingPathComponent(name)
        let destinationPath = outPath.appendingPathComponent(name)
        do {
            try FileManager.default.moveItem(at: originPath, to: destinationPath)
            return true
        }
        catch {
            print(error)
        }
        return false
    }
    
    func copyFile(withFile name: String, inDirectory inPath: URL, toDirectory outPath: URL) -> Bool {
        let originPath = inPath.appendingPathComponent(name)
        let destinationPath = outPath.appendingPathComponent(name)
        do {
            try FileManager.default.copyItem(at: originPath, to: destinationPath)
            return true
        }
        catch {
            print(error)
        }
        return false
    }
    
    func renameFile(at filePath: URL, oldfile oldName: String, newfile newname: String) -> Bool {
        let oldFilePath = filePath.appendingPathComponent(oldName)
        let newFilePath = filePath.appendingPathComponent(newname)
        
        do {
            try FileManager.default.moveItem(at: oldFilePath, to: newFilePath)
            return true
        }
        catch {
            print(error)
        }
        return false
    }
    
    func changeExtension(withName: String, at path: URL, toExtension newExt: String) -> Bool{
        var newFileName = NSString(string: withName)
        newFileName =  newFileName.deletingPathExtension as NSString
        newFileName = newFileName.appendingPathExtension(newExt)! as NSString
        
        let oldFilePath = path.appendingPathComponent(withName)
        let newFilePath = path.appendingPathComponent(newFileName as String)
        
        do {
            try FileManager.default.moveItem(at: oldFilePath, to: newFilePath)
            return true
        }
        catch {
            print(error)
        }
        return false
    }
    
    func changeExtensionWithSwift(withName: String, at path: URL, toExtension newExt: String) -> Bool{
        
        let names = withName.split(separator: ".")
        let newName = names[0] + "." + newExt
        
        let oldFilePath = path.appendingPathComponent(withName)
        let newFilePath = path.appendingPathComponent(newName)
        
        do {
            try FileManager.default.moveItem(at: oldFilePath, to: newFilePath)
            return true
        }
        catch {
            print(error)
        }
        return false
    }
    
    
    func getAllFiles(at path: URL, foldername: String) -> [URL]
    {
        let filepath = path.appendingPathComponent(foldername)
        do {
            let directoryContents =   try FileManager.default.contentsOfDirectory(at: filepath, includingPropertiesForKeys: nil, options: [])
            var pdfList = directoryContents.filter {
                $0.pathExtension == "pdf"
            } as [URL]
            var txtList = directoryContents.filter {
                $0.pathExtension == "txt"
            } as [URL]
            var csvList = directoryContents.filter {
                $0.pathExtension == "csv"
            } as [URL]
            var pngList = directoryContents.filter {
                $0.pathExtension == "png"
            } as [URL]
            
            pdfList.append(contentsOf: txtList)
            pdfList.append(contentsOf: csvList)
            pdfList.append(contentsOf: pngList)
            
            return pdfList
        }
        catch {
            print(error)
        }
        
        return []
    }
    
}
