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
/// 默认的无数据提示 View 的点击回调
@property (nonatomic, copy) void(^defaultNoDataViewClickActionBlock)(UIView *view);
/// 自定义无数据提示View
@property (nonatomic, strong) UIView *customNoDataView;

@end
