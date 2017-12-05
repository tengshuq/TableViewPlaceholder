//
//  UITableView+AddForPlaceholder.h
//  TableViewPlaceholder
//
//  Created by TengShuQiang on 2017/12/4.
//  Copyright © 2017年 TTeng. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UITableView (AddForPlaceholder)

/// 是否显示无数据时的提示，默认为YES
@property (nonatomic, assign) BOOL showNoDataNotice;
/**
 默认的无数据提示 View 的点击回调
 @note 用这个 block 的时候注意在 block “内部”使用weak，不然会导致循环引用
 */
@property (nonatomic, copy) void(^defaultNoDataViewDidClickBlock)(UIView *view);
/// 自定义无数据提示View
@property (nonatomic, strong) UIView *customNoDataView;
@end
