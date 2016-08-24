//
//  ViewController.m
//  IQLabelViewDemo
//
//  Created by kcandr on 20.12.14.

#import "ViewController.h"
#import "IQLabelView.h"

@interface ViewController () <IQLabelViewDelegate>
{
    IQLabelView *currentlyEditingLabel;
    NSMutableArray *labels;
}

@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) NSArray *colors;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.colors = [NSArray arrayWithObjects:[UIColor whiteColor], [UIColor redColor], [UIColor blueColor], nil];
    
    UIBarButtonItem *addLabelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                    target:self action:@selector(addLabel)];

    UIBarButtonItem *refreshColorButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                                        target:self action:@selector(changeColor)];
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                                target:self action:@selector(saveImage)];
    self.navigationItem.leftBarButtonItem = addLabelButton;
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:saveButton, refreshColorButton, nil];
    
    [self.view setBackgroundColor:[UIColor colorWithRed:88/255.0 green:173/255.0 blue:227/255.0 alpha:1.0]];
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchOutside:)]];
    [self.imageView setImage:[UIImage imageNamed:@"image"]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addLabel
{
    [currentlyEditingLabel hideEditingHandles];
    CGRect labelFrame = CGRectMake(CGRectGetMidX(self.imageView.frame) - arc4random() % 20,
                                   CGRectGetMidY(self.imageView.frame) - arc4random() % 20,
                                   60, 50);
    
    IQLabelView *labelView = [[IQLabelView alloc] initWithFrame:labelFrame];
    [labelView setDelegate:self];
    [labelView setShowsContentShadow:NO];
    [labelView setEnableMoveRestriction:YES];
    [labelView setFontName:@"Baskerville-BoldItalic"];
    [labelView setFontSize:21.0];
    [labelView setTextBorderColor:[UIColor blueColor]];
    
    [self.imageView addSubview:labelView];
    [self.imageView setUserInteractionEnabled:YES];
    
    if (arc4random() % 2 == 0) {
        [labelView setAttributedPlaceholder:[[NSAttributedString alloc]
                                             initWithString:NSLocalizedString(@"Placeholder", nil)
                                             attributes:@{ NSForegroundColorAttributeName : [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.75] }]];
    }
    
    currentlyEditingLabel = labelView;
    [labels addObject:labelView];
}

- (void)saveImage
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        UIImageWriteToSavedPhotosAlbum([self visibleImage], nil, nil, nil);
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"Saved to Photo Roll");
        });
    });
}

- (void)changeColor
{
    [currentlyEditingLabel setTextColor:[self.colors objectAtIndex:arc4random() % 3]];
    [currentlyEditingLabel setTextBorderColor:[self.colors objectAtIndex:arc4random() % 3]];
}

- (UIImage *)visibleImage
{
    UIGraphicsBeginImageContextWithOptions(self.imageView.bounds.size, YES, [UIScreen mainScreen].scale);
    CGContextTranslateCTM(UIGraphicsGetCurrentContext(), CGRectGetMinX(self.imageView.frame), -CGRectGetMinY(self.imageView.frame));
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *visibleViewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return visibleViewImage;
}

#pragma mark - Gesture 

- (void)touchOutside:(UITapGestureRecognizer *)touchGesture
{
    [currentlyEditingLabel hideEditingHandles];
}

#pragma mark - IQLabelDelegate

- (void)labelViewDidClose:(IQLabelView *)label
{
    // some actions after delete label
    [labels removeObject:label];
}

- (void)labelViewDidBeginEditing:(IQLabelView *)label
{
    // move or rotate begin
}

- (void)labelViewDidShowEditingHandles:(IQLabelView *)label
{
    // showing border and control buttons
    currentlyEditingLabel = label;
}

- (void)labelViewDidHideEditingHandles:(IQLabelView *)label
{
    // hiding border and control buttons
    currentlyEditingLabel = nil;
}

- (void)labelViewDidStartEditing:(IQLabelView *)label
{
    // tap in text field and keyboard showing
    currentlyEditingLabel = label;
}

@end
