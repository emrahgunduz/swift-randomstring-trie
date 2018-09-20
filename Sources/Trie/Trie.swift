#if os(macOS) || os(iOS) || os(tvOS)
import Darwin
#elseif os(Linux)
import Glibc
#endif

import Foundation

fileprivate class Node {
  public var isEnd:    Bool = false
  public var children: [Character: Node]

  public var parent:    Node?
  public var character: Character?

  public init (isEnd: Bool, parent: Node? = nil, character: Character? = nil) {
    self.isEnd = isEnd
    self.children = [:]
    self.parent = parent
    self.character = character
  }
}

public class Trie {
  private let queue = DispatchQueue(label: "com.markakod.Trie", attributes: .concurrent)
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

  private func traverse (from: Node) -> String? {
    var current = from
    guard var element = String(from.character!) else {
      return nil
    }

    while (current.parent != nil) {
      element += current.character
      var parent = current.parent
    }

    return ""
  }

  private func findEnd (from: Node) -> Node? {
    for (_, child) in from.children {
      if (child.isEnd) {
        return child
      } else {
        return self.findEnd(from: child)
      }
    }

    return nil
  }

  public func insert (element: String) -> Void {
    queue.async(flags: .barrier) {
      var current: Node = self.root;

      for letter: Character in element {
        let next: Node? = current.children[letter]
        if (next == nil) {
          current.children[letter] = Node(isEnd: false, parent: current, character: letter)
        }

        current = current.children[letter]!
      }

      current.isEnd = true
    }
  }

  public func exists (element: String) -> Bool {
    var exists = false
    queue.sync {
      guard let node = prefixNode(prefix: element) else {
        return
      }

      guard node.isEnd == true else {
        return
      }

      exists = true
    }
    return exists
  }

  public func exists (element: String, _ body: (Bool) -> Void) -> Void {
    queue.sync {
      guard let node = prefixNode(prefix: element) else {
        body(false)
        return
      }

      guard node.isEnd == true else {
        body(false)
        return
      }

      body(true)
    }
  }

  public func contents (_ body: (String) -> Void) {
    queue.sync {
      let current: Node = self.root;

      for (_, child) in current.children {
        if (child.isEnd) {
          body(self.traverse(from: child))
          return
        }

        guard let onEnd = self.findEnd(from: child) else {
          return
        }

        body(self.traverse(from: onEnd))
      }
    }
  }
}
