//
//  KITabViewItem.m
//  Kitalker
//
//  Created by 杨 烽 on 13-3-7.
//  
//

#import "KITabViewItem.h"

@implementation KITabViewItem

@synthesize index = _index;
@synthesize title = _title;
@synthesize image = _image;
@synthesize selectedImage = _selectedImage;
@synthesize backgroundImage = _backgroundImage;
@synthesize selectedBackgroundImage = _selectedBackgroundImage;
@synthesize viewController = _viewController;
@synthesize deselectable = _deselectable;
@synthesize badge = _badge;

- (id)init {
    return [self initWithViewController:nil];
}

- (id)initWithViewController:(UIViewController *)viewController {
    if (self = [super init]) {
        _viewController = viewController;
        [self setBackgroundColor:[UIColor clearColor]];
        [self setDeselectable:NO];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)dealloc {
    _title = nil;
    _image = nil;
    _selectedImage = nil;
    _backgroundImage = nil;
    _selectedBackgroundImage = nil;
    _viewController = nil;
    _badge = nil;
}

@end
