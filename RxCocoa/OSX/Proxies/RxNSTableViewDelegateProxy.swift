//
//  RxNSTableViewDelegateProxy.swift
//  Rx
//
//  Created by Rheese Burgess on 06/01/2016.
//


import Foundation
#if !RX_NO_MODULE
import RxSwift
#endif
import Cocoa

public class RxNSTableViewDelegateProxy : DelegateProxy
                                        , NSTableViewDelegate
                                        , DelegateProxyType {
    
    /**
     Typed parent object.
     */
    public weak private(set) var tableView: NSTableView?
    
    public required init(parentObject: AnyObject) {
        self.tableView = (parentObject as! NSTableView)
        super.init(parentObject: parentObject)
    }
    
    // MARK : Delegate Proxy
    
    /**
    For more information take a look at `DelegateProxyType`.
    */
    public override class func createProxyForObject(object: AnyObject) -> AnyObject {
        let tableView = (object as! NSTableView)
        
        return castOrFatalError(tableView.rx_createTableViewDelegateProxy())
    }
    
    /**
     For more information take a look at `DelegateProxyType`.
     */
    public class func setCurrentDelegate(delegate: AnyObject?, toObject object: AnyObject) {
        let tableView: NSTableView = castOrFatalError(object)
        tableView.setDelegate(castOptionalOrFatalError(delegate))
    }
    
    /**
     For more information take a look at `DelegateProxyType`.
     */
    public class func currentDelegateFor(object: AnyObject) -> AnyObject? {
        let tableView: NSTableView = castOrFatalError(object)
        return tableView.delegate()
    }
}