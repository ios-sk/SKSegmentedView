//
//  SKSegmentedMenuItem.swift
//  SwiftDemo
//
//  Created by 李烁凯 on 2020/9/17.
//  Copyright © 2020 luckysk. All rights reserved.
//

struct SKSegmentedMenuItemDefault: SKSegmentedMenuItemCustom {
}

import UIKit

class SKSegmentedMenuItem: UIButton {
    
    var index: Int = 0
    
    var itemCustom: SKSegmentedMenuItemCustom
    
    private var _frameWithOutTransform = CGRect.zero
    var frameWithOutTransform: CGRect {
        get {
            _frameWithOutTransform
        }
    }
    
    /// 双击回调
    var itemDoubleTapBlock: (() -> ())?
    
    var title: String? {
        didSet {
            setTitle(title, for: .normal)
        }
    }
    
    var titleFont: UIFont? {
        didSet {
            titleLabel?.font = titleFont
        }
    }
    
    // 双击回调的view
    private lazy var tapView: UIView = {
        let tapView = UIView.init()
        tapView.isHidden = true
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(doubleTapAction))
        tap.numberOfTapsRequired = 2
        tapView.addGestureRecognizer(tap)
        self.addSubview(tapView)
        return tapView
    }()
    
    init(frame: CGRect, itemCustom: SKSegmentedMenuItemCustom?) {
        if let ic = itemCustom {
            self.itemCustom = ic
        } else {
            self.itemCustom = SKSegmentedMenuItemDefault.init()
        }
        
        super.init(frame: frame)
        setUp()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUp() {
        self.adjustsImageWhenHighlighted = false
        
        setTitleColor(itemCustom.color, for: .normal)
        setTitleColor(itemCustom.selectedColor, for: .selected)
        
        titleFont = itemCustom.font
        
        setImage(itemCustom.image, for: .normal)
        setImage(itemCustom.selectedImage, for: .selected)
    }
    
    override var isHighlighted: Bool {
        willSet {
            if self.adjustsImageWhenHighlighted {
                super.isHighlighted = newValue
            }
        }
    }
    
    override var frame: CGRect {
        didSet {
            _frameWithOutTransform = frame
            tapView.frame = self.bounds
        }
    }
    
    override var isSelected: Bool {
        didSet {
            tapView.isHidden = !isSelected
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let _ = self.image(for: .normal) {
            
            if itemCustom.contentHorizontalCenter {
                var titleSize = self.titleLabel?.frame.size ?? CGSize.init(width: 0, height: 0)
                let imageSize = self.imageView?.frame.size ?? CGSize.init(width: 0, height: 0)
                
                titleSize = CGSize.init(width: CGFloat(ceilf(Float(titleSize.width))), height: CGFloat(ceilf(Float(titleSize.height))))
            
                let totalHeight = imageSize.height + titleSize.height + CGFloat(itemCustom.spacing)
                self.imageEdgeInsets = UIEdgeInsets.init(top: -(totalHeight - imageSize.height - CGFloat(itemCustom.verticalOffset)), left: 0, bottom: 0, right: -titleSize.width)
                self.titleEdgeInsets = UIEdgeInsets.init(top: CGFloat(itemCustom.verticalOffset), left: imageSize.width, bottom: -(totalHeight - titleSize.height), right: 0)
            }
        }
    }
    
    @objc func doubleTapAction() {
        if let db = itemDoubleTapBlock {
            db()
        }
    }
}
