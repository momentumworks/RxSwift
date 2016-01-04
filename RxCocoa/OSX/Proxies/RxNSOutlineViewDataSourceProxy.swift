//
//  RxNSOutlineViewDataSourceProxy.swift
//  RxCocoa
//
//  Created by Rheese Burgess on 16/12/2015.
//

import Foundation
#if !RX_NO_MODULE
import RxSwift
#endif
import Cocoa

let outlineViewDataSourceNotSet = OutlineViewDataSourceNotSet()

class OutlineViewDataSourceNotSet
        : NSObject
                , NSOutlineViewDataSource {

    func outlineView(outlineView: NSOutlineView, child index: Int, ofItem item: AnyObject?) -> AnyObject {
        rxAbstractMethodWithMessage(dataSourceNotSet)
    }

    func outlineView(outlineView: NSOutlineView, isItemExpandable item: AnyObject) -> Bool {
        rxAbstractMethodWithMessage(dataSourceNotSet)
    }

    func outlineView(outlineView: NSOutlineView, numberOfChildrenOfItem item: AnyObject?) -> Int {
        // For some reason this function is called when initially setting the datasource on the NSOutlineView, so we need to return a default value
        return 0
    }

    func outlineView(outlineView: NSOutlineView, objectValueForTableColumn tableColumn: NSTableColumn?, byItem item: AnyObject?) -> AnyObject? {
        rxAbstractMethodWithMessage(dataSourceNotSet)
    }
}

public class RxNSOutlineViewDataSourceProxy
        : DelegateProxy
                , NSOutlineViewDataSource
                , DelegateProxyType {

    /**
     Typed parent object.
     */
    public weak private(set) var outlineView: NSOutlineView?

    private weak var _requiredMethodsDataSource: NSOutlineViewDataSource? = outlineViewDataSourceNotSet

    /**
     Initializes `RxOutlineViewDataSourceProxy`

     - parameter parentObject: Parent object for delegate proxy.
     */
    public required init(parentObject: AnyObject) {
        self.outlineView = (parentObject as! NSOutlineView)
        super.init(parentObject: parentObject)
    }

    // MARK: Delegate

    /**
    Required delegate method implementation.
    */
    public func outlineView(outlineView: NSOutlineView, child index: Int, ofItem item: AnyObject?) -> AnyObject {
        return ((_requiredMethodsDataSource ?? outlineViewDataSourceNotSet).outlineView?(outlineView, child: index, ofItem: item))!
    }

    /**
     Required delegate method implementation.
     */
    public func outlineView(outlineView: NSOutlineView, isItemExpandable item: AnyObject) -> Bool {
        return (_requiredMethodsDataSource ?? outlineViewDataSourceNotSet).outlineView?(outlineView, isItemExpandable: item) ?? false
    }

    /**
     Required delegate method implementation.
     */
    public func outlineView(outlineView: NSOutlineView, numberOfChildrenOfItem item: AnyObject?) -> Int {
        return (_requiredMethodsDataSource ?? outlineViewDataSourceNotSet).outlineView?(outlineView, numberOfChildrenOfItem: item) ?? 0
    }

    /**
     Required delegate method implementation.
     */
    public func outlineView(outlineView: NSOutlineView, objectValueForTableColumn tableColumn: NSTableColumn?, byItem item: AnyObject?) -> AnyObject? {
        return (_requiredMethodsDataSource ?? outlineViewDataSourceNotSet).outlineView?(outlineView, objectValueForTableColumn: tableColumn, byItem: item)
    }

    // MARK: proxy

    /**
    For more information take a look at `DelegateProxyType`.
    */
    public override class func createProxyForObject(object: AnyObject) -> AnyObject {
        let outlineView = (object as! NSOutlineView)

        return castOrFatalError(outlineView.rx_createDataSourceProxy())
    }

    /**
     For more information take a look at `DelegateProxyType`.
     */
    public override class func delegateAssociatedObjectTag() -> UnsafePointer<Void> {
        return _pointer(&dataSourceAssociatedTag)
    }

    /**
     For more information take a look at `DelegateProxyType`.
     */
    public class func setCurrentDelegate(delegate: AnyObject?, toObject object: AnyObject) {
        let collectionView: NSOutlineView = castOrFatalError(object)
        collectionView.setDataSource(castOptionalOrFatalError(delegate))
    }

    /**
     For more information take a look at `DelegateProxyType`.
     */
    public class func currentDelegateFor(object: AnyObject) -> AnyObject? {
        let collectionView: NSOutlineView = castOrFatalError(object)
        return collectionView.dataSource()
    }

    /**
     For more information take a look at `DelegateProxyType`.
     */
    public override func setForwardToDelegate(forwardToDelegate: AnyObject?, retainDelegate: Bool) {
        let requiredMethodsDataSource: NSOutlineViewDataSource? = castOptionalOrFatalError(forwardToDelegate)
        _requiredMethodsDataSource = requiredMethodsDataSource ?? outlineViewDataSourceNotSet
        super.setForwardToDelegate(forwardToDelegate, retainDelegate: retainDelegate)
    }
}