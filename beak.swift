// beak: kareman/SwiftShell @ 5.0.0
// beak: sharplet/Regex @ 2.0.0
// beak: kylef/PathKit @ 1.0.0

// include: beak2.swift

import Foundation
import SwiftShell
import Regex
import PathKit

let tool = "beak"
let repo = "https://github.com/yonaskolb/Beak"

/// Formats all the code in the project
public func formatCode() throws {
    let formatOptions = "--wraparguments beforefirst --stripunusedargs closure-only --header strip --disable sortedImports,blankLinesAtEndOfScope,blankLinesAtStartOfScope"
    try runAndPrint(bash: "swiftformat Sources \(formatOptions)")
    try runAndPrint(bash: "swiftformat Tests \(formatOptions)")
}

/// Installs beak
///
/// - Parameters:
///   - directory: The directory to install beak
public func install(directory: String = "/usr/local/bin") throws {
    print("🐦  Building Beak...")
    let output = run(bash: "swift build --disable-sandbox -c release")
    if let error = output.error {
        print("Couldn't build:\n\(error)")
        return
    }
    try runAndPrint(bash: "cp -R .build/release/\(tool) \(directory)/\(tool)")
    print("🐦  Installed Beak!")
}

/// Updates homebrew formula to a certain version
///
/// - Parameters:
///   - version: The version to release
public func updateBrew(_ version: String) throws {
  let releaseTar = "\(repo)/archive/\(version).tar.gz"
  let output = run(bash: "curl -L -s \(releaseTar) | shasum -a 256 | sed 's/ .*//'")
  guard output.succeeded else {
    print("Error retrieving brew SHA")
    return
  }
  let sha = output.stdout

  try replaceFile(
      regex: "(url \".*/archive/)(.*).tar.gz",
      replacement: "$1\(version).tar.gz",
      path: "Formula/beak.rb")

  try replaceFile(
      regex: "sha256 \".*\"",
      replacement: "sha256 \"\(sha)\"",
      path: "Formula/beak.rb")

  run(bash: "git add Formula/beak.rb")
  run(bash: "git commit -m \"Updated brew to \(version)\"")
}

/// Releases a new version of Beak
///
/// - Parameters:
///   - version: The version to release
public func release(_ version: String) throws {

    try replaceFile(
        regex: "public let version: String = \".*\"",
        replacement: "public let version: String = \"\(version)\"",
        path: "Sources/BeakCLI/BeakCLI.swift")

    run(bash: "git add Sources/BeakCLI/BeakCLI.swift")
    run(bash: "git commit -m \"Updated to \(version)\"")
    run(bash: "git tag \(version)")

    print("🐦  Released version \(version)!")
}

func replaceFile(regex: String, replacement: String, path: Path) throws {
    let regex = try Regex(string: regex)
    let contents: String = try path.read()
    let replaced = contents.replacingFirst(matching: regex, with: replacement)
    try path.write(replaced)
}

func runMint(package: String, command: String?) {

}
