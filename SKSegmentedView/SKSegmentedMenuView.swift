//
//  SKSegmentedMenuView.swift
//  SwiftDemo
//
//  Created by 李烁凯 on 2020/9/17.
//  Copyright © 2020 luckysk. All rights reserved.
//



import UIKit

struct SKSegmentedMenuViewDefault: SKSegmentedMenuViewCustom {
    
}

class SKSegmentedMenuView: UIView {

    typealias OtherItemTapHandlerBlock = (_ item: SKSegmentedMenuItem) -> ()
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView.init(frame: self.bounds)
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.autoresizingMask = UIView.AutoresizingMask(arrayLiteral: .flexibleHeight, .flexibleBottomMargin, .flexibleWidth)
        if #available(iOS 11.0, *){
            scrollView.contentInsetAdjustmentBehavior = .never
        }
        self.addSubview(scrollView)
        return scrollView
    }()
    
    private var menuViewCustom: SKSegmentedMenuViewCustom
    weak var delegate: SKSegmentedMenuViewDelegate?
    
    var otherItemTapHandlerBlock: OtherItemTapHandlerBlock?
    var otherItem: SKSegmentedMenuItem?
    lazy var otherItemLeftLine: UIView = {
        let line = UIView.init()
        line.backgroundColor = UIColor.red.withAlphaComponent(0.8)
        return line
    }()
    
    private var menuItems: [SKSegmentedMenuItem] = Array()
    
    private lazy var itemSelectedBgImageView: UIImageView = {
        let imageView = UIImageView.init()
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = menuViewCustom.itemSelectedBgColor
        imageView.image = menuViewCustom.itemSelectedBgImage
        if menuViewCustom.itemSelectedBgRadius != 0 {
            imageView.layer.masksToBounds = true
            imageView.layer.cornerRadius = CGFloat(menuViewCustom.itemSelectedBgRadius)
        }
        
        return imageView
    }()
    
    private var leftAndRightSpacing: CGFloat {
        CGFloat(menuViewCustom.leftAndRightSpacing)
    }
    
    private var itemFitTextWidthSpacing: CGFloat {
        CGFloat(menuViewCustom.itemFitTextWidthSpacing)
    }
    
    private var itemSelectedBgInsets: UIEdgeInsets {
        menuViewCustom.itemSelectedBgViewInsets ?? UIEdgeInsets.zero
    }
    
    private var itemFullWidth: Bool {
        menuViewCustom.isItemFullWidth
    }
    
    /// 选中的item
    private var selectedItem: SKSegmentedMenuItem? {
        if selectIndex < 0 {
            return nil
        }
        return menuItems[selectIndex]
    }
    
    var selectIndex: Int = -1 {
        willSet{
            guard let ts = self.titles else { return }
            
            if newValue == selectIndex ||
                newValue < 0 ||
                newValue >= ts.count ||
                ts.count == 0 {
                return
            }
            
            delegate?.segmentedMenuView?(self, willSelectItem: newValue)
            
            if selectIndex >= 0 {
                let oldSelectItem = menuItems[selectIndex]
                oldSelectItem.isSelected = false
                let scale = menuViewCustom.font.pointSize / menuViewCustom.selectedFont.pointSize
                oldSelectItem.transform = CGAffineTransform.init(scaleX: scale, y: scale)
            }
            
            let newSelectItem = menuItems[newValue]
            newSelectItem.isSelected = true

            newSelectItem.transform = CGAffineTransform.init(scaleX: 1, y: 1)
            if menuViewCustom.itemSelectedBgViewAnimated {
                
                UIView.animate(withDuration: 0.25) {
                    self.updateSlectedBgViewFrame(index: newValue)
                }
                
            } else {
                updateSlectedBgViewFrame(index: newValue)
            }
        }
        
        didSet {
            setSelectedItemCenter()
            delegate?.segmentedMenuView?(self, didSelectedItem: selectIndex)
        }
    }
    
    var titles: [String]? {
        
        willSet{
            menuItems.forEach{ $0.removeFromSuperview() }
        }
        
        didSet {
            if let ts = titles {
                var items = [SKSegmentedMenuItem]()
                ts.forEach {
                    let menuItem = SKSegmentedMenuItem.init(frame: .zero, itemCustom: menuViewCustom)
                    menuItem.title = $0
                    menuItem.addTarget(self, action: #selector(menuItemAction), for: .touchUpInside)
                    items.append(menuItem)
                    
                    menuItem.itemDoubleTapBlock = { [weak self] in
                        guard let weakSelf = self else { return }
                        weakSelf.delegate?.segmentedMenuView?(weakSelf, selectedItemDoubleTap: weakSelf.selectIndex)
                    }
                    
                }
                menuItems = items
                
                updateItemsFrame()
                
                /// 默认选中第一个
                selectIndex = 0
                
                updateItemsScaleIfNeeded()
            }
        }
    }
    
    
    /// 在最右边添加一个按钮
    /// - Parameters:
    ///   - menuItem: 添加的按钮
    ///   - tapHandlerBlock: 按钮点击的回调
    func addOtherMenuItem(menuItem: SKSegmentedMenuItem, _ tapHandlerBlock: @escaping OtherItemTapHandlerBlock) {
        otherItem = menuItem
        menuItem.addTarget(self, action: #selector(otherMenuItemAction), for: .touchUpInside)
        self.addSubview(menuItem)
        menuItem.addSubview(otherItemLeftLine)
        otherItemTapHandlerBlock = tapHandlerBlock
        
        updateItemsFrame()
        updateSlectedBgViewFrame(index: selectIndex)
    }
    
    /// 更新每个item位置
    private func updateItemsFrame() {
        
        // item选中的背景移除
        itemSelectedBgImageView.removeFromSuperview()
        scrollView.addSubview(itemSelectedBgImageView)
        
        var x: CGFloat = leftAndRightSpacing
        
        // 设置itemFrame
        if itemFullWidth {
            var allItemWidth = self.frame.size.width - CGFloat(leftAndRightSpacing * 2)
            
            if let oi = otherItem {
                allItemWidth -= oi.frame.size.width
            }
            
            // 每一item宽度
            var itemWidth = allItemWidth / CGFloat(menuItems.count)
            
            // 四舍五入 取整 防止字体模糊
            itemWidth = CGFloat(floorf(Float(itemWidth) + 0.5))
            
            for (index, item) in menuItems.enumerated() {
                item.frame = CGRect.init(x: x, y: 0, width: itemWidth, height: self.frame.size.height)
                item.index = index
                x += itemWidth
                scrollView.addSubview(item)
            }
        }else{
            
            if let oi = otherItem {
                if oi.frame.size.width > 0 {
                    scrollView.frame = CGRect.init(x: 0, y: 0, width: self.frame.size.width - oi.frame.size.width, height: self.frame.size.height)
                }
            }
            
            for (index, item) in menuItems.enumerated() {
                let size = CGSize.init(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
                let attributes = [NSAttributedString.Key.font: item.titleLabel?.font]
                let option = NSStringDrawingOptions.usesLineFragmentOrigin
                let rect: CGRect = item.title!.boundingRect(with: size, options: option, attributes: attributes as [NSAttributedString.Key : Any], context: nil)
                
                
                let itemWidth = CGFloat(ceilf(Float(rect.size.width))) + itemFitTextWidthSpacing;
                
                item.frame = CGRect.init(x: x, y: 0, width: itemWidth, height: self.frame.size.height)
                item.index = index
                x += CGFloat(itemWidth)
                scrollView.addSubview(item)
            }
        }
        
        if let oi = otherItem {
            if oi.frame.size.width > 0 {
                let width = oi.frame.size.width
                let height = self.frame.size.height
                oi.frame = CGRect.init(x: self.frame.size.width - width, y: 0, width: width, height: height)
                otherItemLeftLine.frame = CGRect.init(x: 0, y: 10, width: 1, height: height - 20)
            }
        }
        
        scrollView.contentSize = CGSize.init(width: max(x + self.leftAndRightSpacing, self.scrollView.frame.size.width), height: self.scrollView.frame.size.height)
    }
    
    private func updateItemsScaleIfNeeded() {
        
        let scale = menuViewCustom.font.pointSize / menuViewCustom.selectedFont.pointSize
        
        menuItems.forEach {
            $0.titleFont = menuViewCustom.selectedFont
            
            if $0.isSelected == false{
                $0.transform = CGAffineTransform.init(scaleX: scale, y: scale)
            }
        }
    }
    
    /// 更新选中的背景
    /// - Parameter index: 选中的下标
    private func updateSlectedBgViewFrame(index: Int){
        if index < 0 {
            return
        }
        
        let item = menuItems[index]
        
        let width = ((menuViewCustom.itemSlelectdFixedWidth != 0) ? CGFloat(menuViewCustom.itemSlelectdFixedWidth) : item.frameWithOutTransform.size.width) - itemSelectedBgInsets.left - itemSelectedBgInsets.right;
        let height = item.frameWithOutTransform.size.height - itemSelectedBgInsets.top - itemSelectedBgInsets.bottom;
        
        itemSelectedBgImageView.frame = CGRect.init(x: item.frameWithOutTransform.origin.x + itemSelectedBgInsets.left + ((menuViewCustom.itemSlelectdFixedWidth != 0) ? ((item.frameWithOutTransform.size.width - CGFloat(menuViewCustom.itemSlelectdFixedWidth)) / 2) : 0),
                                                    y: item.frameWithOutTransform.origin.y + itemSelectedBgInsets.top,
                                                    width: width,
                                                    height: height)
    }
    
    
    // item点击事件
    @objc func menuItemAction(_ sender: SKSegmentedMenuItem) {
        selectIndex = sender.index
    }
    
    // otherItem点击事件
    @objc func otherMenuItemAction(_ sender: SKSegmentedMenuItem) {
        if let b = otherItemTapHandlerBlock {
            b(sender)
        }
    }
    
    
    /// 将选中的item居中
    private func setSelectedItemCenter() {
        var offsetX = (selectedItem?.center.x ?? 0) - scrollView.frame.size.width * 0.5
        
        if offsetX < 0 {
            offsetX = 0
        }
        
        let maxOffsetX = self.scrollView.contentSize.width - self.scrollView.frame.size.width;
        
        if offsetX > maxOffsetX {
            offsetX = maxOffsetX
        }
        
        scrollView.setContentOffset(CGPoint.init(x: offsetX, y: 0), animated: true)
    }
    
    init(frame: CGRect, menuViewCustom: SKSegmentedMenuViewCustom?) {
        
        if let mc = menuViewCustom {
            self.menuViewCustom = mc
        } else {
            self.menuViewCustom = SKSegmentedMenuViewDefault.init()
            
        }
        
        super.init(frame: frame)
        internalInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        SKPrint("释放")
    }
    
    private func internalInit() {
        backgroundColor = .white
    }
    
    func updateSubViewsWhenParentScrollView(scrollView: UIScrollView, followContent: SKSegmentedFollowContent) {
        
        let offsetX = scrollView.contentOffset.x
        let scrollViewWidth = scrollView.frame.size.width
        
        let leftIndex = Int(offsetX / scrollViewWidth)
        let rightIndex = leftIndex + 1
        
        let leftItem = menuItems[leftIndex]
        var rightItem_nil: SKSegmentedMenuItem? = nil
        
        if rightIndex < menuItems.count {
            rightItem_nil = menuItems[rightIndex]
        }
        
        guard let rightItem = rightItem_nil else { return }
        
        // 计算右边按钮偏移量
        var rightScale = offsetX / scrollViewWidth;
        // 只想要 0~1
        rightScale = rightScale - CGFloat(leftIndex);
        let leftScale = 1 - rightScale;
        
        // 颜色变化
        if followContent.isItemColorChangeFollowContentScroll {
            var normalRed: CGFloat = 0, normalGreen: CGFloat = 0, normalBlue: CGFloat = 0, normalAlpha: CGFloat = 0
            var selectedRed: CGFloat = 0, selectedGreen: CGFloat = 0, selectedBlue: CGFloat = 0, selectedAlpha: CGFloat = 0

            followContent.color.getRed(&normalRed, green: &normalGreen, blue: &normalBlue, alpha: &normalAlpha)
            followContent.selectedColor.getRed(&selectedRed, green:&selectedGreen, blue:&selectedBlue, alpha:&selectedAlpha);

            // 获取选中和未选中状态的颜色差值
            let redDiff = selectedRed - normalRed;
            let greenDiff = selectedGreen - normalGreen;
            let blueDiff = selectedBlue - normalBlue;
            let alphaDiff = selectedAlpha - normalAlpha;
            // 根据颜色值的差值和偏移量，设置tabItem的标题颜色
            leftItem.titleLabel?.textColor = UIColor.init(red: leftScale * redDiff + normalRed,
                                                         green: leftScale * greenDiff + normalGreen,
                                                         blue: leftScale * blueDiff + normalBlue,
                                                         alpha: leftScale * alphaDiff + normalAlpha)
            
            rightItem.titleLabel?.textColor =  UIColor.init(red:rightScale * redDiff + normalRed,
                                                             green:rightScale * greenDiff + normalGreen,
                                                              blue:rightScale * blueDiff + normalBlue,
                                                             alpha:rightScale * alphaDiff + normalAlpha);
        }
        
        let itemTitleFontScale = followContent.font.pointSize / followContent.selectedFont.pointSize;
        
        // 如果支持title大小跟随content的拖动进行变化，并且未选中字体和已选中字体的大小不一致
        if followContent.isItemFontChangeFollowContentScroll &&
            itemTitleFontScale != 1.0 {
            
            // 计算字体大小的差值
            let diff = itemTitleFontScale - 1;
            
            // 根据偏移量和差值，计算缩放值
            leftItem.transform = CGAffineTransform.init(scaleX: rightScale * diff + 1, y: rightScale * diff + 1)
            rightItem.transform = CGAffineTransform.init(scaleX: leftScale * diff + 1, y: leftScale * diff + 1)
        }
        
        var frame = itemSelectedBgImageView.frame
        
        
        let rightItemX = (rightItem.frameWithOutTransform.origin.x + ((followContent.itemSlelectdFixedWidth != 0) ? ((rightItem.frameWithOutTransform.size.width - CGFloat(followContent.itemSlelectdFixedWidth)) / 2) : 0))
        let leftItemX = (leftItem.frameWithOutTransform.origin.x + ((followContent.itemSlelectdFixedWidth != 0) ? ((leftItem.frameWithOutTransform.size.width - CGFloat(followContent.itemSlelectdFixedWidth)) / 2) : 0))
        let xDiff = rightItemX - leftItemX
        
        frame.origin.x = rightScale * xDiff + leftItem.frameWithOutTransform.origin.x + itemSelectedBgInsets.left + ((followContent.itemSlelectdFixedWidth != 0) ? ((leftItem.frameWithOutTransform.size.width - CGFloat(followContent.itemSlelectdFixedWidth)) / 2) : 0)
        
        if followContent.itemSlelectdFixedWidth != 0{

            frame.size.width = CGFloat(followContent.itemSlelectdFixedWidth) - itemSelectedBgInsets.left - itemSelectedBgInsets.right

        } else {

            let widthDiff = rightItem.frameWithOutTransform.size.width - leftItem.frameWithOutTransform.size.width
            if (widthDiff != 0) {
                let leftSelectedBgWidth = leftItem.frameWithOutTransform.size.width - itemSelectedBgInsets.left - itemSelectedBgInsets.right
                frame.size.width = rightScale * widthDiff + leftSelectedBgWidth
            }
        }

        self.itemSelectedBgImageView.frame = frame;
    }
    
}
