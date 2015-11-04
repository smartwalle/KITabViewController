//
//  KITabViewItem.h
//  Kitalker
//
//  Created by 杨 烽 on 13-3-7.
//  
//

#import <UIKit/UIKit.h>

@interface KITabViewItem : UIControl {
    NSUInteger          _index;
    NSString            *_title;
    UIImage             *_image;
    UIImage             *_selectedImage;
    UIImage             *_backgroundImage;
    UIImage             *_selectedBackgroundImage;
    UIViewController    *_viewController;
    BOOL                _deselectable;
    NSString            *_badge;
}

@property (nonatomic, assign) NSUInteger            index;
@property (nonatomic, strong) NSString              *title;
@property (nonatomic, strong) UIImage               *image;
@property (nonatomic, strong) UIImage               *selectedImage;
@property (nonatomic, strong) UIImage               *backgroundImage;
@property (nonatomic, strong) UIImage               *selectedBackgroundImage;
@property (nonatomic, strong) UIViewController      *viewController;
@property (nonatomic, assign) BOOL                  deselectable;
@property (nonatomic, strong) NSString              *badge;

- (id)initWithViewController:(UIViewController *)viewController;

@end
