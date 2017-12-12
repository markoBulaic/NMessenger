//
//  MixedContentNodeWithTimestamp.swift
//  nMessenger-iOS
//
//  Created by Alexander Dodatko on 12/12/17.
//  Copyright © 2017 Ebay Inc. All rights reserved.
//

import Foundation


open class MixedContentNodeWithTimestamp: ContentNode {
    
    open var textNode: ASTextNode?
    open var timestampNode: ASTextNode?
    open var attachmentsNode: CollectionViewContentNode?
    
    open override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        let children: [ASLayoutElement?] = [self.timestampNode,
                                            self.textNode,
                                            self.attachmentsNode]
        
        let stackSpec = ASStackLayoutSpec(direction: .vertical,
                                          spacing: 5,
                                          justifyContent: .start,
                                          alignItems: .start,
                                          children: children.flatMap { $0 })
        
        let insets = UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 15)
        
        let insetSpec = ASInsetLayoutSpec(insets: insets,
                                          child: stackSpec)
        return insetSpec
    }
    
    open override func messageNodeLongPressSelector(
        _ recognizer: UITapGestureRecognizer)
    {
        // TODO: rewrite if specific menu is required for each cell
        //
        // fatalError("handled in MessageNode")
    }
    
}
