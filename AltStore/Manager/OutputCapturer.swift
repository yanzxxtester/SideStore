//
//  OutputCapturer.swift
//  SideStore
//
//  Created by Fabian Thies on 12.02.23.
//  Copyright © 2023 SideStore. All rights reserved.
//

import Foundation
import LocalConsole

class OutputCapturer {
    
    public static let shared = OutputCapturer()

    private let consoleManager = LCManager.shared

    private var inputPipe = Pipe()
    private var errorPipe = Pipe()
    
    private init() {
        // Setup pipe file handlers
        self.inputPipe.fileHandleForReading.readabilityHandler = { [weak self] fileHandle in
            self?.handle(data: fileHandle.availableData)
        }
        self.errorPipe.fileHandleForReading.readabilityHandler = { [weak self] fileHandle in
            self?.handle(data: fileHandle.availableData, isError: true)
        }

        // Intercept STDOUT and STDERR
        dup2(self.inputPipe.fileHandleForWriting.fileDescriptor, STDOUT_FILENO)
        dup2(self.errorPipe.fileHandleForWriting.fileDescriptor, STDERR_FILENO)
    }

    deinit {
        try? self.inputPipe.fileHandleForReading.close()
        try? self.errorPipe.fileHandleForReading.close()
    }

    private func handle(data: Data, isError: Bool = false) {
        guard let string = String(data: data, encoding: .utf8) else {
            return
        }

        DispatchQueue.main.async {
            self.consoleManager.print(string)
        }
    }
}
