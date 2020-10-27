//
//  ViewController.swift
//  SegmentedViewDemo
//
//  Created by 李烁凯 on 2020/10/27.
//

import UIKit

struct Custom: SKSegmentedViewProtocol {
    var isItemFullWidth: Bool = true
//    var selectedColor: UIColor = .blue
    
//    var isItemColorChangeFollowContentScroll: Bool = false
    
    var itemSelectedBgViewInsets: UIEdgeInsets? = UIEdgeInsets.init(top: SKSegmentedView.menuViewHeight - 6, left: 0, bottom: 2, right: 0)
//    var itemSlelectdFixedWidth: Float = 35
//    var itemSelectedBgColor: UIColor? = UIColor.blue
    var itemSelectedBgImage: UIImage? = UIImage.init(named: "icon_line")
    
    var itemSelectedBgRadius: Float = 4
    
}

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "分段视图"
        
        setSegmentedView()
    }

    func setSegmentedView() {
        
        let navH = (self.navigationController?.navigationBar.frame.height ?? 0) + UIApplication.shared.statusBarFrame.height
        
        let segmentedView = SKSegmentedView.init(frame: CGRect.init(x: 0, y: navH, width: self.view.bounds.width, height: self.view.bounds.height - navH), segmentedViewProtocol: Custom.init())
        segmentedView.delegate = self
        let vc1 = NewViewController.init()
        vc1.view.backgroundColor = .red
        vc1.title = "全部"
        self.addChild(vc1)
        
        let vc2 = NewViewController.init()
        vc2.view.backgroundColor = .black
        vc2.title = "进行中"
        self.addChild(vc2)
        
        let vc3 = NewViewController.init()
        vc3.view.backgroundColor = .white
        vc3.title = "已完成"
        self.addChild(vc3)
        
        let vc4 = NewViewController.init()
        vc4.view.backgroundColor = .orange
        vc4.title = "故障"
        self.addChild(vc4)
        
        let vc5 = NewViewController.init()
        vc5.view.backgroundColor = .cyan
        vc5.title = "已取消"
        self.addChild(vc5)
        
        segmentedView.viewControllers = [vc1, vc2, vc3, vc4, vc5]
        segmentedView.defaultSelectedIndex = 2
        self.view.addSubview(segmentedView)

        let menuItem = SKSegmentedMenuItem.init(frame: CGRect.init(x: 0, y: 0, width: 40, height: 0), itemCustom: nil)
        menuItem.title = "测试"
        segmentedView.addOtherMenuItem(menuItem) { (_) in
            print("点击了右边的按钮")
        }
    }
}

/// SKSegmentedViewDelegate
extension ViewController: SKSegmentedViewDelegate{
    /// 将要切换到index
    func segmentedView(_ segmentedView: SKSegmentedView, willSelectItem index: Int){
        print("将要切换到\(index)")
    }
    
    /// 已经切换到index
    func segmentedView(_ segmentedView: SKSegmentedView, didSelectedItem index: Int){
        print("已经切换到\(index)")
    }
    
    /// 选中的item双击
    func segmentedView(_ segmentedView: SKSegmentedView, selectedItemDoubleTap index: Int){
        print("双击了\(index)")
    }
}

/// 子视图
class NewViewController: UIViewController {
    override func viewDidLoad() {
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.navigationController?.pushViewController(PopViewController(), animated: true)
    }
    
}


class PopViewController: UIViewController {
    override func viewDidLoad() {
        self.view.backgroundColor = .white
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    
}
