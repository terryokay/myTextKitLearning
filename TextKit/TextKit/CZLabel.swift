//
//  CZLabel.swift
//  TextKit
//
//  Created by hu yr on 2017/2/13.
//  Copyright © 2017年 terry. All rights reserved.
//

import UIKit
/**
    1.使用TextKit 接管 Label 的底层实现
    2.使用正则表达式过滤 URL
    3.交互
 
 - UILabel 默认不能实现垂直顶部对齐,使用TextKit 可以
 
 在iOS7.0 之前,要实现类似的效果,需要使用CoreText 使用其阿里异常 的繁琐
 */
class CZLabel: UILabel {
    
    //MARK: - 重写属性 - 进一步体会 TextKit接管底层的实现
    // 一旦内容变化,需要让textStorage相应变化
    override var text: String?{
        didSet{
            //重新准备文本内容
            prepareTextContent()
        }
    }
    
    
    //MARK: - 构造函数
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        prepareTextSystem()
    
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        prepareTextSystem()
    }
    
    //MARK : - 交互
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        //1.获取用户点击的位置
        guard let location = touches.first?.location(in: self) else{
            return
        }
        
        //2.获取当前点中字符的索引
        let idx = layoutManager.glyphIndex(for: location, in: textContainer)
        
        //3.判断 idx 是否在 urls 的ranges的范围内. 如果在,就高亮
        for r in urlRanges ?? []{
            
            if NSLocationInRange(idx, r){
                
                textStorage.addAttributes([NSForegroundColorAttributeName:UIColor.blue], range: r)
                
                //如果需要重绘,需要调用一个函数,但是不是 drawRect
                setNeedsDisplay()
                
                
            }else{
                print("没戳着")
            }
            
            
            
        }
        
        
        
        
    }
    
    /**
     在 iOS中绘制工作是类似于油画似的,后绘制的内容,会把之前绘制的内容覆盖!
     尽量避免使用带透明度的颜色,会严重影响性能!
     */
    
    override func drawText(in rect: CGRect) {
//        super.drawText(in: rect)
        
        let range = NSRange(location: 0, length: textStorage.length)
        
        layoutManager.drawBackground(forGlyphRange: range, at: CGPoint())
        
        layoutManager.drawGlyphs(forGlyphRange: range, at: CGPoint())
    }
    
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        
        //指定绘制文本的区域
        textContainer.size = bounds.size
        
    }

   // MARK: --TextKit 的核心对象
    /// 属性文本存储
    fileprivate lazy var textStorage = NSTextStorage()
    
    /// 负责'文本'布局
    fileprivate lazy var layoutManager = NSLayoutManager()
    
    /// 设定文本绘制的范围
    fileprivate lazy var textContainer = NSTextContainer()

}

// MARK: - 设置TextKit 核心对象
fileprivate extension CZLabel{
    
    /// 准备文本系统
    func prepareTextSystem(){
        
        isUserInteractionEnabled = true
        
        
        //1.准备文本内容
        prepareTextContent()
        
        //2.设置对象的关系
        textStorage.addLayoutManager(layoutManager)
        layoutManager.addTextContainer(textContainer)
        
        
        
        
    }
    
    /// 准备文本内容 - 使用 textStorage 接管label的内容
    func prepareTextContent(){
    
        if let attributedStr = attributedText {
            textStorage.setAttributedString(attributedStr)
        }else if let text = text{
            textStorage.setAttributedString(NSAttributedString(string: text))
        }else{
            
            textStorage.setAttributedString(NSAttributedString(string: ""))
        }
        
        //遍历 范围数组,设置URL文字的属性
        for r in urlRanges ?? []{
            
            textStorage.addAttributes([NSForegroundColorAttributeName: UIColor.red,NSBackgroundColorAttributeName : UIColor.darkText], range: r)
        }
    }
    
}

// MARK: - 正则表达式函数
fileprivate extension CZLabel{
    
    /// 返回 textStorage 中的URL range数组
    var urlRanges:[NSRange]?{
        
        //1.正则表达式
        let pattern = "[a-zA-Z]*://[a-zA-Z0-9/\\.]*"
        
        guard let regx = try? NSRegularExpression(pattern: pattern, options: []) else{
            
            return nil
        }
        
        //2.多重匹配
        let matches = regx.matches(in: textStorage.string, options: [], range: NSRange(location: 0, length: textStorage.length))
        
        
        //3.遍历数组,生成range的数组
        var ranges = [NSRange]()
        
        for m in matches{
            ranges.append(m.rangeAt(0))
        }
        
        return ranges
    }
    
}
