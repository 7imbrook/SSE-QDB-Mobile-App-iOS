//
//  QDBQuoteSubmission.m
//  SSE-QDB
//
//  Created by Michael on 11/2/12.
//  Copyright (c) 2012 Michael Timbrook. All rights reserved.
//

#import "QDBQuoteSubmission.h"
#import "AFNetworking/AFNetworking.h"

@interface QDBQuoteSubmission ()

@end

@implementation QDBQuoteSubmission

@synthesize quoteBody;
@synthesize discription;
@synthesize tags;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [quoteBody becomeFirstResponder];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

 - (IBAction)CreateQuote:(NSString*)quote:(NSString*)description:(NSString*)quoteTags {
     NSURL *sendRequest = [[NSURL alloc] initWithString:@"http://michaeltimbrook.com:3000"];
     AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:sendRequest];
     NSDictionary *params = @{  @"quote[body]" : quote,
                                @"quote[description]" : description,
                                @"tags" : quoteTags };
     NSMutableURLRequest *request = [httpClient requestWithMethod:@"POST" path:@"/qdb/quotes" parameters:params];
     
     AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
     [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
     [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
     [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
     }];
     [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
     [operation start];
 }

- (IBAction)submitQuote:(id)sender {
    [self CreateQuote:self.quoteBody.text :self.discription.text :self.tags.text];
    [self returnToStream:self];
}

- (IBAction)returnToStream:(id)sender {
    //[self dismissModalViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:^{}];
}
@end
