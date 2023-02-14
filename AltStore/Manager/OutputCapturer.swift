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

    private var stdoutPipe = Pipe()
    private var stderrPipe = Pipe()
    private var outputPipe = Pipe()
    
    private init() {
        // Setup pipe file handlers
        self.stdoutPipe.fileHandleForReading.readabilityHandler = { [weak self] fileHandle in
            self?.handle(data: fileHandle.availableData)
        }
        self.stderrPipe.fileHandleForReading.readabilityHandler = { [weak self] fileHandle in
            self?.handle(data: fileHandle.availableData, isError: true)
        }
        
        // Keep output in STDOUT without causing infinite loop
        dup2(STDOUT_FILENO, self.outputPipe.fileHandleForWriting.fileDescriptor)

        // Intercept STDOUT and STDERR
        dup2(self.stdoutPipe.fileHandleForWriting.fileDescriptor, STDOUT_FILENO)
        dup2(self.stderrPipe.fileHandleForWriting.fileDescriptor, STDERR_FILENO)
    }

    deinit {
        try? self.stdoutPipe.fileHandleForReading.close()
        try? self.stderrPipe.fileHandleForReading.close()
    }

    private func handle(data: Data, isError: Bool = false) {
        guard let string = String(data: data, encoding: .utf8) else {
            return
        }

        DispatchQueue.main.async {
            self.consoleManager.print(string)
            // put data back into STDOUT so it appears in Xcode/idevicedebug run
            self.outputPipe.fileHandleForWriting.write(data) // this might not need to be async
        }
    }
}
