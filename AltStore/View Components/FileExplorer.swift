//
//  FileExplorer.swift
//  SideStore
//
//  Created by naturecodevoid on 2/16/23.
//  Copyright © 2023 SideStore. All rights reserved.
//

import SwiftUI
import ZIPFoundation
import UniformTypeIdentifiers

// https://stackoverflow.com/a/72165424
func allUTITypes() -> [UTType] {
    let types: [UTType] =
        [.item,
         .content,
         .compositeContent,
         .diskImage,
         .data,
         .directory,
         .resolvable,
         .symbolicLink,
         .executable,
         .mountPoint,
         .aliasFile,
         .urlBookmarkData,
         .url,
         .fileURL,
         .text,
         .plainText,
         .utf8PlainText,
         .utf16ExternalPlainText,
         .utf16PlainText,
         .delimitedText,
         .commaSeparatedText,
         .tabSeparatedText,
         .utf8TabSeparatedText,
         .rtf,
         .html,
         .xml,
         .yaml,
         .sourceCode,
         .assemblyLanguageSource,
         .cSource,
         .objectiveCSource,
         .swiftSource,
         .cPlusPlusSource,
         .objectiveCPlusPlusSource,
         .cHeader,
         .cPlusPlusHeader]

    let types_1: [UTType] =
        [.script,
         .appleScript,
         .osaScript,
         .osaScriptBundle,
         .javaScript,
         .shellScript,
         .perlScript,
         .pythonScript,
         .rubyScript,
         .phpScript,
         .json,
         .propertyList,
         .xmlPropertyList,
         .binaryPropertyList,
         .pdf,
         .rtfd,
         .flatRTFD,
         .webArchive,
         .image,
         .jpeg,
         .tiff,
         .gif,
         .png,
         .icns,
         .bmp,
         .ico,
         .rawImage,
         .svg,
         .livePhoto,
         .heif,
         .heic,
         .webP,
         .threeDContent,
         .usd,
         .usdz,
         .realityFile,
         .sceneKitScene,
         .arReferenceObject,
         .audiovisualContent]

    let types_2: [UTType] =
        [.movie,
         .video,
         .audio,
         .quickTimeMovie,
         UTType("com.apple.quicktime-image"),
         .mpeg,
         .mpeg2Video,
         .mpeg2TransportStream,
         .mp3,
         .mpeg4Movie,
         .mpeg4Audio,
         .appleProtectedMPEG4Audio,
         .appleProtectedMPEG4Video,
         .avi,
         .aiff,
         .wav,
         .midi,
         .playlist,
         .m3uPlaylist,
         .folder,
         .volume,
         .package,
         .bundle,
         .pluginBundle,
         .spotlightImporter,
         .quickLookGenerator,
         .xpcService,
         .framework,
         .application,
         .applicationBundle,
         .applicationExtension,
         .unixExecutable,
         .exe,
         .systemPreferencesPane,
         .archive,
         .gzip,
         .bz2,
         .zip,
         .appleArchive,
         .spreadsheet,
         .presentation,
         .database,
         .message,
         .contact,
         .vCard,
         .toDoItem,
         .calendarEvent,
         .emailMessage,
         .internetLocation,
         .internetShortcut,
         .font,
         .bookmark,
         .pkcs12,
         .x509Certificate,
         .epub,
         .log]
            .compactMap({ $0 })

    return types + types_1 + types_2
}

extension Binding<URL?>: Equatable {
    public static func == (lhs: Binding<URL?>, rhs: Binding<URL?>) -> Bool {
        return lhs.wrappedValue == rhs.wrappedValue
    }
}

private struct DirectoryEntry: Identifiable {
    var id = UUID()
    var path: URL
    var parent: URL
    var isFile = false
    var childFiles = [URL]()
    var childDirectories: [DirectoryEntry]?
    var filesAndDirectories: [DirectoryEntry]? {
        if childFiles.count <= 0 { return childDirectories }
        
        var filesAndDirectories = childDirectories ?? []
        for file in childFiles {
            filesAndDirectories.insert(DirectoryEntry(path: file, parent: path, isFile: true), at: 0)
        }
        
        return filesAndDirectories.sorted(by: { $0.asString < $1.asString })
    }
    var asString: String {
        let str = path.description.replacingOccurrences(of: parent.description, with: "").removingPercentEncoding!
        if str.count <= 0 {
            return "/"
        }
        return str
    }
}

private enum FileExplorerAction {
    case delete
    case zip
    case insert
}

private struct File: View {
    @ObservedObject private var iO = Inject.observer
    
    var item: DirectoryEntry
    @Binding var explorerHidden: Bool
    
    @State var quickLookURL: URL?
    @State var fileExplorerAction: FileExplorerAction?
    @State var hidden = false
    @State var isShowingFilePicker = false
    @State var selectedFile: URL?
    
    var body: some View {
        AsyncFallibleButton(action: {
            switch (fileExplorerAction) {
            case .delete:
                print("deleting \(item.path.description)")
                try FileManager.default.removeItem(at: item.path)
                
            case .zip:
                print("zipping \(item.path.description)")
                let dest = FileManager.default.documentsDirectory.appendingPathComponent(item.path.pathComponents.last! + ".zip")
                do {
                    try FileManager.default.removeItem(at: dest)
                } catch {}

                try FileManager.default.zipItem(at: item.path, to: dest)
                
            case .insert:
                print("inserting \(selectedFile!.description) to \(item.path.description)")

                try FileManager.default.copyItem(at: selectedFile!, to: item.path.appendingPathComponent(selectedFile!.pathComponents.last!), shouldReplace: true)
                explorerHidden = true
                explorerHidden = false
                
            default:
                print("unknown action for \(item.path.description): \(String(describing: fileExplorerAction))")
            }
        }, label: { execute in
            HStack {
                Text(item.asString)
                if item.isFile {
                    Text(getFileSize(file: item.path)).foregroundColor(.secondary)
                }
                Spacer()
                Menu {
                    if item.isFile {
                        SwiftUI.Button(action: { quickLookURL = item.path }) {
                            Label("View/Share", systemSymbol: .eye)
                        }
                    } else {
                        SwiftUI.Button(action: {
                            fileExplorerAction = .zip
                            execute()
                        }) {
                            Label("Save to ZIP file", systemSymbol: .squareAndArrowDown)
                        }
                        
                        SwiftUI.Button {
                            isShowingFilePicker = true
                        } label: {
                            Label("Insert file", systemSymbol: .plus)
                        }
                    }
                    
                    if item.asString != "/" {
                        SwiftUI.Button(action: {
                            fileExplorerAction = .delete
                            execute()
                        }) {
                            Label("Delete", systemSymbol: .trash)
                        }
                    }
                } label: {
                    Image(systemSymbol: .ellipsis)
                        .frame(width: 20, height: 20) // Make it easier to tap
                }
            }
            .onChange(of: $selectedFile) { file in
                guard file.wrappedValue != nil else { return }
                
                fileExplorerAction = .insert
                execute()
            }
        }, afterFinish: { success in
            switch (fileExplorerAction) {
            case .delete:
                if success { hidden = true }
                
            case .zip:
                UIApplication.shared.open(URL(string: "shareddocuments://" + FileManager.default.documentsDirectory.description.replacingOccurrences(of: "file://", with: ""))!, options: [:], completionHandler: nil)
                
            default: break
            }
        }, wrapInButton: false)
        .quickLookPreview($quickLookURL)
        .sheet(isPresented: $isShowingFilePicker) {
            DocumentPicker(selectedUrl: $selectedFile, supportedTypes: allUTITypes().map({ $0.identifier }))
                .ignoresSafeArea()
        }
        .isHidden($hidden)
        .enableInjection()
    }
    
    func getFileSize(file: URL) -> String {
        guard let attributes = try? FileManager.default.attributesOfItem(atPath: file.description.replacingOccurrences(of: "file://", with: "")) else { return "Unknown file size" }
        var bytes = attributes[FileAttributeKey.size] as! Double
        
        // https://stackoverflow.com/a/14919494 (ported to swift)
        let thresh = 1024.0;

        if (bytes < thresh) {
            return String(describing: bytes) + " B";
        }

        let units = ["kB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
        var u = -1;

        while (bytes >= thresh && u < units.count - 1) {
            bytes /= thresh;
            u += 1;
        }

        return String(format: "%.2f", bytes) + " " + units[u];
    }
}

struct FileExplorer: View {
    @ObservedObject private var iO = Inject.observer
    
    var url: URL?
    
    @State var hidden = false
    
    var body: some View {
        List([iterateOverDirectory(directory: url!, parent: url!)], children: \.filesAndDirectories) { item in
            File(item: item, explorerHidden: $hidden)
        }
        .toolbar {
            ToolbarItem {
                SwiftUI.Button {
                    hidden = true
                    hidden = false
                } label: {
                    Image(systemSymbol: .arrowClockwise)
                }
            }
        }
        .isHidden($hidden)
        .enableInjection()
    }
    
    private func iterateOverDirectory(directory: URL, parent: URL) -> DirectoryEntry {
        var directoryEntry = DirectoryEntry(path: directory, parent: parent)
        if let contents = try? FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil, options: []) {
            for entry in contents {
                if entry.hasDirectoryPath {
                    if directoryEntry.childDirectories == nil { directoryEntry.childDirectories = [] }
                    directoryEntry.childDirectories!.append(iterateOverDirectory(directory: entry, parent: directory))
                } else {
                    directoryEntry.childFiles.append(entry)
                }
            }
        }
        return directoryEntry
    }
}

struct FileExplorer_Previews: PreviewProvider {
    static var previews: some View {
        FileExplorer(url: FileManager.default.altstoreSharedDirectory)
    }
}
