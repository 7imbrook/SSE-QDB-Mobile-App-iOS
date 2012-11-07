//
//  QDBViewController.h
//  SSE-QDB
//
//  Created by Michael on 11/1/12.
//  Copyright (c) 2012 Michael Timbrook. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QDBViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, retain) NSMutableArray *quoteID;
@property (nonatomic, retain) NSMutableArray *body;
@property (nonatomic, retain) NSMutableArray *discription;
@property (weak, nonatomic) IBOutlet UITableView *quoteStream;
@property (nonatomic, retain) UIRefreshControl *refresh;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *addQuote;
@property (weak, nonatomic) IBOutlet UIButton *adminMenu;

@property (nonatomic, retain) NSAttributedString *attributedTitle;

-(void)configAdmin;
-(void)loadQuotes;
-(IBAction)mainViewSwipe:(id)sender;

@end
