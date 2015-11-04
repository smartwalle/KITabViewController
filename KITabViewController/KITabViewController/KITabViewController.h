//
//  KITabViewController.h
//  Kitalker
//
//  Created by 杨 烽 on 13-3-7.
//  
//

/*
 KITabViewController *tvc = [[KITabViewController alloc] initWithPosition:KITabViewPositionOfBottom autoLayout:NO];
 [tvc setDelegate:self];
 
 [tvc.view setFrame:CGRectMake(0, 0, 320, 400)];
 [self.view addSubview:tvc.view];
 
 NSMutableArray *items = [[NSMutableArray alloc] init];
 
 for (int i=0; i<5; i++) {
 ViewController1 *vc1 = [[ViewController1 alloc] initWithNibName:@"ViewController1" bundle:nil];
 UINavigationController *nv = [[UINavigationController alloc] initWithRootViewController:vc1];
 [vc1 release];
 KITabViewItem *item = nil;
 
 if (i==2) {
 item = [[KITabViewItem alloc] initWithViewController:nil];
 [item setFrame:CGRectMake(i*64, 49-60, 64, 60)];
 
 } else {
 item = [[KITabViewItem alloc] initWithViewController:nv];
 [item setFrame:CGRectMake(i*64, 0, 64, 49)];
 
 }
 
 [nv release];
 
 [items addObject:item];
 [item release];
 }
 
 [tvc setTabViewItems:items];
 [items release];
 
 [tvc setSelectedIndex:1];
 */

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "KITabView.h"

typedef enum {
    KITabViewTransitionNormal,
    KITabViewTransitionFade,
    KITabViewTransitionPush
} KITabViewTransition;

@protocol KITabViewControllerDelegate;
@interface KITabViewController : UIViewController <KITabViewDelegate> {
    id<KITabViewControllerDelegate> __weak _delegate;
    BOOL                            _autoLayout;
    KITabView                       *_tabView;
    BOOL                            _tabViewHidden;
    UIScrollView                    *_containerView;
    KITabViewPosition               _position;
    NSUInteger                      _selectedIndex;
    KITabViewItem                   *_selectedItem;
    UIViewController                *_selectedViewController;
    UIView                          *_headerView;
    BOOL                            _headerViewHidden;
}

@property (nonatomic, weak) id<KITabViewControllerDelegate>     delegate;
@property (nonatomic, strong) KITabView                         *tabView;
@property (nonatomic, assign) NSUInteger                        selectedIndex;
@property (nonatomic, strong) KITabViewItem                     *selectedItem;
@property (nonatomic, assign) BOOL                              tabViewHidden;
@property (nonatomic, assign) KITabViewPosition                 position;
@property (nonatomic, assign) BOOL                              autoLayout;
@property (nonatomic, strong) UIView                            *headerView;
@property (nonatomic, readonly) BOOL                            headerViewHidden;

@property (nonatomic, assign) KITabViewTransition               transition;

- (id)initWithPosition:(KITabViewPosition)position autoLayout:(BOOL)autoLayout;

- (void)setTabViewBackgroundColor:(UIColor *)color;

- (void)setTabViewBackgroundImage:(UIImage *)image;

- (void)setTabBarHeaderView:(UIView *)view;

- (void)setTabBarFooterView:(UIView *)view;

/*设置一页显示的TabViewItem数量*/
- (void)setNumberOfItemsInPage:(NSUInteger)number;

- (void)setTabItemSelectedImage:(UIImage *)image margin:(UIEdgeInsets)margin;

- (CGFloat)tabViewHeight;

- (void)setTabViewItems:(NSMutableArray *)tabViewItems;

- (NSMutableArray *)tabViewItems;

- (void)pop;

- (void)deselectIndex:(NSUInteger)index;

- (void)setHeaderViewHidden:(BOOL)hidden animated:(BOOL)animated;

@end

@protocol KITabViewControllerDelegate <NSObject>
@optional
- (CGFloat)tabViewHeightForTabViewController:(KITabViewController *)tabViewController;
- (UIEdgeInsets)edgeInsetsForTabViewController:(KITabViewController *)tabViewController;
- (void)tabViewController:(KITabViewController *)tabViewController didSelectedIndex:(NSUInteger)index;
- (void)tabViewController:(KITabViewController *)tabViewController didSelectedItem:(KITabViewItem *)item;
- (BOOL)tabViewController:(KITabViewController *)tabViewController willSelectIndex:(NSUInteger)index;
- (BOOL)tabViewController:(KITabViewController *)tabViewController willDeselectedIndex:(NSUInteger)index;
@end

@interface UIViewController (KITabViewController)
@property (nonatomic, assign, readonly) KITabViewController *tabViewController;
@property (nonatomic, assign, readonly) KITabViewItem       *tabViewItem;
@end
