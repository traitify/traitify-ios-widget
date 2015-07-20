//
//  TraitifyResultsViewController.m
//  TraitifyWidget
//

#import "TraitifyResultsViewController.h"
#import "Traitify.h"


@interface TraitifyResultsViewController ()
@property (weak, nonatomic) IBOutlet UILabel *resultName;
@property (weak, nonatomic) IBOutlet UIImageView *resultImage;
@property (weak, nonatomic) IBOutlet UITextView *resultDescView;
@property (weak, nonatomic) IBOutlet UIButton *finishedButton;

@end

@implementation TraitifyResultsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	NSArray *sortedTypes = [self.result.personalityTypes sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"score" ascending:NO]]];
	TraitifyType *primaryType = sortedTypes[0];
	
	self.resultName.text = primaryType.typeName;
	self.resultDescView.text = primaryType.typeDescription;
	
	self.resultName.textColor = primaryType.badge.fontColor;
	self.resultDescView.textColor = primaryType.badge.fontColor;
	self.finishedButton.backgroundColor= primaryType.badge.color1;
	
	NSURLRequest *request = [NSURLRequest requestWithURL:primaryType.badge.imageMediumURL];
	NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
	NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfig];
	NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
		if (data) {
			UIImage *image = [UIImage imageWithData:data];
			dispatch_async(dispatch_get_main_queue(), ^{
				self.resultImage.image = image;
			});
		}
	}];
	[task resume];
}

- (IBAction)finishedButtonTapped:(id)sender {
	[self dismissViewControllerAnimated:YES completion:nil];
}

@end
