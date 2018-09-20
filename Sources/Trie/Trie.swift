#if os(macOS) || os(iOS) || os(tvOS)
import Darwin
#elseif os(Linux)
import Glibc
#endif

import Foundation

fileprivate class TNode<Key: Hashable> {
  public var parent: TNode?
  public var key:    Key?
  public var isEnd:  Bool = false

  public var children: [Key: TNode] = [:]

  public init (key: Key?, parent: TNode?) {
    self.key = key
    self.parent = parent
  }
}

public class Trie<CollectionType: Collection> where CollectionType.Element: Hashable {
  private typealias Node = TNode<CollectionType.Element>

  private let queue = DispatchQueue(label: "com.markakod.Trie", attributes: .concurrent)
  private let root  = Node(key: nil, parent: nil)

  public init () {}

  public func insert (collection: CollectionType) -> Void {
    queue.async(flags: .barrier) {
      var current = self.root;

      for elem in collection {
        if (current.children[elem] == nil) { current.children[elem] = Node(key: elem, parent: current) }
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

  public func contents (_ body: (CollectionType) -> Void) {
    queue.sync { [weak self] in
      self!.loop(from: self!.root, body: body)
    }
  }

  public func count () -> UInt {
    var all: UInt = 0
    queue.sync { [weak self] in
      self!.loopSimple(from: self!.root) { all += 1 }
    }
    return all
  }

  private func traverse (from: Node) -> CollectionType {
    var current: Node?                    = from
    var item:    [CollectionType.Element] = []

    while (current != nil) {
      if (current!.key == nil) { break }
      let key = current?.key
      item.append(key!)
      current = current!.parent
    }

    let reversed = item.reversed()
    return reversed as! CollectionType
  }

  private func loop (from: Node, body: (CollectionType) -> Void) {
    for (_, child) in from.children {
      if (child.isEnd) {
        body(traverse(from: child))
      }

      self.loop(from: child, body: body)
    }
  }

  private func loopSimple (from: Node, body: () -> Void) {
    for (_, child) in from.children {
      if (child.isEnd) { body() }

      self.loopSimple(from: child, body: body)
    }
  }

  private func prefixNode (prefix: CollectionType) -> Node? {
    var current: Node = self.root;

    for elem in prefix {
      if (current.children[elem] == nil) { return nil }
      current = current.children[elem]!
    }

    return current
  }

}
