#if os(macOS) || os(iOS) || os(tvOS)
import Darwin
#elseif os(Linux)
import Glibc
#endif

import Foundation

fileprivate class Node {
  public var isEnd:       Bool = false
  public var children:    [Character: Node]
  public var description: String?

  public init (isEnd: Bool) {
    self.isEnd = isEnd
    self.children = [:]
  }
}

public struct TWord {
  public var exists:      Bool
  public var word:        String
  public var description: String
}

public class Trie {
  private let root: Node

  public init () {
    self.root = Node(isEnd: false)
  }

  private func prefixNode (prefix: String) -> Node? {
    var current: Node = self.root;

    for letter: Character in prefix {
      let next: Node? = current.children[letter]
      if (next == nil) {
        return nil
      }
      current = next!
    }

    return current
  }

  public func insert (word: String, description: String) -> Void {
    var current: Node = self.root;

    for letter: Character in word {
      let next: Node? = current.children[letter]
      if (next == nil) {
        current.children[letter] = Node(isEnd: false)
      }

      current = current.children[letter]!
    }

    current.isEnd = true
    current.description = description
  }

  public func wordExists (word: String) -> TWord {
    guard let node = prefixNode(prefix: word) else {
      return TWord(exists: false, word: word, description: "")
    }

    guard node.isEnd == true else {
      return TWord(exists: false, word: word, description: "")
    }

    return TWord(exists: true, word: word, description: node.description ?? "")
  }

  public func wordWithPrefixExists (prefix: String) -> Bool {
    let node: Node? = prefixNode(prefix: prefix)
    return (node != nil)
  }
}
