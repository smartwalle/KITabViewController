//
//  KITabViewController.m
//  Kitalker
//
//  Created by 杨 烽 on 13-3-7.
//  
//

#import "KITabViewController.h"
#import <objc/runtime.h>

@interface KITabViewController () <UIScrollViewDelegate> {
    BOOL            _isFirstAppear;
    CGFloat         _containerViewHeight;
    NSMutableArray  *_selectedIndexStack;
}
@property (nonatomic, strong) UIScrollView  *containerView;
@property (nonatomic, assign) CGPoint       lastContentOffset;

@end

@implementation KITabViewController
@synthesize autoLayout          = _autoLayout;
@synthesize delegate            = _delegate;
@synthesize position            = _position;
@synthesize tabView             = _tabView;
@synthesize containerView       = _containerView;
@synthesize selectedIndex       = _selectedIndex;
@synthesize selectedItem        = _selectedItem;
@synthesize headerView          = _headerView;
@synthesize headerViewHidden    = _headerViewHidden;

- (id)init {
    return [self initWithPosition:KITabViewPositionOfBottom autoLayout:YES];
}

- (id)initWithPosition:(KITabViewPosition)position autoLayout:(BOOL)autoLayout {
    if (self = [super init]) {
        _position = position;
        _autoLayout = autoLayout;
        [self tabViewInitFinished];
    }
    return self;
}

- (void)tabViewInitFinished {
    _selectedIndex = 0;
    _isFirstAppear = YES;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self tabViewInitFinished];
}

- (void)loadView {
    [super loadView];
    [self updateView:NO];
    [self.view setClipsToBounds:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    /*避免显示KITabViewController之后，没有显示Sub ViewController，所以将这段代码从viewDidAppear移动至此*/
    if (_isFirstAppear) {
        [self setSelectedIndex:_selectedIndex];
        _isFirstAppear = NO;
    }
    [_selectedViewController viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [_selectedViewController viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_selectedViewController viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [_selectedViewController viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    for (KITabViewItem *item in self.tabViewItems) {
        if (item.viewController) {
            [item.viewController didReceiveMemoryWarning];
        }
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == self.view && [keyPath isEqualToString:@"frame"]) {
//        [self updateView];
    } else if (object == _selectedViewController.view && [keyPath isEqualToString:@"frame"]) {
        /*UITableView *tableView = (UITableView *)_selectedViewController.view;
        CGPoint offset = CGPointZero;
        BOOL isTableView = [tableView isMemberOfClass:[UITableView class]];
        if (isTableView) {
            offset = [tableView contentOffset];
        }
        [_selectedViewController.view setBounds:[self containerView].bounds];
        if (isTableView) {
            [tableView setContentOffset:offset];
        }*/
    }
}

- (void)setHeaderView:(UIView *)headerView {
    if (_headerView != headerView) {
        [_headerView removeFromSuperview];
        _headerView = headerView;
        if (_headerView != nil) {
            [_headerView setFrame:CGRectMake(0,
                                             0,
                                             CGRectGetWidth(self.view.bounds),
                                             CGRectGetHeight(_headerView.bounds))];
            [self.view addSubview:_headerView];
            _headerViewHidden = NO;
        } else {
            _headerViewHidden = YES;
        }
        [self updateView:NO];
    }
}

- (void)setHeaderViewHidden:(BOOL)hidden animated:(BOOL)animated {
    if (self.headerView != nil) {
        if (_headerViewHidden != hidden) {
            _headerViewHidden = hidden;
            [self updateView:animated];
        }
    }
}

- (void)setTransition:(KITabViewTransition)transition {
    _transition = transition;
    [self updateContainerViewContentSize];
}

- (void)updateView:(BOOL)animated {
    
    //处理headerView相关的
    CGFloat headerViewHeight = CGRectGetHeight(self.headerView.bounds);
    if (self.headerViewHidden) {
        headerViewHeight = 0;
    }
    
    CGFloat tabViewX = 0;
    CGFloat tabViewY = 0;
    CGFloat tabViewWidth = CGRectGetWidth(self.view.bounds);
    CGFloat tabViewHeight = [self tabViewHeight];
    
    UIEdgeInsets edgeInsets = [self containerViewEdgeInsets];
    
    CGFloat containerViewX = 0;
    CGFloat containerViewY = 0;
    CGFloat containerViewWidth = CGRectGetWidth(self.view.bounds);
    CGFloat containerViewHeight = CGRectGetHeight(self.view.bounds)-tabViewHeight-edgeInsets.top-edgeInsets.bottom-headerViewHeight;
    
    //用于记录container view的高度是否发生的变化
//    if (_containerViewHeight == containerViewHeight) {
//        return ;
//    }
//    _containerViewHeight = containerViewHeight;
    
    UIViewAutoresizing tabViewAutoresizing = UIViewAutoresizingNone;
    UIViewAutoresizing containerViewAutoresizing = UIViewAutoresizingNone;
    
    switch (self.position) {
        case KITabViewPositionOfTop: {
            //如果tabView是在上方，则containerView和tabView的y分别加上headerView的高度
            tabViewY += headerViewHeight;
            containerViewY = tabViewHeight+headerViewHeight;
            
            if (self.tabViewHidden) {
                containerViewY -= tabViewHeight;
                containerViewHeight += tabViewHeight + edgeInsets.top + edgeInsets.bottom;
                tabViewY -= tabViewHeight;
                tabViewHeight = 0;
            }
            
            tabViewAutoresizing = UIViewAutoresizingFlexibleBottomMargin;
            containerViewAutoresizing = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        }
            break;
        case KITabViewPositionOfBottom: {
            //如果tabView是在下方，containerView的y则加上headerView的高度
            tabViewY = CGRectGetHeight(self.view.bounds) - tabViewHeight;
            containerViewY += headerViewHeight;
            
            if (self.tabViewHidden) {
                containerViewHeight += tabViewHeight + edgeInsets.top + edgeInsets.bottom;
                tabViewY += tabViewHeight;
            }
            
            tabViewAutoresizing = UIViewAutoresizingFlexibleTopMargin;
            containerViewAutoresizing = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        }
            break;
        case KITabViewPositionOfLeft: {
            tabViewAutoresizing = UIViewAutoresizingFlexibleRightMargin;
            containerViewAutoresizing = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        }
            break;
        case KITabViewPositionOfRight: {
            tabViewAutoresizing = UIViewAutoresizingFlexibleLeftMargin;
            containerViewAutoresizing = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        }
            break;
        default:
            break;
    }
    
//    if (self.headerView != nil) {
//        if (self.headerViewHidden) {
//            if (self.tabViewHidden) {
//            } else {
//            }
//        } else {
//            containerViewHeight -= CGRectGetHeight(self.headerView.bounds);
//            if (self.tabViewHidden) {
//                
//                containerViewY += CGRectGetHeight(self.headerView.bounds);
//            } else {
//                tabViewY += CGRectGetHeight(self.headerView.bounds);
//                containerViewY += tabViewY;
//            }
//        }
//    }
    
    [[self tabView] setAutoresizingMask:tabViewAutoresizing];
    [[self containerView] setAutoresizingMask:containerViewAutoresizing];
    
    [UIView animateWithDuration:animated?0.3:0 animations:^{
        [[self tabView] setFrame:CGRectMake(tabViewX,
                                            tabViewY,
                                            tabViewWidth,
                                            tabViewHeight)];
        
        [[self containerView] setFrame:CGRectMake(containerViewX,
                                                  containerViewY,
                                                  containerViewWidth,
                                                  containerViewHeight)];
        if (_selectedViewController != nil) {
            [_selectedViewController.view setFrame:self.containerView.bounds];
        }
        [[self headerView] setFrame:CGRectMake(0,
                                               self.headerViewHidden?-CGRectGetHeight(self.headerView.bounds):0,
                                               CGRectGetWidth(self.view.bounds),
                                               CGRectGetHeight(self.headerView.bounds))];
        
    } completion:^(BOOL finished) {
//        [[self headerView] setHidden:self.headerViewHidden];
    }];
    [self updateContainerViewContentSize];
    
    [self.view insertSubview:[self tabView] aboveSubview:[self containerView]];
}

- (KITabView *)tabView {
    if(_tabView == nil) {
        _tabView = [[KITabView alloc] initWithDelegate:self position:self.position];
        [_tabView setAutoLayout:_autoLayout];
        [self.view addSubview:_tabView];
    }
    return _tabView;
}

- (UIScrollView *)containerView {
    if (_containerView == nil) {
        _containerView = [[UIScrollView alloc] init];
        [_containerView setDelegate:self];
        [_containerView setPagingEnabled:YES];
        [_containerView setClipsToBounds:YES];
        [_containerView setBounces:NO];
        [_containerView setShowsHorizontalScrollIndicator:NO];
        [_containerView setShowsVerticalScrollIndicator:NO];
        [_containerView setDirectionalLockEnabled:YES];
        [_containerView setBackgroundColor:[UIColor clearColor]];
        [_containerView setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin
                                            |UIViewAutoresizingFlexibleHeight
                                            |UIViewAutoresizingFlexibleTopMargin];
        [_containerView setAutoresizesSubviews:YES];
        [self.view addSubview:_containerView];
    }
    return _containerView;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    BOOL push = NO;
    
    if (self.lastContentOffset.x > scrollView.contentOffset.x) {
        push = NO;
    } else {
        push = YES;
    }
    
    if (scrollView.isDragging || scrollView.isDecelerating) {
        NSUInteger firstNeededPageIndex = 0;
        NSUInteger lastNeededPageIndex = 0;
        
        CGRect visibleBounds = self.containerView.bounds;
        firstNeededPageIndex = floorf(CGRectGetMinX(visibleBounds) / CGRectGetWidth(visibleBounds));
        lastNeededPageIndex  = floorf((CGRectGetMaxX(visibleBounds)-1) / CGRectGetWidth(visibleBounds));
        firstNeededPageIndex = MAX(firstNeededPageIndex, 0);
        lastNeededPageIndex  = MIN(lastNeededPageIndex, [self.tabViewItems count] - 1);
        
        if (push) {
            [self setSelectedIndex:lastNeededPageIndex];
        } else {
            [self setSelectedIndex:firstNeededPageIndex];
        }
    }
    
    if (self.transition == KITabViewTransitionPush) {
        CGPoint newPoint = scrollView.contentOffset;
        newPoint.x /= self.tabView.numberOfItemsInPage;
        
        [[self tabView] updateSelectedImageViewOffset:newPoint];
    }
    
    self.lastContentOffset = scrollView.contentOffset;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    //拖动Scrollview时，在这里删除
    [self cleanSubViewWithoutCurrent];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    //通过点击TabViewItem时， 在这里删除
    [self cleanSubViewWithoutCurrent];
}

- (void)updateContainerViewContentSize {
    [self.containerView setContentSize:CGSizeMake(self.transition==KITabViewTransitionPush?(CGRectGetWidth(self.view.bounds)*self.tabViewItems.count):0,
                                                  CGRectGetHeight(_selectedViewController.view.bounds))];
}

- (void)cleanSubView {
    for (UIView *view in self.containerView.subviews) {
        [view removeFromSuperview];
    }
}

- (void)cleanSubViewWithoutCurrent {
    for (UIView *view in self.containerView.subviews) {
        if (view != _selectedViewController.view) {
            [view removeFromSuperview];
        }
    }
}

- (NSMutableArray *)selectedIndexStack {
    if (_selectedIndexStack == nil) {
        _selectedIndexStack = [[NSMutableArray alloc] init];
    }
    return _selectedIndexStack;
}

- (void)setTabViewItems:(NSMutableArray *)tabViewItems {
    [self cleanSubView];
    
    [[self tabView] setTabViewItems:tabViewItems];
    
    for (KITabViewItem *item in tabViewItems) {
        if (item.viewController) {
            [item.viewController setValue:item forKey:@"tabViewItem"];
            [item.viewController setValue:self forKey:@"tabViewController"];
//            [item.viewController setValue:self forKey:@"parentViewController"];
            [self addChildViewController:item.viewController];
        }
    }
    
    [self updateContainerViewContentSize];
    
    [self.containerView setContentOffset:CGPointMake(0, 0)];
    
    if (!_isFirstAppear) {
        [self setSelectedIndex:0];
    }
}

- (NSMutableArray *)tabViewItems {
    return [[self tabView] tabViewItems];
}

- (void)setTabViewBackgroundColor:(UIColor *)color {
    [[self tabView] setBackgroundColor:color];
}

- (void)setTabViewBackgroundImage:(UIImage *)image {
    [[self tabView] setBackgroundImage:image];
}

- (void)setTabBarHeaderView:(UIView *)view {
    [[self tabView] setHeaderView:view];
}

- (void)setTabBarFooterView:(UIView *)view {
    [[self tabView] setFooterView:view];
}

- (void)setNumberOfItemsInPage:(NSUInteger)number {
    [[self tabView] setNumberOfItemsInPage:number];
}

- (void)setTabItemSelectedImage:(UIImage *)image margin:(UIEdgeInsets)margin {
    [[self tabView] setItemSelectedImage:image margin:margin];
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex {
    _selectedIndex = selectedIndex;
    /*避免显示KITabViewController之后，没有显示Sub ViewController，所以取消此判断*/
//    if ([self.view superview] != nil) {
        [[self tabView] setSelectedIndex:_selectedIndex];
//    }
}

- (NSUInteger)selectedIndex {
    return [[self tabView] selectedIndex];
}

- (void)setSelectedItem:(KITabViewItem *)selectedItem {
    [[self tabView] setSelectedItem:selectedItem];
}

- (KITabViewItem *)selectedItem {
    return [[self tabView] selectedItem];
}

- (CGFloat)tabViewHeight {
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(tabViewHeightForTabViewController:)]) {
        return [self.delegate tabViewHeightForTabViewController:self];
    }
    return kTabViewDefaultHeight;
}

- (UIEdgeInsets)containerViewEdgeInsets {
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(edgeInsetsForTabViewController:)]) {
        return [self.delegate edgeInsetsForTabViewController:self];
    }
    return UIEdgeInsetsZero;
}

- (CGFloat)heightForTabView:(KITabView *)tabView {
    return [self tabViewHeight];
}

- (BOOL)tabView:(KITabView *)tabView willDeselectIndex:(NSUInteger)index {
    return [self willDeselectedIndex:index];
}

- (BOOL)tabView:(KITabView *)tabView willSelectIndex:(NSUInteger)selectedIndex {
    return [self willSelectIndex:selectedIndex];
}

- (void)tabView:(KITabView *)tabView didSelectedIndex:(NSUInteger)selectedIndex {
    if (self.delegate != nil
        && [self.delegate respondsToSelector:@selector(tabViewController:didSelectedIndex:)]) {
        [self.delegate tabViewController:self didSelectedIndex:selectedIndex];
    }
}

- (void)tabView:(KITabView *)tabView didSelectedItem:(KITabViewItem *)selectedItem {
    if (selectedItem.viewController != nil) {
        [self updateViewController:selectedItem];
    }
    if (self.delegate != nil
        && [self.delegate respondsToSelector:@selector(tabViewController:didSelectedItem:)]) {
        [self.delegate tabViewController:self didSelectedItem:selectedItem];
    }
}

- (BOOL)willSelectIndex:(NSUInteger)index {
    if (self.delegate != nil
        && [self.delegate respondsToSelector:@selector(tabViewController:willSelectIndex:)]) {
        return [self.delegate tabViewController:self willSelectIndex:index];
    }
    return YES;
}

- (BOOL)willDeselectedIndex:(NSInteger)index {
    if (self.delegate != nil
        && [self.delegate respondsToSelector:@selector(tabViewController:willDeselectedIndex:)]) {
        return [self.delegate tabViewController:self willDeselectedIndex:index];
    }
    return YES;
}

- (void)updateViewController:(KITabViewItem *)tabViewItem {
    UIViewController *viewController = tabViewItem.viewController;
    NSUInteger index = tabViewItem.index;
    if (_selectedViewController != viewController) {
        
        [_selectedViewController.view setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin
         |UIViewAutoresizingFlexibleHeight
         |UIViewAutoresizingFlexibleTopMargin];
        
        CGRect newFrame = self.containerView.bounds;
        
        static NSString *KI_TAB_VIEW_ANIMATION_KEY = @"transition";
        if (self.transition == KITabViewTransitionFade) {
            CATransition *transition = [CATransition animation];
            transition.timingFunction = UIViewAnimationCurveEaseInOut;
            transition.type = kCATransitionFade;//@"rippleEffect";
            [[self containerView].layer addAnimation:transition forKey:KI_TAB_VIEW_ANIMATION_KEY];
        } else {
            [[self containerView].layer removeAnimationForKey:KI_TAB_VIEW_ANIMATION_KEY];
        }
        
        if (self.transition == KITabViewTransitionPush) {
            _selectedViewController = viewController;
            newFrame.origin.x = index * newFrame.size.width;
            [_selectedViewController.view setFrame:newFrame];
            
            [[self containerView] addSubview:_selectedViewController.view];
            if (!self.containerView.isDragging && !self.containerView.isDecelerating) {
                [[self containerView] setContentOffset:newFrame.origin animated:YES];
            }
        } else {
            if (_selectedViewController != nil) {
                [_selectedViewController.view removeFromSuperview];
                _selectedViewController = nil;
            }
            
            _selectedViewController = viewController;
            [_selectedViewController.view setFrame:newFrame];
            [[self containerView] addSubview:_selectedViewController.view];
        }
        
        [[self selectedIndexStack] addObject:[NSNumber numberWithUnsignedInteger:_selectedViewController.tabViewItem.index]];
    }
}

- (void)pop {
    [[self selectedIndexStack] removeLastObject];
    NSNumber *lastIndex = [[self selectedIndexStack] lastObject];
    if (lastIndex != nil) {
        NSUInteger index = [lastIndex integerValue];
        [[self selectedIndexStack] removeLastObject];
        [self setSelectedIndex:index];
    }
}

- (void)deselectIndex:(NSUInteger)index {
    [[self tabView] deselectIndex:index];
}

- (void)setTabViewHidden:(BOOL)hidden {
    if (_tabViewHidden == hidden) {
        return ;
    }
    _tabViewHidden = hidden;

    [self updateView:YES];
    
//    __block CGRect newFrame = self.view.bounds;
//    [UIView animateWithDuration:0.2 animations:^{
//        switch (self.position) {
//            case KITabViewPositionOfTop: {
//                newFrame.origin.y = _tabViewHidden?-[self tabViewHeight]:0;
//                newFrame.size.height += _tabViewHidden?[self tabViewHeight]:-[self tabViewHeight];
//                [self.view setFrame:newFrame];
//            }
//                break;
//            case KITabViewPositionOfBottom: {
//                newFrame.size.height += _tabViewHidden?[self tabViewHeight]:-[self tabViewHeight];
//                [self.view setFrame:newFrame];
//            }
//                break;
//            case KITabViewPositionOfLeft: {
//                
//            }
//                break;
//            case  KITabViewPositionOfRight: {
//                
//            }
//                break;
//            default:
//                break;
//        }
//    } completion:^(BOOL finished) {
//        
//    }];
}

- (BOOL)tabViewHidden {
    return _tabViewHidden;
}

- (void)dealloc {
    for (KITabViewItem *item in self.tabViewItems) {
        [item.viewController removeFromParentViewController];
    }
    _delegate = nil;
    _tabView = nil;
    _containerView = nil;
    _selectedItem = nil;
    _selectedViewController = nil;
    _selectedIndexStack = nil;
    [_headerView removeFromSuperview];
    _headerView = nil;
}

@end


static char KI_TAB_VIEW_CONTROLLER_KEY;
static char KI_TAB_VIEW_ITEM_KEY;

@implementation  UIViewController (KITabViewController)
@dynamic tabViewController;
@dynamic tabViewItem;

- (void)setTabViewController:(KITabViewController *)tabViewController {
    objc_setAssociatedObject(self, &KI_TAB_VIEW_CONTROLLER_KEY, tabViewController, OBJC_ASSOCIATION_ASSIGN);
}

- (KITabViewController *)tabViewController {
    KITabViewController *tabViewController = objc_getAssociatedObject(self, &KI_TAB_VIEW_CONTROLLER_KEY);
    if (tabViewController == nil && self.parentViewController != nil) {
        tabViewController = [self.parentViewController tabViewController];
    }
    return tabViewController;
}

- (void)setTabViewItem:(KITabViewItem *)tabViewItem {
    objc_setAssociatedObject(self, &KI_TAB_VIEW_ITEM_KEY, tabViewItem, OBJC_ASSOCIATION_ASSIGN);
}

- (KITabViewItem *)tabViewItem {
    return objc_getAssociatedObject(self, &KI_TAB_VIEW_ITEM_KEY);
}

@end
