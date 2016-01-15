//
//  RectView.swift
//  YTBandwagonhost
//
//  Created by hwh on 16/1/13.
//  Copyright © 2016年 油条. All rights reserved.
//

import UIKit

class RectView: UIView {
    var progress: Double = 0 {
        didSet {
            layoutIfNeeded()
        }
    }
    var backColor: UIColor = UIColor.whiteColor() {
        didSet {
            backgroundColor = backColor
        }
    }
    var progressColor: UIColor = UIColor(white: 0.8, alpha: 0.8) {
        didSet {
            layoutIfNeeded()
        }
    }
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {        
        let height = rect.size.height * CGFloat(progress)
        let context = UIGraphicsGetCurrentContext()
        CGContextSetFillColorWithColor(context, progressColor.CGColor)
        CGContextAddRect(context, CGRectMake(0, rect.size.height - height, rect.size.width, height))
        CGContextFillPath(context)
    }
}
