#if os(macOS) || os(iOS) || os(tvOS)
import Darwin
#elseif os(Linux)
import Glibc
#endif

import Foundation

fileprivate class Node {
  public var isEnd:       Bool = false
  public var children:    [Character: Node]

  public init (isEnd: Bool) {
    self.isEnd = isEnd
    self.children = [:]
  }
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

  public func insert (word: String) -> Void {
    var current: Node = self.root;

    for letter: Character in word {
      let next: Node? = current.children[letter]
      if (next == nil) {
        current.children[letter] = Node(isEnd: false)
      }

      current = current.children[letter]!
    }

    current.isEnd = true
  }

  public func wordExists (word: String) -> TWord {
    guard let node = prefixNode(prefix: word) else {
      return false
    }

    guard node.isEnd == true else {
      return false
    }

    return true
  }
}
