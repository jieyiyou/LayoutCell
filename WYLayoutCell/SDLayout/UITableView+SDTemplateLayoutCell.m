//
//  UITableView+SDTemplateLayoutCell.m
//  WYLayoutCell
//
//  Created by 薇谙 on 2018/7/27.
//  Copyright © 2018年 WY. All rights reserved.
//

#import "UITableView+SDTemplateLayoutCell.h"
#import "UITableView+SDIndexPathHeightCache.h"
#import <objc/runtime.h>

@implementation UITableView (SDTemplateLayoutCell)

- (CGFloat)sd_systemFittingHeightForConfiguratedCell:(UITableViewCell *)cell {
    CGFloat contentViewWidth = CGRectGetWidth(self.frame);
    
    // If a cell has accessory view or system accessory type, its content view's width is smaller
    // than cell's by some fixed values.
    if (cell.accessoryView) {
        contentViewWidth -= 16 + CGRectGetWidth(cell.accessoryView.frame);
    } else {
        static const CGFloat systemAccessoryWidths[] = {
            [UITableViewCellAccessoryNone] = 0,
            [UITableViewCellAccessoryDisclosureIndicator] = 34,
            [UITableViewCellAccessoryDetailDisclosureButton] = 68,
            [UITableViewCellAccessoryCheckmark] = 40,
            [UITableViewCellAccessoryDetailButton] = 48
        };
        contentViewWidth -= systemAccessoryWidths[cell.accessoryType];
    }
    
    CGFloat fittingHeight = 0;
        // Try '- sizeThatFits:' for frame layout.
        // Note: fitting height should not include separator view.
        fittingHeight = [cell sizeThatFits:CGSizeMake(contentViewWidth, 0)].height;
//    }
    
    // Still zero height after all above.
    if (fittingHeight == 0) {
        // Use default row height.
        fittingHeight = 44;
    }
    
    // Add 1px extra space for separator line if needed, simulating default UITableViewCell.
    if (self.separatorStyle != UITableViewCellSeparatorStyleNone) {
        fittingHeight += 1.0 / [UIScreen mainScreen].scale;
    }
    
    return fittingHeight;
}

- (__kindof UITableViewCell *)sd_templateCellForReuseIdentifier:(NSString *)identifier {
    NSAssert(identifier.length > 0, @"Expect a valid identifier - %@", identifier);
    
    NSMutableDictionary<NSString *, UITableViewCell *> *templateCellsByIdentifiers = objc_getAssociatedObject(self, _cmd);
    if (!templateCellsByIdentifiers) {
        templateCellsByIdentifiers = @{}.mutableCopy;
        objc_setAssociatedObject(self, _cmd, templateCellsByIdentifiers, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    UITableViewCell *templateCell = templateCellsByIdentifiers[identifier];
    
    if (!templateCell) {
        templateCell = [self dequeueReusableCellWithIdentifier:identifier];
        NSAssert(templateCell != nil, @"Cell must be registered to table view for identifier - %@", identifier);
        templateCell.sd_isTemplateLayoutCell = YES;
        templateCell.contentView.translatesAutoresizingMaskIntoConstraints = NO;
        templateCellsByIdentifiers[identifier] = templateCell;
    }
    
    return templateCell;
}

- (CGFloat)sd_heightForCellWithIdentifier:(NSString *)identifier configuration:(void (^)(id cell))configuration {
    if (!identifier) {
        return 0;
    }
    
    UITableViewCell *templateLayoutCell = [self sd_templateCellForReuseIdentifier:identifier];
    
    // Manually calls to ensure consistent behavior with actual cells. (that are displayed on screen)
    [templateLayoutCell prepareForReuse];
    
    // Customize and provide content for our template cell.
    if (configuration) {
        configuration(templateLayoutCell);
    }
    
    return [self sd_systemFittingHeightForConfiguratedCell:templateLayoutCell];
}

- (CGFloat)sd_heightForCellWithIdentifier:(NSString *)identifier cacheByIndexPath:(NSIndexPath *)indexPath configuration:(void (^)(id cell))configuration {
    if (!identifier || !indexPath) {
        return 0;
    }
    
    // Hit cache
    if ([self.sd_indexPathHeightCache existsHeightAtIndexPath:indexPath]) {
        return [self.sd_indexPathHeightCache heightForIndexPath:indexPath];
    }
    
    CGFloat height = [self sd_heightForCellWithIdentifier:identifier configuration:configuration];
    [self.sd_indexPathHeightCache cacheHeight:height byIndexPath:indexPath];
    
    return height;
}

@end

@implementation UITableView (SDTemplateLayoutHeaderFooterView)

- (__kindof UITableViewHeaderFooterView *)sd_templateHeaderFooterViewForReuseIdentifier:(NSString *)identifier {
    NSAssert(identifier.length > 0, @"Expect a valid identifier - %@", identifier);
    
    NSMutableDictionary<NSString *, UITableViewHeaderFooterView *> *templateHeaderFooterViews = objc_getAssociatedObject(self, _cmd);
    if (!templateHeaderFooterViews) {
        templateHeaderFooterViews = @{}.mutableCopy;
        objc_setAssociatedObject(self, _cmd, templateHeaderFooterViews, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    UITableViewHeaderFooterView *templateHeaderFooterView = templateHeaderFooterViews[identifier];
    
    if (!templateHeaderFooterView) {
        templateHeaderFooterView = [self dequeueReusableHeaderFooterViewWithIdentifier:identifier];
        NSAssert(templateHeaderFooterView != nil, @"HeaderFooterView must be registered to table view for identifier - %@", identifier);
        templateHeaderFooterView.contentView.translatesAutoresizingMaskIntoConstraints = NO;
        templateHeaderFooterViews[identifier] = templateHeaderFooterView;
    }
    
    return templateHeaderFooterView;
}

- (CGFloat)sd_heightForHeaderFooterViewWithIdentifier:(NSString *)identifier configuration:(void (^)(id))configuration {
    UITableViewHeaderFooterView *templateHeaderFooterView = [self sd_templateHeaderFooterViewForReuseIdentifier:identifier];
    
    NSLayoutConstraint *widthFenceConstraint = [NSLayoutConstraint constraintWithItem:templateHeaderFooterView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:CGRectGetWidth(self.frame)];
    [templateHeaderFooterView addConstraint:widthFenceConstraint];
    CGFloat fittingHeight = [templateHeaderFooterView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    [templateHeaderFooterView removeConstraint:widthFenceConstraint];
    
    if (fittingHeight == 0) {
        fittingHeight = [templateHeaderFooterView sizeThatFits:CGSizeMake(CGRectGetWidth(self.frame), 0)].height;
    }
    
    return fittingHeight;
}

@end

@implementation UITableViewCell (sdTemplateLayoutCell)

- (BOOL)sd_isTemplateLayoutCell {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setSd_isTemplateLayoutCell:(BOOL)isTemplateLayoutCell {
    objc_setAssociatedObject(self, @selector(sd_isTemplateLayoutCell), @(isTemplateLayoutCell), OBJC_ASSOCIATION_RETAIN);
}

- (BOOL)sd_enforceFrameLayout {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setSd_enforceFrameLayout:(BOOL)enforceFrameLayout {
    objc_setAssociatedObject(self, @selector(sd_enforceFrameLayout), @(enforceFrameLayout), OBJC_ASSOCIATION_RETAIN);
}

@end

