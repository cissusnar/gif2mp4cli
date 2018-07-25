//
//  main.swift
//  gif2mp4
//
//  Created by cissu on 2018/7/6.
//  Copyright © 2018年 cissu. All rights reserved.
//

import Foundation
import Darwin

var inputFlag = false
var outputFlag = false

var inputString : String?
var outputString : String?


while case let option = getopt(CommandLine.argc, CommandLine.unsafeArgv, "i:o:"), option != -1 {
    switch UnicodeScalar(CUnsignedChar(option)) {
    case "i":
        inputFlag = true
        inputString = String(cString: optarg)
    case "o":
        outputFlag = true
        outputString = String(cString: optarg)
    default:
        print("""
unknow args.
usage:
    -i ~/input.gif
    -o ~/output.mp4
""")
    }
}

let converter : GIFConverter = GIFConverter()
if (inputFlag) {
    let inputFilePath : String! = (inputString! as NSString).expandingTildeInPath
    var outputFilePath : String = ("~/output.mp4" as NSString).expandingTildeInPath
    if outputFlag && outputString != nil {
        if let outputExpantFilePath : String = (outputString! as NSString).expandingTildeInPath {
            outputFilePath = outputExpantFilePath
        }
    }
    
    if FileManager.default.fileExists(atPath: inputFilePath) {
        let fileURL : URL = URL(fileURLWithPath: inputFilePath)
        if let data = try? Data(contentsOf: fileURL) {
            converter.convertGIF(toMP4: data, speed: 0, size: NSZeroSize, repeat: 0, output: outputFilePath, progress: {
                (progress : Progress?) -> Void in
                let string : String = String(format: "complete: %i%%\r", Int(Float(progress!.completedUnitCount)/Float(progress!.totalUnitCount) * 100))
                let stdout = FileHandle.standardOutput
                stdout.write(string.data(using: String.Encoding.utf8)!)
                fflush(__stdoutp)
            }, completion: {
                (error : Error?) -> Void in
                exit(0)
            })
        }
    }
    else {
        print("file not existed!")
        exit(0)
    }
}
else {
    print("need input GIF file!")
    exit(0)
}

RunLoop.current.run()
