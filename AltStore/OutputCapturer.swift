//
//  OutputCapturer.swift
//  SideStore
//
//  Created by Fabian Thies on 12.02.23.
//  Copyright © 2023 SideStore. All rights reserved.
//

import Foundation
import AltStoreCore
//import LocalConsole

class OutputCapturer {
    public static let shared = OutputCapturer()

    //private let consoleManager = LCManager.shared

    private var inputPipe = Pipe()
    private var errorPipe = Pipe()
    private var outputPipe = Pipe()
    
    public static var logPath: URL {
        return FileManager.default.documentsDirectory.appendingPathComponent("sidestore.log")
    }
    
    /// if a message contains a string in this array it will not be printed
    private static let ignore = [
        " internal_ssl_write(): ",
        " internal_ssl_read(): ",
        " idevice_connection_receive_timeout(): ",
        " internal_plist_receive_timeout(): ",
        "pre-send length = ",
        "pre-send length = ",
        "post-send sent ",
        "service_send(): sending "
    ]
    
    /// any occurences of the strings in this array are replaced with `[removed]`
    private static var remove = [String]()
    
    public static func addRemoves() {
        let maybeRemove = [
            Keychain.shared.appleIDEmailAddress,
            Keychain.shared.appleIDPassword,
            Keychain.shared.signingCertificateSerialNumber,
            Keychain.shared.signingCertificatePassword,
        ]
        
        for item in maybeRemove {
            if item != nil && !item!.isEmpty && !remove.contains(item!) { OutputCapturer.remove.append(item!) }
        }
    }

    private init() {
        OutputCapturer.addRemoves()
        
        // Setup pipe file handlers
        self.inputPipe.fileHandleForReading.readabilityHandler = { [weak self] fileHandle in
            self?.handle(data: fileHandle.availableData)
        }
        self.errorPipe.fileHandleForReading.readabilityHandler = { [weak self] fileHandle in
            self?.handle(data: fileHandle.availableData, isError: true)
        }
        
        // Keep STDOUT
        dup2(STDOUT_FILENO, self.outputPipe.fileHandleForWriting.fileDescriptor)

        // Intercept STDOUT and STDERR
        dup2(self.inputPipe.fileHandleForWriting.fileDescriptor, STDOUT_FILENO)
        dup2(self.errorPipe.fileHandleForWriting.fileDescriptor, STDERR_FILENO)
    }

    deinit {
        try? self.inputPipe.fileHandleForReading.close()
        try? self.errorPipe.fileHandleForReading.close()
    }

    private func handle(data: Data, isError: Bool = false) {
        guard var string = String(data: data, encoding: .utf8) else {
            return
        }
        
        for item in OutputCapturer.ignore {
            if string.contains(item) { return }
        }
        
        for item in OutputCapturer.remove {
            string = string.replacingOccurrences(of: item, with: "[removed]")
        }
        
        // Write output to STDOUT
        self.outputPipe.fileHandleForWriting.write(data)

        DispatchQueue.main.async {
            //self.consoleManager.print(string)
            if let fileHandle = try? FileHandle(forWritingTo: OutputCapturer.logPath) {
                defer {
                    fileHandle.closeFile()
                }
                fileHandle.seekToEndOfFile()
                fileHandle.write(string.data(using: .utf8)!)
            }
            else {
                try? string.data(using: .utf8)!.write(to: OutputCapturer.logPath, options: .atomic)
            }
        }
    }
}
