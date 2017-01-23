//
//  MenuViewController.m
//  Belarus
//
//  Created by  Alex Nevsky on 24.12.15.
//  Copyright © 2016 Alex Nevsky. All rights reserved.
//

#import "MenuViewController.h"
#import <Masonry/View+MASAdditions.h>
#import "MetricaLogger.h"
#import "MessageUI/MessageUI.h"

static NSString *kAppSupportEmail = @"belarus.today.com@gmail.com";
static NSString *kAppSiteLink = @"http://belarus-today.com";
static NSString *kAppRateLink = @"itms-apps://itunes.apple.com/app/id1180300697";

@interface MenuViewController () < MFMailComposeViewControllerDelegate, UIAlertViewDelegate >

@property (nonatomic, strong) UIView *contentContainer;
@property (nonatomic, strong) UIImageView *coverView;

@property (nonatomic, strong) UIAlertView *rateAppAlert;
@property (nonatomic, strong) UIAlertView *sendEmailFeedbackAlert;
@property (nonatomic, strong) NSString *rating;

- (IBAction)allAction:(id)sender;
- (IBAction)peopleAction:(id)sender;
- (IBAction)autoAction:(id)sender;
- (IBAction)technologyAction:(id)sender;
- (IBAction)entertainmentAction:(id)sender;
- (IBAction)feedbackAction:(id)sender;
- (IBAction)shareAction:(id)sender;
- (IBAction)rateAction:(id)sender;

@end

@implementation MenuViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
        
    [self setup];
}

- (void)setup
{
    self.navigationItem.title = NSLocalizedString(@"Menu", nil);
    
    UIView *contentContainer = UIView.new;
    
    self.contentContainer = contentContainer;
    [self.view addSubview:contentContainer];
    [contentContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    self.coverView = UIImageView.new;
    self.coverView.image = [UIImage imageNamed:@"belarus-launch"];
    self.coverView.contentMode = UIViewContentModeScaleAspectFill;
    self.coverView.frame = self.tableView.frame;
    self.tableView.backgroundView = self.coverView;
    
    UIVisualEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
    effectView.frame = self.coverView.bounds;
    [self.coverView addSubview:effectView];
    [effectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.coverView);
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}

- (IBAction)allAction:(id)sender
{
    NSDictionary *deviceStat = [[NSDictionary alloc] initWithObjectsAndKeys:@"Selection", @"All Action", nil];
    [MetricaLogger reportToMetricaEvent:@"Menu Statistics" withParams:deviceStat];
    
    [[NSUserDefaults standardUserDefaults] setObject:@"All" forKey:@"NewsCategoryPref"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)peopleAction:(id)sender
{
    NSDictionary *deviceStat = [[NSDictionary alloc] initWithObjectsAndKeys:@"Selection", @"People Action", nil];
    [MetricaLogger reportToMetricaEvent:@"Menu Statistics" withParams:deviceStat];
    
    [[NSUserDefaults standardUserDefaults] setObject:@"People" forKey:@"NewsCategoryPref"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)autoAction:(id)sender
{
    NSDictionary *deviceStat = [[NSDictionary alloc] initWithObjectsAndKeys:@"Selection", @"Auto Action", nil];
    [MetricaLogger reportToMetricaEvent:@"Menu Statistics" withParams:deviceStat];
    
    [[NSUserDefaults standardUserDefaults] setObject:@"Auto" forKey:@"NewsCategoryPref"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)technologyAction:(id)sender
{
    NSDictionary *deviceStat = [[NSDictionary alloc] initWithObjectsAndKeys:@"Selection", @"Technology Action", nil];
    [MetricaLogger reportToMetricaEvent:@"Menu Statistics" withParams:deviceStat];
    
    [[NSUserDefaults standardUserDefaults] setObject:@"Technology" forKey:@"NewsCategoryPref"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)entertainmentAction:(id)sender
{
    NSDictionary *deviceStat = [[NSDictionary alloc] initWithObjectsAndKeys:@"Selection", @"Entertainment Action", nil];
    [MetricaLogger reportToMetricaEvent:@"Menu Statistics" withParams:deviceStat];
    
    [[NSUserDefaults standardUserDefaults] setObject:@"Entertainment" forKey:@"NewsCategoryPref"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)feedbackAction:(id)sender
{
    NSDictionary *deviceStat = [[NSDictionary alloc] initWithObjectsAndKeys:@"Selection", @"Feedback Action", nil];
    [MetricaLogger reportToMetricaEvent:@"Menu Statistics" withParams:deviceStat];
    
    NSString *message = NSLocalizedString(@"I want to tell you about app the following", nil);
    [self sendEmailWithSubject:[NSString stringWithFormat:@"%@ - Feedback", NSLocalizedString(@"Belarus Today - Mobile App", nil)] andBody:message];
}

- (IBAction)shareAction:(id)sender
{
    NSDictionary *deviceStat = [[NSDictionary alloc] initWithObjectsAndKeys:@"Selection", @"Share Action", nil];
    [MetricaLogger reportToMetricaEvent:@"Menu Statistics" withParams:deviceStat];
    
    [self shareText:NSLocalizedString(@"I love this amazing app!", nil) andImage:[UIImage imageNamed:@"belarus-launch"] andUrl:[NSURL URLWithString:kAppSiteLink]];
}

- (IBAction)rateAction:(id)sender
{
    NSDictionary *deviceStat = [[NSDictionary alloc] initWithObjectsAndKeys:@"Selection", @"Rate Action", nil];
    [MetricaLogger reportToMetricaEvent:@"Menu Statistics" withParams:deviceStat];
    
    if (self.rateAppAlert == nil) {
        self.rateAppAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Rate App", nil) message:NSLocalizedString(@"Thank you for using app. Please rate this app", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Not now", nil) otherButtonTitles:NSLocalizedString(@"Thumbs up!", nil), NSLocalizedString(@"Nice", nil), NSLocalizedString(@"Not good", nil), nil];
    }
    
    [self.rateAppAlert show];
}

# pragma mark - app actions

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView == self.rateAppAlert) {
        NSString *string = [alertView buttonTitleAtIndex:buttonIndex];
        if ([string isEqualToString:NSLocalizedString(@"Thumbs up!", nil)]) {
            [self openAppStore];
        }
        else if ([string isEqualToString:NSLocalizedString(@"Nice", nil)]) {
            [self openAppStore];
        }
        else if ([string isEqualToString:NSLocalizedString(@"Not good", nil)]) {
            self.rating = NSLocalizedString(@"Not good", nil);
            
            if (self.sendEmailFeedbackAlert == nil) {
                self.sendEmailFeedbackAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Thanks!", nil) message:NSLocalizedString(@"Please tell us what you want this app be", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Not now", nil) otherButtonTitles:NSLocalizedString(@"Write", nil), nil];
            }
            
            [self.sendEmailFeedbackAlert show];
        }
        
    }
    else if (alertView == self.sendEmailFeedbackAlert) {
        NSString *string = [alertView buttonTitleAtIndex:buttonIndex];
        if ([string isEqualToString:NSLocalizedString(@"Write", nil)]) {
            NSString *message = NSLocalizedString(@"I want to tell you about app", nil);
            [self sendEmailWithSubject:[NSString stringWithFormat:@"%@ - %@", NSLocalizedString(@"Belarus Today - Mobile App", nil), self.rating] andBody:message];
        }
    }
}

- (void)shareText:(NSString *)text andImage:(UIImage *)image andUrl:(NSURL *)url
{
    NSMutableArray *sharingItems = [NSMutableArray new];
    if (text) {
        [sharingItems addObject:text];
    }
    if (image) {
        [sharingItems addObject:image];
    }
    if (url) {
        [sharingItems addObject:url];
    }
    
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:sharingItems applicationActivities:nil];
    [self presentViewController:activityController animated:YES completion:nil];
}

- (void)openAppStore
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kAppRateLink]];
}

- (void)sendEmailWithSubject:(NSString *)subject andBody:(NSString *)body
{
    BOOL isSuccess = NO;
    if ([MFMessageComposeViewController canSendText]) {
        MFMailComposeViewController *mailComposeViewController = [[MFMailComposeViewController alloc] init];
        if (mailComposeViewController) {
            isSuccess = YES;
            
            mailComposeViewController.mailComposeDelegate = self;
            mailComposeViewController.subject = subject;
            [mailComposeViewController setMessageBody:[NSString stringWithFormat:@"%@", body] isHTML:NO];
            [mailComposeViewController setToRecipients:@[kAppSupportEmail]];
            [self presentViewController:mailComposeViewController animated:YES completion:nil];
        }
    }
    
    if (!isSuccess) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Can't send email. Please check mail client and/or SIM card.", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}

@end
