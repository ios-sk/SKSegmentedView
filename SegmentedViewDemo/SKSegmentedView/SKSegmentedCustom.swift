//
//  SKSegmentedCustom.swift
//  SwiftDemo
//
//  Created by 李烁凯 on 2020/9/17.
//  Copyright © 2020 luckysk. All rights reserved.
//

import UIKit


public protocol SKSegmentedMenuItemCustom{
    var color: UIColor { get }
    var selectedColor: UIColor { get }
    
    var font: UIFont { get }
    var selectedFont: UIFont { get }
    
    var image: UIImage? { get }
    var selectedImage: UIImage? { get }
    
    /// 设置image和title的水平居中
    var contentHorizontalCenter: Bool { get }
    /// 垂直方向偏移量 contentHorizontalCenter 为 true 时才有用
    var verticalOffset: Float { get }
    /// Image与Title的间距 contentHorizontalCenter 为 true 时才有用
    var spacing: Float { get }
}

extension SKSegmentedMenuItemCustom {
    var color: UIColor { .black }
    var selectedColor: UIColor { .red }
    
    var font: UIFont { UIFont.systemFont(ofSize: 14) }
    var selectedFont: UIFont { UIFont.systemFont(ofSize: 16) }
    
    var image: UIImage? { nil }
    var selectedImage: UIImage? { nil }
    
    var contentHorizontalCenter: Bool { false }
    var verticalOffset: Float { 0 }
    var spacing: Float { 0 }
}


/// 顶部按钮的设置
public protocol SKSegmentedMenuViewCustom: SKSegmentedMenuItemCustom{
    
    /// tabBar左右边缘距离
    var leftAndRightSpacing: Float { get }
    /// item充满view的宽度 item的宽度固定
    var isItemFullWidth: Bool { get }
    /// item匹配文字宽度是的间距
    var itemFitTextWidthSpacing: Float { get }
    
    /// 选中的背景切换时是否支持动画
    var itemSelectedBgViewAnimated: Bool { get }
    
    /// 选中的背景的Edge 
    var itemSelectedBgViewInsets: UIEdgeInsets? { get }
    
    
    var itemSelectedBgColor: UIColor? { get }
    var itemSelectedBgImage: UIImage? { get }
    
    /// 选择背景的圆角 默认 0
    var itemSelectedBgRadius: Float { get }
    
    /// 选择背景的固定宽度
    var itemSlelectdFixedWidth: Float { get }
}


extension SKSegmentedMenuViewCustom {
    
    var leftAndRightSpacing: Float { 0 }
    var isItemFullWidth: Bool { false }
    var itemFitTextWidthSpacing: Float { 10 }
    
    /// 选中的背景切换时是否支持动画
    var itemSelectedBgViewAnimated: Bool { false }
    
    /// 选中的背景的Edge
    var itemSelectedBgViewInsets: UIEdgeInsets? { UIEdgeInsets.init(top: SKSegmentedView.menuViewHeight - 3, left: 5, bottom: 1, right: 5) }
    
    var itemSelectedBgColor: UIColor? { nil }
    var itemSelectedBgImage: UIImage? { nil }
    
    var itemSelectedBgRadius: Float { 0 }
    var itemSlelectdFixedWidth: Float { 0 }
}

public protocol SKSegmentedFollowContent: SKSegmentedMenuViewCustom {
    
    /// 拖动内容视图时，item的颜色是否根据拖动位置显示渐变效果，默认为true
    var isItemColorChangeFollowContentScroll: Bool { get }
    
    /// 拖动内容视图时，item的字体是否根据拖动位置显示渐变效果，默认为true
    var isItemFontChangeFollowContentScroll: Bool { get }
    
}

extension SKSegmentedFollowContent {
    var isItemColorChangeFollowContentScroll: Bool { true }
    var isItemFontChangeFollowContentScroll: Bool { true }
}


public protocol SKSegmentedViewProtocol: SKSegmentedFollowContent {
    /**
     *  控制child view controller调用viewDidLoad方法的时机
     *  1. 值为true时，拖动内容视图，一旦拖动到该child view controller所在的位置，立即加载其view
     *  2. 值为false时，拖动内容视图，拖动到该child view controller所在的位置，不会立即其view，而是要等到手势结束，scrollView停止滚动后，再加载其view
     *  3. 默认值为false
     */
    var loadViewOfChildContollerWhileAppear: Bool { get }
}

extension SKSegmentedViewProtocol {
    var loadViewOfChildContollerWhileAppear: Bool { false }
}


/// SegmentedView的代理
@objc protocol SKSegmentedViewDelegate {
    
    /// 将要切换到index
    @objc optional func segmentedView(_ segmentedView: SKSegmentedView, willSelectItem index: Int)
    
    /// 已经切换到index
    @objc optional func segmentedView(_ segmentedView: SKSegmentedView, didSelectedItem index: Int)
    
    /// 选中的item双击
    @objc optional func segmentedView(_ segmentedView: SKSegmentedView, selectedItemDoubleTap index: Int)
    
}

/// menuView的代理
@objc protocol SKSegmentedMenuViewDelegate {
    
    /// 将要切换到index
    @objc optional func segmentedMenuView(_ segmentedView: SKSegmentedMenuView, willSelectItem index: Int)
    
    /// 已经切换到index
    @objc optional func segmentedMenuView(_ segmentedView: SKSegmentedMenuView, didSelectedItem index: Int)
    
    /// 选中的item双击
    @objc optional func segmentedMenuView(_ segmentedView: SKSegmentedMenuView, selectedItemDoubleTap index: Int)
    
}


