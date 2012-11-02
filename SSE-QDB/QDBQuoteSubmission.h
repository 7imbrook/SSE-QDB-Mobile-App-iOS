//
//  QDBQuoteSubmission.h
//  SSE-QDB
//
//  Created by Michael on 11/2/12.
//  Copyright (c) 2012 Michael Timbrook. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QDBQuoteSubmission : UIViewController
@property (weak, nonatomic) IBOutlet UITextView *quoteBody;
@property (weak, nonatomic) IBOutlet UITextView *discription;
@property (weak, nonatomic) IBOutlet UITextView *tags;

- (IBAction)submitQuote:(id)sender;
- (IBAction)returnToStream:(id)sender;

@end
