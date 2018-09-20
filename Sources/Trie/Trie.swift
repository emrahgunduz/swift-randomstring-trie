#if os(macOS) || os(iOS) || os(tvOS)
import Darwin
#elseif os(Linux)
import Glibc
#endif

import Foundation

fileprivate class Node<Key: Hashable> {
  public var parent: Node?
  public var key:    Key?
  public var isEnd:  Bool = false

  public var children: [Key: Node] = [:]

  public init (key: Key?, parent: Node?) {
    self.key = key
    self.parent = parent
    self.children = children
  }
}

public class Trie {
  private let queue      = DispatchQueue(label: "com.markakod.Trie", attributes: .concurrent)
  private let root: Node = Node(key: nil, parent: nil)

  public init () {}

  public func insert (collection: CollectionType) -> Void {
    queue.async(flags: .barrier) {
      var current = self.root;

      for elem in collection {
        if (current.children[elem] == nil) { current.children[elem] = Node(parent: current, key: elem) }
        current = current.children[elem]!
      }

      current.isEnd = true
    }
  }

  public func exists (collection: CollectionType) -> Bool {
    var exists = false
    queue.sync {
      guard let node = prefixNode(prefix: collection) else {
        return
      }

      guard node.isEnd == true else {
        return
      }

      exists = true
    }
    return exists
  }

  public func exists (collection: CollectionType, _ body: (Bool) -> Void) -> Void {
    queue.sync {
      guard let node = prefixNode(prefix: collection) else {
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
    queue.sync { [weak self] in
      loop(from: self!.root, body: body)
    }
  }

  public func count () -> UInt {
    var all: UInt = 0
    queue.sync { [weak self] in
      self!.loopSimple(from: self!.root) { all += 1 }
    }
    return all
  }

}

fileprivate extension Trie {
  fileprivate func traverse (from: Node) -> [Key] {
    var current: Node? = from
    var item:    [Key] = []

    while (current != nil) {
      if (current!.key == nil) { break }
      item.append(current?.key)
      current = current!.parent
    }

    let reversed = item.reversed()
    return reversed
  }

  fileprivate func loop (from: Node, body: (String) -> Void) {
    for (_, child) in from.children {
      if (child.isEnd) {
        body(self.traverse(from: child))
      }

      self.loop(from: child, body: body)
    }
  }

  fileprivate func loopSimple (from: Node, body: () -> Void) {
    for (_, child) in from.children {
      if (child.isEnd) { body() }

      self.loopSimple(from: child, body: body)
    }
  }

  fileprivate func prefixNode (prefix: CollectionType) -> Node? {
    var current: Node = self.root;

    for elem in prefix {
      if (current.children[elem] == nil) { return nil }
      current = current.children[elem]!
    }

    return current
  }

}
