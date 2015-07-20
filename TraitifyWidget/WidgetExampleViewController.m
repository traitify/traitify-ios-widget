//
//  WidgetExampleViewController.m
//  TraitifyWidget
//

#import "WidgetExampleViewController.h"
#import "TraitifyWidgetViewController.h"
#import "Traitify.h"


@interface WidgetExampleViewController ()
@property (weak, nonatomic) IBOutlet UIView *containerView;
@end

@implementation WidgetExampleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	TraitifyWidgetViewController *twvc = [TraitifyWidgetViewController traitifyWidget];
	[twvc willMoveToParentViewController:self];
	[self addChildViewController:twvc];
	[self.containerView addSubview:twvc.view];
	twvc.view.frame = self.containerView.bounds;
	[twvc didMoveToParentViewController:self];
	
	[twvc.traitify createAssessmentWithDeckID:@"introvert-extrovert" complete:^(NSDictionary *assessmentDict) {
		TraitifyAssessment *assessment = [TraitifyAssessment assessmentWithDictionary:assessmentDict];
		if (assessment) {
			twvc.assessmentID = assessment.assessmentID;
			[twvc beginSlides];
		}
	}];
}

@end
