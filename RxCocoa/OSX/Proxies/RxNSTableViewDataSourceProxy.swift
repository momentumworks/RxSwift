//
//  RxNSTableViewDataSourceProxy.swift
//  Rx
//
//  Created by Rheese Burgess on 06/01/2016.
//

import Foundation
#if !RX_NO_MODULE
import RxSwift
#endif
import Cocoa

let tableViewDataSourceNotSet = TableViewDataSourceNotSet()

class TableViewDataSourceNotSet : NSObject
                                , NSTableViewDataSource {
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        // This is sometimes called before the datasource is set, as described in the documentation, so we return 0
        return 0
    }
    
    func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
        rxAbstractMethodWithMessage(dataSourceNotSet)
    }
    
    func tableView(tableView: NSTableView, setObjectValue object: AnyObject?, forTableColumn tableColumn: NSTableColumn?, row: Int) {
        rxAbstractMethodWithMessage(dataSourceNotSet)
    }
}

public class RxNSTableViewDataSourceProxy : DelegateProxy
                                          , NSTableViewDataSource
                                          , DelegateProxyType {
    
    /**
     Typed parent object.
     */
    public weak private(set) var tableView: NSTableView?
    
    private weak var _requiredMethodsDataSource: NSTableViewDataSource? = tableViewDataSourceNotSet
    
    /**
     Initializes `RxTableViewDataSourceProxy`
     
     - parameter parentObject: Parent object for delegate proxy.
     */
    public required init(parentObject: AnyObject) {
        self.tableView = (parentObject as! NSTableView)
        super.init(parentObject: parentObject)
    }
    
    // MARK: Delegate
    
    public func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return (_requiredMethodsDataSource ?? tableViewDataSourceNotSet).numberOfRowsInTableView?(tableView) ?? 0
    }
    
    public func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
        return (_requiredMethodsDataSource ?? tableViewDataSourceNotSet).tableView?(tableView, objectValueForTableColumn: tableColumn, row: row)
    }
    
    public func tableView(tableView: NSTableView, setObjectValue object: AnyObject?, forTableColumn tableColumn: NSTableColumn?, row: Int) {
        (_requiredMethodsDataSource ?? tableViewDataSourceNotSet).tableView?(tableView, setObjectValue: object, forTableColumn: tableColumn, row: row)
    }
    
    // MARK: proxy
    
    /**
    For more information take a look at `DelegateProxyType`.
    */
    public override class func createProxyForObject(object: AnyObject) -> AnyObject {
        let tableView = (object as! NSTableView)
        
        return castOrFatalError(tableView.rx_createTableViewDataSourceProxy())
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
        let collectionView: NSTableView = castOrFatalError(object)
        collectionView.setDataSource(castOptionalOrFatalError(delegate))
    }
    
    /**
     For more information take a look at `DelegateProxyType`.
     */
    public class func currentDelegateFor(object: AnyObject) -> AnyObject? {
        let collectionView: NSTableView = castOrFatalError(object)
        return collectionView.dataSource()
    }
    
    /**
     For more information take a look at `DelegateProxyType`.
     */
    public override func setForwardToDelegate(forwardToDelegate: AnyObject?, retainDelegate: Bool) {
        let requiredMethodsDataSource: NSTableViewDataSource? = castOptionalOrFatalError(forwardToDelegate)
        _requiredMethodsDataSource = requiredMethodsDataSource ?? tableViewDataSourceNotSet
        super.setForwardToDelegate(forwardToDelegate, retainDelegate: retainDelegate)
    }
}