//
//  UITableView+AddForPlaceholder.h
//  TableViewPlaceholder
//
//  Created by TengShuQiang on 2017/12/4.
//  Copyright © 2017年 TTeng. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UITableView (AddForPlaceholder)

/**
 默认的无数据提示 View 的点击回调
 @note 用这个 block 的时候注意在 block “内部”使用weak，不然会导致循环引用
 */
@property (nonatomic, copy) void(^defaultNoDataViewDidClickBlock)(UIView *view);
/// 设置默认的提示文字
@property (nonatomic, copy) NSString *defaultNoDataText;
/// 设置默认的提示图片
@property (nonatomic, strong) UIImage *defaultNoDataImage;
/// 自定义无数据提示View
@property (nonatomic, strong) UIView *customNoDataView;
@end
