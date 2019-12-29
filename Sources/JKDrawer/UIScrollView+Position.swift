//
//  UIScrollView+Position.swift
//  
//
//  Created by Johan Kool on 22/12/2019.
//

import UIKit

extension UIScrollView {

    var isAtTop: Bool {
        return contentOffset.y <= verticalOffsetForTop
    }

    var isAtBottom: Bool {
        return contentOffset.y >= verticalOffsetForBottom
    }

    var verticalOffsetForTop: CGFloat {
        let topInset = contentInset.top
        return -topInset
    }

    var verticalOffsetForBottom: CGFloat {
        let scrollViewHeight = bounds.height
        let scrollContentSizeHeight = contentSize.height
        let bottomInset = contentInset.bottom
        let scrollViewBottomOffset = scrollContentSizeHeight + bottomInset - scrollViewHeight
        return scrollViewBottomOffset
    }
    
    var isAtLeft: Bool {
        return contentOffset.y <= horizontalOffsetForLeft
    }
    
    var isAtRight: Bool {
        return contentOffset.y >= horizontalOffsetForRight
    }
    
    var horizontalOffsetForLeft: CGFloat {
        let leftInset = contentInset.left
        return -leftInset
    }
    
    var horizontalOffsetForRight: CGFloat {
        let scrollViewWidth = bounds.width
        let scrollContentSizeWidth = contentSize.width
        let rightInset = contentInset.right
        let scrollViewRightOffset = scrollContentSizeWidth + rightInset - scrollViewWidth
        return scrollViewRightOffset
    }
    
}
