//
//  KITabView.m
//  Kitalker
//
//  Created by 杨 烽 on 13-3-7.
//  
//

#import "KITabView.h"

#define kTabViewDefaultBackgroundColor [UIColor blackColor]

@implementation KITabView
@synthesize delegate            = _delegate;
@synthesize autoLayout          = _autoLayout;
@synthesize scrollView          = _scrollView;
@synthesize tabViewItems        = _tabViewItems;
@synthesize selectedIndex       = _selectedIndex;
@synthesize selectedItem        = _selectedItem;
@synthesize selectedItem2       = _selectedItem2;
@synthesize headerView          = _headerView;
@synthesize footerView          = _footerView;
@synthesize numberOfItemsInPage = _numberOfItemsInPage;

- (id)initWithDelegate:(id<KITabViewDelegate>)delegate position:(KITabViewPosition)position {
    if (self = [super init]) {
        [self setDelegate:delegate];
        [self initFinished];
        _selectedIndex = NSNotFound;
        _position = position;
    }
    return self;
}

- (void)initFinished {
    _numberOfItemsInPage = 5;
    [self setBackgroundColor:kTabViewDefaultBackgroundColor];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self updateLayout];
}

- (void)setTabViewItems:(NSMutableArray *)tabViewItems {
    if (_tabViewItems != tabViewItems) {
        for (KITabViewItem *item in _tabViewItems) {
            [item removeTarget:self
                        action:@selector(setSelectedItem:)
              forControlEvents:UIControlEventTouchDown];
        }
        
        _tabViewItems = nil;
        _tabViewItems = tabViewItems;
        
        _selectedIndex = NSNotFound;
        _selectedItem = nil;
        _selectedItem2 = nil;
        
        [self setNeedsLayout];
    }
}

- (void)setHeaderView:(UIView *)headerView {
    if (_headerView != headerView) {
        [_headerView removeFromSuperview];
        _headerView = nil;
        _headerView = headerView;
        if (_headerView != nil && [_headerView isKindOfClass:[UIView class]]) {
            [self addSubview:_headerView];
        }
        [self setNeedsLayout];
    }
}

- (void)setFooterView:(UIView *)footerView {
    if (_footerView != footerView) {
        [_footerView removeFromSuperview];
        _footerView = nil;
        _footerView = footerView;
        if (_footerView != nil && [_footerView isKindOfClass:[UIView class]]) {
            [self addSubview:_footerView];
        }
        [self setNeedsLayout];
    }
}

- (void)updateLayout {
    
    CGRect headerViewFrame = [self headerView].frame;
    CGRect footerViewFrame = [self footerView].frame;
    
    CGFloat scrollViewWidth = CGRectGetWidth(self.bounds) - CGRectGetWidth(headerViewFrame) - CGRectGetWidth(footerViewFrame);
    CGFloat scrollViewHeight = CGRectGetHeight(self.bounds);
    CGFloat scrollViewX = CGRectGetWidth(headerViewFrame);
    CGFloat scrollViewY = 0;
    
    CGFloat itemCount = self.tabViewItems.count>_numberOfItemsInPage?_numberOfItemsInPage:self.tabViewItems.count;
    CGFloat itemX = 0;
    CGFloat itemWidth = scrollViewWidth / itemCount;
    
    KITabViewItem *lastItem = nil;
    
    NSInteger count = self.tabViewItems.count;
    
    for (int i=0; i<count; i++) {
        KITabViewItem *item = [self.tabViewItems objectAtIndex:i];
        
        [item setIndex:i];
        
        [item addTarget:self
                 action:@selector(setSelectedItem:)
       forControlEvents:UIControlEventTouchUpInside];
        
        [[self scrollView] addSubview:item];
        
        if (self.autoLayout) {
            itemX = i*itemWidth;
            [item setFrame:CGRectMake(itemX, 0, itemWidth, [self height])];
        }
        
        if (i == self.tabViewItems.count-1) {
            lastItem = item;
        }
    }
    
    CGSize contentSize = CGSizeMake(CGRectGetMaxX(lastItem.frame),
                                    [self height]);
    [[self scrollView] setFrame:CGRectMake(scrollViewX, scrollViewY, scrollViewWidth, scrollViewHeight)];
    [[self scrollView] setContentSize:contentSize];
    
    if (_selectedItem) {
        [self updateItemSelectedImgViewFrame:_selectedItem.frame];
    }
    
    if ([self headerView]) {
        [[self headerView] setFrame:CGRectMake(0,
                                               0,
                                               CGRectGetWidth(headerViewFrame),
                                               CGRectGetHeight(headerViewFrame))];
        [[self scrollView] setClipsToBounds:YES];
    } else {
        [[self scrollView] setClipsToBounds:NO];
    }
    
    if ([self footerView]) {
        [[self footerView] setFrame:CGRectMake(CGRectGetMaxX([self scrollView].frame),
                                               0,
                                               CGRectGetWidth(footerViewFrame),
                                               CGRectGetHeight(footerViewFrame))];
        [[self scrollView] setClipsToBounds:YES];
    } else {
        [[self scrollView] setClipsToBounds:NO];
    }
}

- (UIScrollView *)scrollView {
    if (_scrollView == nil) {
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        [_scrollView setBounces:NO];
        [_scrollView setShowsHorizontalScrollIndicator:NO];
        [_scrollView setShowsVerticalScrollIndicator:NO];
        [_scrollView setCanCancelContentTouches:NO];
        [_scrollView setClipsToBounds:NO];
        [_scrollView setBackgroundColor:[UIColor clearColor]];
        [self addSubview:_scrollView];
    }
    return _scrollView;
}

- (void)setBounces:(BOOL)bounces {
    _bounces = bounces;
    [self.scrollView setBounces:_bounces];
}

- (UIImageView *)backgroundImageView {
    if (_backgroundImageView == nil) {
        _backgroundImageView= [[UIImageView alloc] init];
        [_backgroundImageView setContentMode:UIViewContentModeScaleToFill];
        [self addSubview:_backgroundImageView];
    }
    [self sendSubviewToBack:_backgroundImageView];
    return _backgroundImageView;
}

- (void)setBackgroundImage:(UIImage *)image {
    [self setBackgroundColor:[UIColor clearColor]];
    [[self backgroundImageView] setBackgroundColor:[UIColor clearColor]];
    [[self backgroundImageView] setImage:image];
    [[self backgroundImageView] setFrame:self.bounds];
    /*
    CGFloat y = 0;
    CGFloat height = CGRectGetHeight(self.bounds);
    switch (_position) {
        case KITabViewPositionOfTop: {
            y = 0;
            height = image.size.height;
        }
            break;
        case KITabViewPositionOfBottom: {
            if (height < image.size.height) {
                y = height - image.size.height;
                height = image.size.height;
            }
        }
            
        default:
            break;
    }
    
    [[self backgroundImageView] setFrame:CGRectMake(0,
                                                    y,
                                                    CGRectGetWidth(self.bounds),
                                                    height)];
//    UIColor *color = [UIColor colorWithPatternImage:image];
//    [self setBackgroundColor:color];
     */
}

- (UIImageView *)itemSelectedImgView {
    if (_itemSelectedImgView == nil) {
        _itemSelectedImgView = [[UIImageView alloc] init];
        [_itemSelectedImgView setContentMode:UIViewContentModeScaleToFill];
        [[self scrollView] addSubview:_itemSelectedImgView];
    }
//    [self insertSubview:_itemSelectedImgView belowSubview:[self backgroundImageView]];
    return _itemSelectedImgView;
}

- (void)setItemSelectedImage:(UIImage *)image margin:(UIEdgeInsets)margin {
    [[self itemSelectedImgView] setImage:image];
    _itemSelectedImgViewMargin = margin;
}

- (void)updateSelectedImageViewOffset:(CGPoint)offset {
    CGRect frame = [[self itemSelectedImgView] frame];
    frame.origin.x = offset.x;
    
    frame.origin.y = frame.origin.y - -_itemSelectedImgViewMargin.top;
    frame.size.height = frame.size.height - _itemSelectedImgViewMargin.top - _itemSelectedImgViewMargin.bottom;
    
    frame.origin.x = frame.origin.x - -_itemSelectedImgViewMargin.left;
    frame.size.width = frame.size.width - _itemSelectedImgViewMargin.left - _itemSelectedImgViewMargin.right;
    
    [[self itemSelectedImgView] setFrame:frame];
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex {
    if ([[self tabViewItems] count] <= selectedIndex) {
        return;
    }
    if (_selectedIndex != selectedIndex) {
        _selectedIndex = selectedIndex;
        KITabViewItem *item = [[self tabViewItems] objectAtIndex:_selectedIndex];
        [self setSelectedItem:item];
    }
}

- (void)setSelectedItem:(KITabViewItem *)selectedItem {
    [self setSelectedItem:selectedItem force:YES];
}

- (void)setSelectedItem:(KITabViewItem *)selectedItem force:(BOOL)force {
    /*if (selectedItem.viewController == nil) {
     if (self.delegate != nil) {
     if ([self.delegate respondsToSelector:@selector(tabView:didSelectedItem:)]) {
     [self.delegate tabView:self didSelectedItem:selectedItem];
     }
     
     if ([self.delegate respondsToSelector:@selector(tabView:didSelectedIndex:)]) {
     [self.delegate tabView:self didSelectedIndex:selectedItem.index];
     }
     }
     } else*/
    
    if (force && self.delegate != nil) {
        if ([self.delegate respondsToSelector:@selector(tabViewController:willDeselectedIndex:)]) {
            if (![self.delegate tabView:self willDeselectIndex:_selectedItem.index]) {
                return ;
            }
        }
    }
    
    if (!selectedItem.deselectable) {
        /*
         记录上一不可取消选中项
         */
        _selectedItem2 = nil;
        _selectedItem2 = selectedItem;
    }
    
    if (selectedItem.deselectable && selectedItem == _selectedItem) {
        /*
         如果需要选中项deselectable为YES，并且刚好等于当前选中的项，则取消选中当前项
         */
        [_selectedItem setSelected:NO];
        _selectedItem = _selectedItem2;
        [_selectedItem setSelected:YES];
        _selectedIndex = [[self tabViewItems] indexOfObject:_selectedItem];
    } else if (_selectedItem != selectedItem) {
        if (force && self.delegate != nil) {
            if ([self.delegate respondsToSelector:@selector(tabView:willSelectIndex:)]) {
                if (![self.delegate tabView:self willSelectIndex:selectedItem.index]) {
                    return ;
                }
            }
        }
        
        [_selectedItem setSelected:NO];
        _selectedItem = selectedItem;
        [_selectedItem setSelected:YES];
        _selectedIndex = [[self tabViewItems] indexOfObject:_selectedItem];
        
        [self updateItemSelectedImgViewFrame:_selectedItem.frame];
        
        if (force && self.delegate != nil) {
            if ([self.delegate respondsToSelector:@selector(tabView:didSelectedItem:)]) {
                [self.delegate tabView:self didSelectedItem:_selectedItem];
            }
            
            if ([self.delegate respondsToSelector:@selector(tabView:didSelectedIndex:)]) {
                [self.delegate tabView:self didSelectedIndex:_selectedIndex];
            }
        }
    }
    
//    if (!CGRectContainsPoint(selectedItem.frame, self.scrollView.contentOffset)) {
//        [self.scrollView scrollRectToVisible:selectedItem.frame animated:YES];
//    }
}

- (void)updateItemSelectedImgViewFrame:(CGRect)newFrame {
    if (_itemSelectedImgView) {
        CGRect oldFrame = [[self itemSelectedImgView] frame];
        if (CGRectEqualToRect(oldFrame, CGRectZero)) {
            oldFrame.size = newFrame.size;
            [[self itemSelectedImgView] setFrame:oldFrame];
        }
        
        [self.scrollView scrollRectToVisible:newFrame animated:YES];
        
        [UIView animateWithDuration:.2 animations:^{
            
            CGRect frame = newFrame;
            
            frame.origin.y = frame.origin.y - -_itemSelectedImgViewMargin.top;
            frame.size.height = frame.size.height - _itemSelectedImgViewMargin.top - _itemSelectedImgViewMargin.bottom;
            
            frame.origin.x = frame.origin.x - -_itemSelectedImgViewMargin.left;
            frame.size.width = frame.size.width - _itemSelectedImgViewMargin.left - _itemSelectedImgViewMargin.right;
            
            [[self itemSelectedImgView] setFrame:frame];
        }];
    }
}

- (void)deselectIndex:(NSUInteger)index {
    if (_selectedIndex == index) {
        KITabViewItem *item = [[self tabViewItems] objectAtIndex:_selectedIndex];
        if (item.deselectable) {
            [self setSelectedItem:item];
        }
    }
}

- (CGFloat)height {
    if (self.delegate != nil) {
        if ([self.delegate respondsToSelector:@selector(heightForTabView:)]) {
            return [self.delegate heightForTabView:self];
        }
    }
    return kTabViewDefaultHeight;
}

- (void)dealloc {
    _scrollView = nil;
    _tabViewItems = nil;
    _selectedItem = nil;
    _selectedItem2 = nil;
    _backgroundImageView = nil;
    _itemSelectedImgView = nil;
    [_headerView removeFromSuperview];
    _headerView = nil;
    [_footerView removeFromSuperview];
    _footerView = nil;
    [self setDelegate:nil];
}

@end
