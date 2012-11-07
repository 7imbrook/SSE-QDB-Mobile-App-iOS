//
//  QDBCell.h
//  SSE-QDB
//
//  Created by Michael on 11/1/12.
//  Copyright (c) 2012 Michael Timbrook. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>

@interface QDBCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *quoteNumber;
@property (weak, nonatomic) IBOutlet UITextView *body;
@property (weak, nonatomic) IBOutlet UITextView *description;

@end
