// This command trims a list of videos with ffmpeg and concatenate them into
// a single final video.
//
// It takes 2 forms of input. The path for the final output video is taken as
// the only command line argument. After launch, the command reads lines from
// stdin until EOF. Each line of these input should be an absolute path to
// a video file, and optionally, a start and end timestamp in the format of
// hh:mm:ss. All 3 fields are separated by commas. Here's an example input:
/*

/absolute/path/to/video,00:05:00,00:30:00
/absolute/path/to/another_video

*/

// Say, that input is in a file "input.txt", then this command can be used as
//     cat input.txt | trimcat output.mov
// Then output.mov will be a video with content of "video" from beginning of the
// 5th minute to the 30th minute, followed by the content of "another_video"
// with its entirety

import Foundation

@discardableResult
func bash(_ command: String) -> Int32 {
    let task = Process()
    task.launchPath = "/bin/bash"
    task.arguments = ["-c", command]
    task.launch()
    task.waitUntilExit()
    return task.terminationStatus
}

var inputs = [(String, String?, String?)]()
while case let line? = readLine(strippingNewline: true) {
    let segments = line.split(separator: ",").map(String.init)
    if segments.count == 3 {
        inputs.append((segments[0], segments[1], segments[2]))
    } else {
        inputs.append((line, nil, nil))
    }
}

let workPath = NSTemporaryDirectory() + "\(arc4random())/"
try FileManager.default.createDirectory(atPath: workPath, withIntermediateDirectories: true)

var videoForConcat = [String]()

for input in inputs {
    let fileName = NSString(string: input.0).lastPathComponent
    switch input {
    case let (path, .some(start), .some(end)):
        videoForConcat.append(workPath + fileName)
        let trimPath = workPath + fileName
        bash("ffmpeg -i \(path) -ss \(start) -to \(end) -r 30 \(trimPath)")
    default:
        videoForConcat.append(input.0)
    }
}

print(videoForConcat)

let concatTemplate = "file '%@'"

let concatList = videoForConcat
    .map { String(format: concatTemplate, $0) }
    .joined(separator: "\n")

print(concatList)

let concatListFilePath = workPath + "concat_list.txt"

print(concatListFilePath)
try concatList.write(toFile: concatListFilePath, atomically: true, encoding: .utf8)
bash("ffmpeg -y -f concat -safe 0 -i \(concatListFilePath) -r 30 \(CommandLine.arguments[1])")

print("Temporary files are in \(workPath)")
