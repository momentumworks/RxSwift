//
//  RxNSOutlineViewDelegateProxy.swift
//  RxCocoa
//
//  Created by Rheese Burgess on 16/12/2015.
//

import Foundation
#if !RX_NO_MODULE
import RxSwift
#endif
import Cocoa

public class RxNSOutlineViewDelegateProxy : DelegateProxy
        , NSOutlineViewDelegate
        , DelegateProxyType {

    /**
     Typed parent object.
     */
    public weak private(set) var outlineView: NSOutlineView?

    public required init(parentObject: AnyObject) {
        self.outlineView = (parentObject as! NSOutlineView)
        super.init(parentObject: parentObject)
    }

    // MARK : Delegate Proxy

    /**
    For more information take a look at `DelegateProxyType`.
    */
    public override class func createProxyForObject(object: AnyObject) -> AnyObject {
        let outlineView = (object as! NSOutlineView)

        return castOrFatalError(outlineView.rx_createDelegateProxy())
    }

    /**
    For more information take a look at `DelegateProxyType`.
    */
    public class func setCurrentDelegate(delegate: AnyObject?, toObject object: AnyObject) {
        let outlineView: NSOutlineView = castOrFatalError(object)
        outlineView.setDelegate(castOptionalOrFatalError(delegate))
    }

    /**
    For more information take a look at `DelegateProxyType`.
    */
    public class func currentDelegateFor(object: AnyObject) -> AnyObject? {
        let outlineView: NSOutlineView = castOrFatalError(object)
        return outlineView.delegate()
    }
}
