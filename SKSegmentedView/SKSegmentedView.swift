//
//  SKSegmentedView.swift
//  SwiftDemo
//
//  Created by 李烁凯 on 2020/9/17.
//  Copyright © 2020 luckysk. All rights reserved.
//

struct SKSegmentedViewDefault: SKSegmentedViewProtocol {
}

import UIKit

class SKSegmentedView: UIView {
    
    /// 默认的menuView高度
    static var menuViewHeight: CGFloat = 44.0

    /// 默认选中的下标
    var defaultSelectedIndex: Int = 0 {
        didSet {
            menuView.selectIndex = defaultSelectedIndex
        }
    }
    
    weak var delegate: SKSegmentedViewDelegate?
    
    private lazy var rootScrollView: UIScrollView = {
        let rootScorllView = UIScrollView.init()
        rootScorllView.delegate = self
        rootScorllView.isPagingEnabled = true
        rootScorllView.isUserInteractionEnabled = true
        rootScorllView.bounces = false
        rootScorllView.showsVerticalScrollIndicator = false
        rootScorllView.showsHorizontalScrollIndicator = false
        rootScorllView.autoresizingMask = UIView.AutoresizingMask(arrayLiteral: .flexibleHeight, .flexibleBottomMargin, .flexibleWidth)
        if #available(iOS 11.0, *){
            rootScorllView.contentInsetAdjustmentBehavior = .never
        }
        self.addSubview(rootScorllView)
        return rootScorllView
    }()

    private var segmentedViewPro: SKSegmentedViewProtocol
    
    private lazy var menuView: SKSegmentedMenuView = {
        let menuView = SKSegmentedMenuView.init(frame: .zero, menuViewCustom: segmentedViewPro)
        menuView.delegate = self
        self.addSubview(menuView)
        return menuView
    }()
    
    private var selectedControllerIndex: Int = 0
    private var selectedController: UIViewController? {
        get {
            if selectedControllerIndex < 0 {
                return nil
            }
            return viewControllers[selectedControllerIndex]
        }
    }
    
    var viewControllers: Array<UIViewController> = Array() {
        willSet{
            viewControllers.forEach{
                $0.removeFromParent()
                $0.view.removeFromSuperview()
            }
        }
        didSet {
            setupDataOfTabBarAndContenView()
        }
    }
    
    /// 在menuView的右边添加一个按钮
    /// - Parameters:
    ///   - menuItem: 添加的按钮
    ///   - handlerBlock: 按钮的回调
    func addOtherMenuItem(_ menuItem: SKSegmentedMenuItem, handlerBlock: @escaping (_ menuItem: SKSegmentedMenuItem) -> Void) {
        menuView.addOtherMenuItem(menuItem: menuItem) { (item) in
            handlerBlock(item)
        }
    }
    
    init(frame: CGRect, segmentedViewProtocol: SKSegmentedViewProtocol?) {
        
        if let sp = segmentedViewProtocol {
            self.segmentedViewPro = sp
        } else {
            self.segmentedViewPro = SKSegmentedViewDefault.init()
        }
        
        super.init(frame: frame)
        setupFrameOfTabBarAndContentView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 设置 tabbar 和 rootScrollView 的frame
    private func setupFrameOfTabBarAndContentView() {
        setupFrameOfTabBarAndContentView(menuViewHeight: SKSegmentedView.menuViewHeight)
    }
    
    private func setupFrameOfTabBarAndContentView(menuViewHeight: CGFloat) {
        let size = self.bounds.size
        let tabBarFrame = CGRect.init(x: 0, y: 0, width: size.width, height: menuViewHeight)
        let contentViewFrame = CGRect.init(x: 0, y:menuViewHeight, width: size.width, height: size.height - menuViewHeight)
        setupFrameOfTabBarAndContentView(menuViewFrame: tabBarFrame, contentViewFrame: contentViewFrame)
    }
    
    private func setupFrameOfTabBarAndContentView(menuViewFrame: CGRect, contentViewFrame: CGRect) {
        menuView.frame = menuViewFrame
        rootScrollView.frame = contentViewFrame
    }
    
    private func setupDataOfTabBarAndContenView() {
        var titles: Array<String> = Array()
        
        viewControllers.forEach{
            titles.append($0.title ?? "没有设置title")
        }
        menuView.titles = titles
        
        updateContentViewsFrame()
    }
    
    private func updateContentViewsFrame() {
        
        rootScrollView.contentSize = CGSize.init(width: rootScrollView.frame.size.width * CGFloat(viewControllers.count), height: rootScrollView.frame.size.height)
        
        for (index, vc) in viewControllers.enumerated() {
            if vc.isViewLoaded {
                vc.view.frame = getControllerFrame(at: index)
            }
        }
        rootScrollView.scrollRectToVisible(selectedController?.view.frame ?? getControllerFrame(at: 0), animated: false)
    }
    
    /// 根据下标获取vc的frame
    private func getControllerFrame(at index: Int) -> CGRect {
        return CGRect.init(x: CGFloat(index) * rootScrollView.frame.size.width, y: 0, width: rootScrollView.frame.size.width, height: rootScrollView.frame.size.height)
    }
    
}

extension SKSegmentedView: SKSegmentedMenuViewDelegate{
    
    /// 将要切换到index
    func segmentedMenuView(_ segmentedView: SKSegmentedMenuView, willSelectItem index: Int){
        delegate?.segmentedView?(self, willSelectItem: index)
    }

    /// 已经切换到index
    func segmentedMenuView(_ segmentedView: SKSegmentedMenuView, didSelectedItem index: Int){

        var oldController: UIViewController? = nil

        if selectedControllerIndex >= 0 {
            oldController = viewControllers[selectedControllerIndex]

            for (ix, vc) in viewControllers.enumerated() {
                if ix != index &&
                    vc.isViewLoaded &&
                    vc.view.superview != nil{
                    vc.view.removeFromSuperview()
                }
            }
        }

        let curVC = viewControllers[index]

        if !curVC.isViewLoaded {
            curVC.view.frame = getControllerFrame(at: index)
        }

        rootScrollView.addSubview(curVC.view)
        rootScrollView.scrollRectToVisible(curVC.view.frame, animated: false)

        // segmentedView didSelectedItem
        delegate?.segmentedView?(self, didSelectedItem: index)

        if let oldVC = oldController {
            if ((oldVC.view as? UIScrollView) != nil) {
                let scrollView = oldVC.view as! UIScrollView
                scrollView.scrollsToTop = false
            }
        }

        if ((curVC.view as? UIScrollView) != nil) {
            let scrollView = curVC.view as! UIScrollView
            scrollView.scrollsToTop = true
        }

        selectedControllerIndex = index
    }

    /// 选中的item双击
    func segmentedMenuView(_ segmentedView: SKSegmentedMenuView, selectedItemDoubleTap index: Int) {
        delegate?.segmentedView?(self, selectedItemDoubleTap: index)
    }
    
}

extension SKSegmentedView: UIScrollViewDelegate{
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let page = scrollView.contentOffset.x / scrollView.frame.size.width
        menuView.selectIndex = Int(page)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !(scrollView.isDragging ||
            scrollView.isDecelerating){
            return
        }

        let offsetX = scrollView.contentOffset.x
        let scrollViewWidth = scrollView.frame.size.width

        if offsetX < 0 {
            return
        }

        if offsetX > scrollView.contentSize.width - scrollViewWidth {
            return
        }

        let leftIndex = Int(offsetX / scrollViewWidth)
        var rightIndex = leftIndex + 1

        if CGFloat(leftIndex) == offsetX / scrollViewWidth {
            rightIndex = leftIndex

        }

        for index in leftIndex...rightIndex {

            let vc = viewControllers[index]

            if !vc.isViewLoaded &&
                segmentedViewPro.loadViewOfChildContollerWhileAppear {
                vc.view.frame = getControllerFrame(at: index)
            }

            if vc.isViewLoaded &&
                vc.view.superview == nil{
                rootScrollView.addSubview(vc.view)
            }
        }

        menuView.updateSubViewsWhenParentScrollView(scrollView: rootScrollView, followContent: segmentedViewPro)
        
    }
    
}
