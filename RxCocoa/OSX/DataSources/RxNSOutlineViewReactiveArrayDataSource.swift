//
//  RxNSOutlineViewReactiveArrayDataSource.swift
//  RxCocoa
//
//  Created by Rheese Burgess on 17/12/2015.
//

import Foundation
#if !RX_NO_MODULE
import RxSwift
#endif
import Cocoa

// objc monkey business
class _RxNSOutlineViewReactiveArrayDataSource: NSObject, NSOutlineViewDataSource {
    func _outlineView(outlineView: NSOutlineView, child index: Int, ofItem item: AnyObject?) -> AnyObject {
        rxAbstractMethod()
    }

    func outlineView(outlineView: NSOutlineView, child index: Int, ofItem item: AnyObject?) -> AnyObject {
        return _outlineView(outlineView, child: index, ofItem: item)
    }

    func outlineView(outlineView: NSOutlineView, isItemExpandable item: AnyObject) -> Bool {
        return self.outlineView(outlineView, numberOfChildrenOfItem: item) > 0
    }

    func _outlineView(outlineView: NSOutlineView, numberOfChildrenOfItem item: AnyObject?) -> Int {
        return 0
    }

    func outlineView(outlineView: NSOutlineView, numberOfChildrenOfItem item: AnyObject?) -> Int {
        return _outlineView(outlineView, numberOfChildrenOfItem: item)
    }

    func _outlineView(outlineView: NSOutlineView, objectValueForTableColumn tableColumn: NSTableColumn?, byItem item: AnyObject?) -> AnyObject? {
        return nil
    }

    func outlineView(outlineView: NSOutlineView, objectValueForTableColumn tableColumn: NSTableColumn?, byItem item: AnyObject?) -> AnyObject? {
        return _outlineView(outlineView, objectValueForTableColumn: tableColumn, byItem: item)
    }
}

class RxNSOutlineViewReactiveArrayDataSourceSequenceWrapper<S: SequenceType where S.Generator.Element : NSObject>
    : RxNSOutlineViewReactiveArrayDataSource<S.Generator.Element>, RxNSOutlineViewDataSourceType {

    typealias Element = S

    override init(childrenFactory: ChildrenFactory) {
        super.init(childrenFactory: childrenFactory)
    }

    func outlineView(outlineView: NSOutlineView, observedEvent: Event<S>) {
        switch observedEvent {
        case .Next(let value):
            super.outlineView(outlineView, observedElements: Array(value))
        case .Error(let error):
            bindingErrorToInterface(error)
        case .Completed:
            break
        }
    }
}

class Node<E> {
    var value: E?
    var children: [Node]

    init(value: E? = nil) {
        self.value = value
        self.children = []
    }
}

// Please take a look at `DelegateProxyType.swift`
class RxNSOutlineViewReactiveArrayDataSource<Element: NSObject> : _RxNSOutlineViewReactiveArrayDataSource {
    typealias ChildrenFactory = (Element) -> [Element]

    var root: Node<Element> = Node()

    let childrenFactory: ChildrenFactory

    init(childrenFactory: ChildrenFactory) {
        self.childrenFactory = childrenFactory
    }

    override func _outlineView(outlineView: NSOutlineView, child index: Int, ofItem item: AnyObject?) -> AnyObject {
        if (item == nil) {
            return root.children[index].value!
        } else {
            return childrenFactory(item as! Element)[index]
        }
    }

    override func _outlineView(outlineView: NSOutlineView, numberOfChildrenOfItem item: AnyObject?) -> Int {
        if (item == nil) {
            return root.children.count
        } else {
            return childrenFactory(item as! Element).count
        }
    }

    override func _outlineView(outlineView: NSOutlineView, objectValueForTableColumn tableColumn: NSTableColumn?, byItem item: AnyObject?) -> AnyObject? {
        return item
    }

    // reactive

    private func replace(old: Element, with new: Element, inOutline outline: NSOutlineView) -> Int? {
        outline.reloadItem(old) // by itself not enough - by design (!) http://stackoverflow.com/questions/19963031/nsoutlineview-reloaditem-has-no-effect
        let index = outline.rowForItem(new)
        return index >= 0 ? index : nil
    }

    private func update(node: Node<Element>, withValue value: Element, inOutline outline: NSOutlineView) -> [Int?] {
        let old = node.value
        node.value = value
        let replacedIndex = replace(old!, with: value, inOutline: outline)
        return [replacedIndex] + update(node, withChildren: childrenFactory(value), inOutline: outline)
    }

    private func update(node: Node<Element>, withChildren children: [Element], inOutline outline: NSOutlineView) -> [Int?] {
        return children.enumerate().map { (index, childValue) -> [Int?] in
            let childNode: Node<Element>
            if index == node.children.count {
                childNode = Node(value: childValue)
                node.children.append(childNode)
            } else {
                childNode = node.children[index]
            }

            return update(childNode, withValue: childValue, inOutline: outline)
        }.reduce([]){ $0 + $1 }
    }

    func outlineView(outlineView: NSOutlineView, observedElements: [Element]) {
        let indices = update(root, withChildren: observedElements, inOutline: outlineView).flatMap { $0 }

        for element in observedElements {
            // Seriously... (O_O)
            outlineView.reloadItem(element, reloadChildren: true)
        }

        if indices.count > 0 {
            let range = NSRange(location: indices[0], length: indices[indices.count - 1] - indices[0] + 1)
            outlineView.reloadDataForRowIndexes(NSIndexSet(indexesInRange: range), columnIndexes: NSIndexSet(index: 0))
        } else {
            outlineView.reloadData()
        }
    }
}