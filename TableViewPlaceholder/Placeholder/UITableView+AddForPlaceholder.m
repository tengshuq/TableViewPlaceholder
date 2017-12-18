//
//  UITableView+AddForPlaceholder.m
//  TableViewPlaceholder
//
//  Created by TengShuQiang on 2017/12/4.
//  Copyright © 2017年 TTeng. All rights reserved.
//

#import "UITableView+AddForPlaceholder.h"
#import <objc/runtime.h>

@implementation UITableView (AddForPlaceholder)


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

void swizzMethod(SEL oriSel, SEL newSel) {
    
    Class class = [UITableView class];
    Method oriMethod = class_getInstanceMethod(class, oriSel);
    Method newMethod = class_getInstanceMethod(class, newSel);
    
    BOOL success = class_addMethod(class, oriSel, method_getImplementation(newMethod), method_getTypeEncoding(newMethod));
    if (success) {
        class_replaceMethod(class, newSel, method_getImplementation(oriMethod), method_getTypeEncoding(oriMethod));
    } else {
        method_exchangeImplementations(oriMethod, newMethod);
    }
}

+ (void)load {
    SEL selectors[] = {
        @selector(reloadData),
        @selector(insertSections:withRowAnimation:),
        @selector(deleteSections:withRowAnimation:),
        @selector(reloadSections:withRowAnimation:),
        @selector(insertRowsAtIndexPaths:withRowAnimation:),
        @selector(deleteRowsAtIndexPaths:withRowAnimation:),
        @selector(reloadRowsAtIndexPaths:withRowAnimation:),
    };
    
    for (NSUInteger index = 0; index < sizeof(selectors) / sizeof(SEL); ++index) {
        SEL originalSelector = selectors[index];
        SEL swizzledSelector = NSSelectorFromString([@"tt_" stringByAppendingString:NSStringFromSelector(originalSelector)]);
        swizzMethod(originalSelector, swizzledSelector);
    }
}

- (void)tt_reloadData {
    [self showPlaceholderNotice];
    [self tt_reloadData];
}

- (void)tt_insertSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation {
    [self showPlaceholderNotice];
    [self tt_insertSections:sections withRowAnimation:animation];
}

- (void)tt_deleteSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation {
    [self showPlaceholderNotice];
    [self tt_deleteSections:sections withRowAnimation:animation];
}

- (void)tt_reloadSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation {
    [self showPlaceholderNotice];
    [self tt_reloadSections:sections withRowAnimation:animation];
}

- (void)tt_insertRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation {
    [self showPlaceholderNotice];
    [self tt_insertRowsAtIndexPaths:indexPaths withRowAnimation:animation];
}

- (void)tt_deleteRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation {
    [self showPlaceholderNotice];
    [self tt_deleteRowsAtIndexPaths:indexPaths withRowAnimation:animation];
}

- (void)tt_reloadRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation {
    [self showPlaceholderNotice];
    [self tt_reloadRowsAtIndexPaths:indexPaths withRowAnimation:animation];
}

- (void)showPlaceholderNotice {
    if (self.showNoDataNotice) {
        NSInteger sectionCount = self.numberOfSections;
        NSInteger rowCount = 0;
        for (int i = 0; i < sectionCount; i++) {
            rowCount += [self.dataSource tableView:self numberOfRowsInSection:i];
        }
        if (rowCount == 0) {
            if (self.customNoDataView) {
                self.backgroundView = [self customNoDataView];
            } else
                self.backgroundView = [self tt_defaultNoDataView];
        } else {
            self.backgroundView = [[UIView alloc] init];
        }
    }
}

- (UIView *)tt_defaultNoDataView {
    
    if (self.defaultNoDataView) {
        return self.defaultNoDataView;
    }
    self.defaultNoDataView = ({
        UIView *view = [[UIView alloc] initWithFrame:self.bounds];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tt_tapDefalutNoDataView:)];
        [view addGestureRecognizer:tap];
        
        [view addSubview:self.defaultNoDataNoticeImageView];
        [view addSubview:self.defaultNoDataNoticeLabel];
        
        [self layoutDefaultView:view];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDeviceOrientationChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
        
        view;
    });
    
    return self.defaultNoDataView;
}

- (void)layoutDefaultView:(UIView *)defaultView {
    
    UIImageView *imageView = self.defaultNoDataNoticeImageView;
    UIImage *image = self.defaultNoDataImage ? : [UIImage imageNamed:@"UITableViewPlaceholder.bundle/TableViewNoData"];
    imageView.image = image;
    CGFloat X = (self.bounds.size.width - image.size.width - self.contentInset.left - self.contentInset.right) / 2;
    CGFloat Y = (self.bounds.size.height - image.size.height - self.contentInset.top - self.contentInset.bottom) / 2 - 20;
    imageView.frame = CGRectMake(X, Y, image.size.width, image.size.height);
    
    // 提示语不用太长，不考虑换行的情况，也不计算文字的宽高了
    UILabel *label = self.defaultNoDataNoticeLabel;
    label.text = self.defaultNoDataText ? : label.text;
    label.frame = CGRectMake(0, imageView.frame.origin.y + imageView.bounds.size.height + 10, self.bounds.size.width, 30);
}

- (void)tt_tapDefalutNoDataView:(UITapGestureRecognizer *)tap {
    
    self.defaultNoDataViewDidClickBlock ? self.defaultNoDataViewDidClickBlock(self.defaultNoDataView) : nil;
}

#pragma mark - notifications
- (void)onDeviceOrientationChange:(NSNotification *)noti {
    if (self.customNoDataView || !self.showNoDataNotice) {
        return;
    }
    [self layoutDefaultView:self.defaultNoDataView];
}


#pragma mark - setter && getter
- (void)setShowNoDataNotice:(BOOL)showNoDataNotice {
    objc_setAssociatedObject(self, @selector(showNoDataNotice), @(showNoDataNotice), OBJC_ASSOCIATION_ASSIGN);
}

- (BOOL)showNoDataNotice {
    return objc_getAssociatedObject(self, _cmd) == nil ? YES : [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setDefaultNoDataViewDidClickBlock:(void (^)(UIView *))defaultNoDataViewDidClickBlock {
    self.showNoDataNotice = YES;
    objc_setAssociatedObject(self, @selector(defaultNoDataViewDidClickBlock), defaultNoDataViewDidClickBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void (^)(UIView *))defaultNoDataViewDidClickBlock {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setCustomNoDataView:(UIView *)customNoDataView {
    self.showNoDataNotice = YES;
    objc_setAssociatedObject(self, @selector(customNoDataView), customNoDataView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIView *)customNoDataView {
    return objc_getAssociatedObject(self, _cmd);
}

- (UIView *)defaultNoDataView {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setDefaultNoDataView:(UIView *)defaultNoDataView {
    objc_setAssociatedObject(self, @selector(defaultNoDataView), defaultNoDataView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

// 默认的label
- (UILabel *)defaultNoDataNoticeLabel {
    UILabel *label = objc_getAssociatedObject(self, _cmd);
    if (!label) {
        label = [[UILabel alloc] init];
        label.text = self.defaultNoDataText ? : @"暂无数据,点击刷新";
        label.font = [UIFont systemFontOfSize:11];
        label.textAlignment = NSTextAlignmentCenter;
        objc_setAssociatedObject(self, _cmd, label, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return label;
}

// 默认的imageView
- (UIImageView *)defaultNoDataNoticeImageView {
    UIImageView *imageView = objc_getAssociatedObject(self, _cmd);
    if (!imageView) {
        imageView = [[UIImageView alloc] init];
        imageView.image = self.defaultNoDataImage ? : [UIImage imageNamed:@"UITableViewPlaceholder.bundle/TableViewNoData"];
        imageView.contentMode = UIViewContentModeCenter;
        objc_setAssociatedObject(self, _cmd, imageView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return imageView;
}

- (NSString *)defaultNoDataText {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setDefaultNoDataText:(NSString *)defaultNoticeText {
    objc_setAssociatedObject(self, @selector(defaultNoDataText), defaultNoticeText, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (UIImage *)defaultNoDataImage {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setDefaultNoDataImage:(UIImage *)defaultNoticeImage {
    objc_setAssociatedObject(self, @selector(defaultNoDataImage), defaultNoticeImage, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
