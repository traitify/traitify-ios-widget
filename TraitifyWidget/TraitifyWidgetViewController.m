//
//  TraitifyWidgetViewController.m
//  TraitifyWidget
//

#import "TraitifyWidgetViewController.h"
#import "TraitifyResultsViewController.h"
#import "Traitify.h"


//Make sure you set these!
static NSString *TRAITIFY_SECRET_KEY = @"1358869jocakd18anf3edv5gk3";
static BOOL TRAITIFY_TESTING_MODE = YES;


@interface TraitifyWidgetViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *slideImage;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *slideImageLoading;
@property (weak, nonatomic) IBOutlet UILabel *slideTitle;
@property (weak, nonatomic) IBOutlet UIButton *meButton;
@property (weak, nonatomic) IBOutlet UIButton *notMeButton;

@property (strong) NSArray *slides;
@property (assign) NSUInteger currentSlideIndex;

@property (strong) TraitifyResult *result;
@end

@implementation TraitifyWidgetViewController {
	NSTimeInterval slideStartTimeInterval;
}

+ (instancetype)traitifyWidget {
	TraitifyWidgetViewController *twvc = [[UIStoryboard storyboardWithName:@"TraitifyWidgetStoryboard" bundle:nil] instantiateInitialViewController];
	twvc.traitify = [[Traitify alloc] init];
	twvc.traitify.secretKey = TRAITIFY_SECRET_KEY;
	twvc.traitify.useTestingMode = TRAITIFY_TESTING_MODE;
	return twvc;
}

- (void)reset {
	[self beginSlides];
}

- (void)beginSlides {
	[self.traitify listSlidesForAssessmentID:self.assessmentID complete:^(NSArray *array) {
		NSMutableArray *slides = [NSMutableArray arrayWithCapacity:array.count];
		for (NSDictionary *slideDict in array) {
			TraitifySlide *slide = [TraitifySlide slideFromDictionary:slideDict];
			[slides addObject:slide];
		}
		dispatch_async(dispatch_get_main_queue(), ^{
			self.slides = [slides copy];
			self.currentSlideIndex = 0;
			[self showCurrentSlide];
		});
	}];
}

- (void)showCurrentSlide {
	TraitifySlide *slide = self.slides[self.currentSlideIndex];
	self.slideTitle.text = slide.caption;
	[self.slideImageLoading startAnimating];
	[slide downloadImageComplete:^(UIImage *image) {
		[self.slideImageLoading stopAnimating];
		self.slideImage.image = image;
		slideStartTimeInterval = [NSDate timeIntervalSinceReferenceDate];
	}];
}

- (void)nextSlide {
	NSUInteger nextIndex = self.currentSlideIndex + 1;
	if (nextIndex >= self.slides.count) {
		[self finishSlides];
	} else {
		self.slideImage.image = nil;
		self.slideTitle.text = @"";
		
		self.currentSlideIndex = nextIndex;
		[self showCurrentSlide];
	}
}

- (void)finishSlides {
	[self.slideImageLoading startAnimating];
	self.slideImage.image = nil;
	self.slideTitle.text = @"";
	
	[self.traitify getResultsForAssessmentID:self.assessmentID complete:^(NSDictionary *dict) {
		self.result = [TraitifyResult resultFromDictionary:dict];
		dispatch_async(dispatch_get_main_queue(), ^{
			[self performSegueWithIdentifier:@"showResultsSegue" sender:self];
		});
	}];
}

- (IBAction)meButtonTapped:(id)sender {
	self.meButton.enabled = NO;
	self.notMeButton.enabled = NO;
	
	NSTimeInterval timeTaken = [NSDate timeIntervalSinceReferenceDate] - slideStartTimeInterval;
	TraitifySlide *slide = self.slides[self.currentSlideIndex];
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		[self.traitify updateSlide:slide
				   forAssessmentID:self.assessmentID
						  response:YES
						 timeTaken:timeTaken
						  complete:^(NSArray *array) {
							  dispatch_async(dispatch_get_main_queue(), ^{
								  self.meButton.enabled = YES;
								  self.notMeButton.enabled = YES;
								  [self nextSlide];
							  });
						  }];
	});
}

- (IBAction)notMeButtonTapped:(id)sender {
	self.meButton.enabled = NO;
	self.notMeButton.enabled = NO;

	NSTimeInterval timeTaken = [NSDate timeIntervalSinceReferenceDate] - slideStartTimeInterval;
	TraitifySlide *slide = self.slides[self.currentSlideIndex];
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		[self.traitify updateSlide:slide
				   forAssessmentID:self.assessmentID
						  response:NO
						 timeTaken:timeTaken
						  complete:^(NSArray *array) {
							  dispatch_async(dispatch_get_main_queue(), ^{
								  self.meButton.enabled = YES;
								  self.notMeButton.enabled = YES;
								  [self nextSlide];
							  });
						  }];
	});
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.identifier isEqualToString:@"showResultsSegue"]) {
		TraitifyResultsViewController *rvc = segue.destinationViewController;
		rvc.result = self.result;
		[self reset];
	}
}

@end
