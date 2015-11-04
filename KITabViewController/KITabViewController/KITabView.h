//
//  KITabView.h
//  Kitalker
//
//  Created by 杨 烽 on 13-3-7.
//  
//

#import <UIKit/UIKit.h>
#import "KITabViewItem.h"

#define kTabViewDefaultHeight 49.0f

typedef enum {
    KITabViewPositionOfTop, //default
    KITabViewPositionOfBottom,
    KITabViewPositionOfLeft, //暂未实现
    KITabViewPositionOfRight//暂未实现
} KITabViewPosition;

@class KITabView;
@protocol KITabViewDelegate <NSObject>

- (CGFloat)heightForTabView:(KITabView *)tabView;
- (void)tabView:(KITabView *)tabView didSelectedIndex:(NSUInteger)selectedIndex;
- (void)tabView:(KITabView *)tabView didSelectedItem:(KITabViewItem *)selectedItem;

- (BOOL)tabView:(KITabView *)tabView willDeselectIndex:(NSUInteger)index;
- (BOOL)tabView:(KITabView *)tabView willSelectIndex:(NSUInteger)selectedIndex;

@end

@interface KITabView : UIView {
    id<KITabViewDelegate>   __weak _delegate;
    KITabViewPosition       _position;
    BOOL                    _autoLayout;
    UIScrollView            *_scrollView;
    NSMutableArray          *_tabViewItems;
    NSUInteger              _selectedIndex;
    KITabViewItem           *_selectedItem;
    KITabViewItem           *_selectedItem2;
    UIImageView             *_backgroundImageView;
    UIImageView             *_itemSelectedImgView;
    UIEdgeInsets            _itemSelectedImgViewMargin;
    UIView                  *_headerView;
    UIView                  *_footerView;
    NSUInteger              _numberOfItemsInPage;
}

@property (nonatomic, weak) id<KITabViewDelegate>     delegate;
@property (nonatomic, assign) BOOL                      autoLayout;
@property (nonatomic, readonly) UIScrollView            *scrollView;
@property (nonatomic, strong) NSMutableArray            *tabViewItems;
@property (nonatomic, assign) NSUInteger                selectedIndex;
@property (nonatomic, strong) KITabViewItem             *selectedItem;
@property (nonatomic, readonly) KITabViewItem           *selectedItem2;
@property (nonatomic, strong) UIView                    *headerView;
@property (nonatomic, strong) UIView                    *footerView;
@property (nonatomic, assign) NSUInteger                numberOfItemsInPage;
@property (nonatomic, assign) BOOL                      bounces;

- (id)initWithDelegate:(id<KITabViewDelegate>)delegate position:(KITabViewPosition)position;

- (void)setBackgroundImage:(UIImage *)image;

- (void)setItemSelectedImage:(UIImage *)image margin:(UIEdgeInsets)margin;

- (void)updateSelectedImageViewOffset:(CGPoint)offset;

- (CGFloat)height;

- (void)deselectIndex:(NSUInteger)index;

@end
