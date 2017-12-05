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
            self.backgroundView = [UIView new];
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
        
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.tag = 1001;
        [view addSubview:imageView];
        
        UILabel *label = [[UILabel alloc] init];
        label.tag = 1002;
        label.text = @"点击刷新";
        label.font = [UIFont systemFontOfSize:11];
        label.textAlignment = NSTextAlignmentCenter;
        [view addSubview:label];
        
        [self layoutDefaultView:view];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDeviceOrientationChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
        
        view;
    });
    
    return self.defaultNoDataView;
}

- (void)layoutDefaultView:(UIView *)defaultView {
    
    UIImageView *imageView = [defaultView viewWithTag:1001];
    
    UIImage *image = [UIImage imageNamed:@"TableViewNoData"];
    imageView.image = image;
    CGFloat X = (self.bounds.size.width - image.size.width) / 2;
    CGFloat Y = (self.bounds.size.height - image.size.height) / 2 - 20;
    imageView.frame = CGRectMake(X, Y, image.size.width, image.size.height);
    
    UILabel *label = [defaultView viewWithTag:1002];
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
    return [objc_getAssociatedObject(self, _cmd) boolValue] ? : YES;
}

- (void)setDefaultNoDataViewDidClickBlock:(void (^)(UIView *))defaultNoDataViewDidClickBlock {
    objc_setAssociatedObject(self, @selector(defaultNoDataViewDidClickBlock), defaultNoDataViewDidClickBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void (^)(UIView *))defaultNoDataViewDidClickBlock {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setCustomNoDataView:(UIView *)customNoDataView {
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

@end
