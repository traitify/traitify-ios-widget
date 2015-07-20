//
//  TraitifyWidgetViewController.h
//  TraitifyWidget
//

#import <UIKit/UIKit.h>

@class Traitify;

@interface TraitifyWidgetViewController : UIViewController

@property (strong) Traitify *traitify;
@property (strong) NSString *assessmentID;

+ (instancetype)traitifyWidget;

- (void)beginSlides;

@end
