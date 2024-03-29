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

  private func traverse (from: Node) -> String {
    var current: Node?  = from
    var item:    String = ""

    while (current != nil) {
      if (current!.character == nil) { break }
      item = item + String(current!.character!)
      current = current!.parent
    }

    let reversed = item.reversed() as [Character]

    return reversed.map { String(describing: $0) }.joined()
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

  private func loop (from: Node, body: (String) -> Void) {
    for (_, child) in from.children {
      if (child.isEnd) {
        body(self.traverse(from: child))
      }

      self.loop(from: child, body: body)
    }
  }

  public func contents (_ body: (String) -> Void) {
    queue.sync { [weak self] in
      loop(from: self!.root, body: body)
    }
  }

  private func loopSimple (from: Node, body: () -> Void) {
    for (_, child) in from.children {
      if (child.isEnd) {
        body()
      }

      self.loopSimple(from: child, body: body)
    }
  }

  public func count () -> UInt {
    var all: UInt = 0
    queue.sync { [weak self] in
      self!.loopSimple(from: self!.root) {
        all += 1
      }
    }
    return all
  }
}
