//
// Copyright (c) 2016 eBay Software Foundation
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

import UIKit
import AsyncDisplayKit

//MARK: CollectionViewContentNode
/**
 CollectionViewContentNode for NMessenger. Extends ContentNode.
 Define content that is a collection view. The collection view can have 1 row or multiple row.
 Cells can be either views or nodes.
 */
open class CollectionViewContentNode: ContentNode
                                    , ASCollectionDelegate
                                    , ASCollectionDataSource
                                    , UICollectionViewDelegateFlowLayout
{
    /**Should the bubble be masked or not*/
    open var maskedBubble = true
    {
        didSet
        {
            self.updateBubbleConfig(self.bubbleConfiguration)
            self.setNeedsLayout()
        }
    }
    
    // MARK: Private Variables
    /** ASCollectionNode as the content of the cell*/
    internal var collectionViewMessageNode:ASCollectionNode =
        ASCollectionNode(collectionViewLayout: UICollectionViewFlowLayout())
    
    /** [ASDisplayNode] as the posibble data of the cell*/
    fileprivate var collectionViewsDataSource: [ASDisplayNode]?
    
    /** [UIView] as the posibble data of the cell*/
    fileprivate var viewsForDataSource: [UIView]?
    
    /** [ASDisplayNode] as the posibble data of the cell*/
    fileprivate var collectionNodesDataSource: [ASDisplayNode]?
    
    /** CGSize as the max size of a cell in the collection view*/
    fileprivate var cellSize: CGSize = CGSize(width: 1, height: 1)
    
    /** CGFloat as the number of rows in the collection view*/
    fileprivate var collectionViewNumberOfRows: CGFloat = 1;
    
    /** CGFloat as the number of rows in the collection view*/
    fileprivate var collectionViewNumberItemInRow: Int = 1;
    
    /** CGFloat as the space between rows in the collection view*/
    fileprivate var spacingBetweenRows: CGFloat = 4
    
    /** CGFloat as the space between cells in the collection view*/
    fileprivate var spacingBetweenCells: CGFloat = 4

    // MARK: Initialisers
    /**
     Initialiser for the cell.
     - parameter customViews: Must be [UIView]. Sets views for the cell.
     - parameter rows: Must be CGFloat. Sets number of rows for the cell.
     Calls helper method to setup cell
     */
    public init(
        withCustomViews customViews: [UIView],
        andNumberOfRows rows: CGFloat,
        bubbleConfiguration: BubbleConfigurationProtocol? = nil)
    {
        super.init(bubbleConfiguration: bubbleConfiguration)
        self.setupCustomViews(customViews,numberOfRows: rows)
    }
    
    /**
     Initialiser for the cell.
     - parameter customNodes: Must be [ASDisplayNode]. Sets views for the cell.
     - parameter rows: Must be CGFloat. Sets number of rows for the cell.
     Calls helper method to setup cell
     */
    public init(
        withCustomNodes customNodes:[ASDisplayNode],
        andNumberOfRows rows: CGFloat,
        bubbleConfiguration: BubbleConfigurationProtocol? = nil)
    {
        super.init(bubbleConfiguration: bubbleConfiguration)
        self.setupCustomNodes(customNodes,numberOfRows: rows)
    }
    
    // MARK: Initialiser helper methods
    /** Override updateBubbleConfig to set bubble mask */
    open override func updateBubbleConfig(_ newValue: BubbleConfigurationProtocol)
    {
        var maskedBubbleConfig = newValue
        maskedBubbleConfig.isMasked = self.maskedBubble
        
        super.updateBubbleConfig(maskedBubbleConfig)
    }
    
    /**
     Creates a collectionview view with horizontal scrolling with the custom UIViews and the number of rows
     - parameter customViews: Must be [UIView]. Sets views for the cell.
     - parameter rows: Must be CGFloat. Sets number of rows for the cell.
     */
    fileprivate func setupCustomViews(
        _ customViews: [UIView],
        numberOfRows rows: CGFloat)
    {
        let isSingleRow = (Int(round(rows)) == 1)
        self.collectionViewNumberOfRows    = rows
        self.viewsForDataSource            = customViews
        self.collectionViewNumberItemInRow = customViews.count/Int(rows)
        
        
        if let tmpArray = self.viewsForDataSource
        {
            let tmpArrayAsNodes = tmpArray.map
            {
                tmpView -> ASDisplayNode in
                
                let viewBlock: AsyncDisplayKit.ASDisplayNodeViewBlock =
                {
                    () -> UIView in
                    
                    return tmpView
                }
                
                let tmpNode = ASDisplayNode(viewBlock: viewBlock)
                tmpNode.style.preferredSize = tmpView.frame.size
                
                return tmpNode
            }
            
            self.collectionViewsDataSource = tmpArrayAsNodes
        }
        
        
        let flowLayout = UICollectionViewFlowLayout()
        if (isSingleRow)
        {
            flowLayout.scrollDirection = .horizontal
        }
        
        flowLayout.itemSize                = self.cellSize
        flowLayout.minimumInteritemSpacing = self.spacingBetweenCells
        flowLayout.minimumLineSpacing      = self.spacingBetweenRows
        
        
        let collectionViewMessageNode =
            ASCollectionNode(collectionViewLayout: flowLayout)
        
            collectionViewMessageNode.backgroundColor = UIColor.clear
            collectionViewMessageNode.accessibilityIdentifier = "CollectionViewWithCustomViews"

        self.collectionViewMessageNode = collectionViewMessageNode
        self.addSubnode(collectionViewMessageNode)
    }
    
    /**
     Creates a collectionview view with horizontal scrolling with the custom ASDisplayNodes and the number of rows
     - parameter customViews: Must be [UIView]. Sets views for the cell.
     - parameter rows: Must be CGFloat. Sets number of rows for the cell.
     */
    fileprivate func setupCustomNodes(
        _ customNodes: [ASDisplayNode],
        numberOfRows rows: CGFloat)
    {
        let isSingleRow = (Int(round(rows)) == 1)
        
        self.collectionViewNumberOfRows    = rows
        self.collectionNodesDataSource     = customNodes
        self.collectionViewNumberItemInRow = customNodes.count/Int(rows)
        
        
        let flowLayout = UICollectionViewFlowLayout()
        if (isSingleRow)
        {
            flowLayout.scrollDirection = .horizontal
        }
        flowLayout.itemSize = cellSize
        flowLayout.minimumInteritemSpacing = spacingBetweenCells
        flowLayout.minimumLineSpacing = spacingBetweenRows
        
        let collectionViewMessageNode =
            ASCollectionNode(collectionViewLayout: flowLayout)

            collectionViewMessageNode.backgroundColor = UIColor.clear
            
            collectionViewMessageNode.accessibilityIdentifier = "CollectionViewWithCustomNodes"
        
        self.collectionViewMessageNode = collectionViewMessageNode
        self.addSubnode(collectionViewMessageNode)
    }
    
    // MARK: Node Lifecycle
    
    /**
     Overriding didLoad to set asyncDataSource and asyncDelegate for collection view
     */
    override open func didLoad()
    {
        super.didLoad()
        
        self.collectionViewMessageNode.delegate   = self
        self.collectionViewMessageNode.dataSource = self
    }
    
    // MARK: Override AsycDisaplyKit Methods
    
    private func updateCellSize(forConstrainedSize tmpConstrainedSize: ASSizeRange)
    {
        if let tmp = self.collectionViewsDataSource
        {
            self.updateCellSizeUsingNodes(
                tmp,
                forConstrainedSize: tmpConstrainedSize,
                shouldUpdatePreferredSizeForEachNode: false)
        }
        else if let tmp = self.collectionNodesDataSource
        {
            self.updateCellSizeUsingNodes(
                tmp,
                forConstrainedSize: tmpConstrainedSize,
                shouldUpdatePreferredSizeForEachNode: true)
        }

    }
    
    private func updateCellSizeUsingNodes(
        _ tmp: [ASDisplayNode],
        forConstrainedSize tmpConstrainedSize: ASSizeRange,
        shouldUpdatePreferredSizeForEachNode: Bool)
    {
        for node in tmp
        {
            let nodeLayout = node.layoutThatFits(tmpConstrainedSize)
            let nodeSize = nodeLayout.size
            
            if (shouldUpdatePreferredSizeForEachNode)
            {
                node.style.preferredSize = nodeSize
            }
            
            if (self.isSmaller(self.cellSize,bigger: nodeSize))
            {
                self.cellSize = nodeSize
            }
        }
    }
    
    private func updateLayoutWidthForMultipleRows(_ width: CGFloat) -> CGFloat
    {
        var result = width
        
        var numOfItems:CGFloat = 0
        if let viewDataSource = self.collectionViewsDataSource
        {
            numOfItems = CGFloat(viewDataSource.count)
        }
        else if let nodeDataSource = self.collectionNodesDataSource
        {
            numOfItems = CGFloat(nodeDataSource.count)
        }
        let numOfColumns = ceil(numOfItems/self.collectionViewNumberOfRows)
        let tmpWidth =
            self.cellSize.width * numOfColumns
                + self.spacingBetweenCells * (numOfColumns - 1)
        
        if (tmpWidth < width)
        {
            result = tmpWidth
        }
        
        return result
    }
    
    
    /**
     Overriding layoutSpecThatFits to specifiy relatiohsips between elements in the cell
     */
    override open func layoutSpecThatFits(
        _ constrainedSize: ASSizeRange)
    -> ASLayoutSpec
    {
        let isMultipleRows = (self.collectionViewNumberOfRows > 1)
        
        // changes `self.cellSize`
        self.updateCellSize(forConstrainedSize: constrainedSize)
        
        
        let height =
            self.cellSize.height * self.collectionViewNumberOfRows
          + self.spacingBetweenRows * (self.collectionViewNumberOfRows - 1)
        
        
        // ===
        //
        var width = constrainedSize.max.width
        if (isMultipleRows)
        {
            width = self.updateLayoutWidthForMultipleRows(width)
        }
        
        self.collectionViewMessageNode.style.preferredSize =
            CGSize(
                width: width,
                height: height)
        
        let tmpSizeSpec = ASAbsoluteLayoutSpec()
            tmpSizeSpec.sizing   = .sizeToFit
            tmpSizeSpec.children = [self.collectionViewMessageNode]
        
        return tmpSizeSpec
    }
    
    // MARK: Private class methods
    
    /**
     - parameter smaller: Must be CGSize
     - parameter bigger: Must be CGSize
     Checks if one CGSize is smaller than another
     */
    fileprivate func isSmaller(
        _ smaller: CGSize,
        bigger: CGSize) -> Bool
    {
        if (smaller.width >= bigger.width)
        {
            return false
        }
        if (smaller.height >= bigger.height)
        {
            return false
        }
        
        return true
        
    }
    
    // MARK: ASCollectionDataSource
    
    /**
     Implementing numberOfSectionsInCollectionView to define number of sections
     */
    open func numberOfSections(in collectionView: UICollectionView) -> Int
    {
        return 1
    }
    
    /**
     Implementing numberOfItemsInSection to define number of items in section
     */
    open func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int)
    -> Int
    {
        return self.itemsCount
    }
    
    private var isEmptyItemsList: Bool
    {
        let result = (0 == self.itemsCount)
        return result
    }
    
    private var itemsCount: Int
    {
        if let viewDataSource = self.collectionViewsDataSource
        {
            return viewDataSource.count
        }
        else if let nodeDataSource = self.collectionNodesDataSource
        {
            return nodeDataSource.count
        }
        
        return 0
    }
    
    private var indexOfLastItem: Int
    {
        let result = self.itemsCount - 1
        return result
    }
    
    /**
     Implementing nodeForItemAtIndexPath to define node at index path
     */
    open func collectionView(
        _ collectionView: ASCollectionView,
        nodeForItemAt indexPath: IndexPath)
    -> ASCellNode
    {
        var cellNode: ASCellNode = ASCellNode()
        if let nodeDataSource = self.collectionNodesDataSource
        {
            // TODO: why not `NSIndexPath.item` ???
            //
            let castedIndexPath: NSIndexPath =
                (indexPath as NSIndexPath)
            let nodeIndex = castedIndexPath.row
            
            let node = nodeDataSource[nodeIndex]
            let tmp = CustomContentCellNode(withCustomNode: node)
            
            cellNode = tmp
            
        }
        return cellNode
    }
    
    /**
     Implementing constrainedSizeForNodeAtIndexPath the size of each cell
     */
    open func collectionView(
        _ collectionView: ASCollectionView,
        constrainedSizeForNodeAt indexPath: IndexPath)
    -> ASSizeRange
    {
        return ASSizeRangeMake(cellSize, cellSize);
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    
    /**
     Implementing insetForSectionAtIndex to define space between colums
     */
    open func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int)
    -> UIEdgeInsets
    {
        if self.collectionViewNumberOfRows != 1
        {
            return UIEdgeInsets.zero
        }
        else
        {
            if (self.isEmptyItemsList)
            {
                return UIEdgeInsets.zero
            }
            
            let lastSectionIndex = self.indexOfLastItem
            precondition(lastSectionIndex >= 0)
            
            let isLastSection = (section == lastSectionIndex)
            
            if (!isLastSection)
            {
                return UIEdgeInsets(
                    top: 0,
                    left: 0,
                    bottom: 0,
                    right: self.spacingBetweenCells)
            }
            
            return UIEdgeInsets.zero
        }
    }
}
