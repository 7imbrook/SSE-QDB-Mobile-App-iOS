//
//  QDBViewController.m
//  SSE-QDB
//
//  Created by Michael on 11/1/12.
//  Copyright (c) 2012 Michael Timbrook. All rights reserved.
//

#import "QDBAppDelegate.h"
#import "QDBViewController.h"
#import "AFNetworking/AFNetworking.h"
#import "QDBCell.h"

@interface QDBViewController ()

@property NSOperationQueue *operationQueue;
@property NSOperationQueue *dataWrite;
@property NSNumber *quoteIdIter;

@end

@implementation QDBViewController


- (void)viewDidLoad
{
    NSLog(@"App Load");
    [super viewDidLoad];
    _operationQueue = [[NSOperationQueue alloc] init];
    [_operationQueue setName:@"Data Fetcher"];
    _dataWrite = [[NSOperationQueue alloc] init];
    [_dataWrite setName:@"Data Write"];
    _quoteStream.dataSource = self;
    _quoteStream.delegate = self;
    //Table Data
    _quoteID = [[NSMutableArray alloc] init];
    _body = [[NSMutableArray alloc] init];
    _discription = [[NSMutableArray alloc] init];
    // END
    _refresh = [[UIRefreshControl alloc] init];
    [_refresh addTarget:self action:@selector(loadQuotes) forControlEvents:UIControlEventValueChanged];
    [_refresh addTarget:self action:@selector(loadQuotes) forControlEvents:UIApplicationStateActive];
    [_quoteStream addSubview:_refresh];
    [self loadQuotes];
}

-(void)configAdmin{
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"admin_on"]){
        NSLog(@"Admin Enabled");
        [_adminMenu setHidden:false];
        
        NSString *mod_user = [[NSUserDefaults standardUserDefaults] stringForKey:@"mod_user"];
        NSString *mod_pass = [[NSUserDefaults standardUserDefaults] stringForKey:@"mod_pass"];
        NSString *strURL = [NSString stringWithFormat:@"https://%@:%@@sse.se.rit.edu/qdb/admin.json", mod_user, mod_pass];
        NSURL *url = [NSURL URLWithString:strURL];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            
        } failure:^(NSURLRequest *request , NSHTTPURLResponse *response , NSError *error , id JSON){
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Bad Login" message:@"Could not authenticate to the server, check username and password in settings." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [errorAlert show];
        }];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        [operation start];        
    } else {
        NSLog(@"Admin Disabled");
        [_adminMenu setEnabled:false];
        [_adminMenu setHidden:true];
    }
}

- (void)loadQuotes{
    NSLog(@"Loading data");
    NSString *strURL = [NSString stringWithFormat:@"https://sse.se.rit.edu/qdb/quotes.json?page=%d", 1];
    NSURL *url = [NSURL URLWithString:strURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        [_quoteID removeAllObjects];
        [_body removeAllObjects];
        [_discription removeAllObjects];
        for (id quotes in JSON){
            if ([quotes valueForKeyPath:@"approved"]) {
                [_quoteID addObject:[quotes valueForKeyPath:@"id"]];
                [_body addObject:[quotes valueForKeyPath:@"body"]];
                if ([quotes valueForKeyPath:@"description"]) {
                    [_discription addObject:[quotes valueForKeyPath:@"description"]];
                } else {
                    [_discription addObject:@"None"];
                }
            }
        }
        NSDate *date = [NSDate date];
        NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"'Last updated ' h:mm:ss a 'on' MM/d/YY"];
        NSString *dateFull = [formatter stringFromDate:date];
        _refresh.attributedTitle = [[NSAttributedString alloc] initWithString:dateFull];
        [_refresh endRefreshing];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        _quoteIdIter = [_quoteID objectAtIndex:[_quoteID count] - 1];
        [_quoteStream reloadData];
        
    } failure:^(NSURLRequest *request , NSHTTPURLResponse *response , NSError *error , id JSON){
        NSLog(@"%@", error.description);
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Network Error" message:@"Error fetching data." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [errorAlert show];
        [_refresh endRefreshing];
    }];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [operation start];
}

- (void)addMoreQuoteToTable{
    [_operationQueue addOperationWithBlock:^{
        _quoteIdIter = @([_quoteIdIter intValue] - 1);
        NSLog(@"Quote to Load: %d", [_quoteIdIter intValue]);
        NSString *strURL = [NSString stringWithFormat:@"https://sse.se.rit.edu/qdb/quotes/%d.json", [_quoteIdIter intValue]];
        NSURL *url = [NSURL URLWithString:strURL];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                NSLog(@"Loading");
                [_quoteID addObject:[JSON valueForKeyPath:@"id"]];
                [_body addObject:[JSON valueForKeyPath:@"body"]];
                [_discription addObject:[JSON valueForKeyPath:@"description"]];
                [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
                    [_quoteStream beginUpdates];
                    NSIndexPath *indexPath = [[NSIndexPath alloc] init];
                    NSLog(@"%d", [_quoteID count]);
                    indexPath = [NSIndexPath indexPathForRow:[_quoteID count]-1 inSection:0];
                    NSArray *indexes = @[indexPath];
                    [_quoteStream insertRowsAtIndexPaths:indexes withRowAnimation:UITableViewRowAnimationBottom];
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    [_quoteStream endUpdates];
                }];
            }];
        } failure:^(NSURLRequest *request , NSHTTPURLResponse *response , NSError *error , id JSON){
            NSLog(@"FAIL");
            _quoteIdIter = @([_quoteIdIter intValue] - 1);
            [self addMoreQuoteToTable];
        }];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        [operation start];
}];
}

- (IBAction)mainViewSwipe:(id)sender {
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark TableView DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_quoteID count];
}

//- (CGFloat)tableView:(UITableView *)t heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    QDBCell *cell = [t dequeueReusableCellWithIdentifier:@"QuoteCell"];
//    NSString *bodyText = [_body objectAtIndex:indexPath.row];
//    NSString *discText = [_discription objectAtIndex:indexPath.row];
//    CGSize template = CGSizeMake(300,CGFLOAT_MAX);
//    UIFont *bodyFont = [cell.body font];
//    UIFont *discFont = [cell.description font];
//    CGSize bodySize;
//    CGSize discSize;
//    bodySize = [bodyText sizeWithFont:bodyFont constrainedToSize:template];
//    discSize = [discText sizeWithFont:discFont constrainedToSize:template];
//    NSLog(@"%@", indexPath);
//    return  bodySize.height + discSize.height + 40;
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSInteger *totalRows = [_quoteID count];
    if (((int)indexPath.row + 1) >= ((int)totalRows - 10)) {
        [self addMoreQuoteToTable];
    }
    
    QDBCell *cell = [tableView dequeueReusableCellWithIdentifier:@"QuoteCell"];
        cell.quoteNumber.text = ((NSNumber *)[_quoteID objectAtIndex:indexPath.row]).stringValue;
        cell.body.text = [_body objectAtIndex:indexPath.row];
        cell.description.text = [_discription objectAtIndex:indexPath.row];
        NSLog(@"Total Rows: %d Loaded: %d ID: %@", (int)totalRows, indexPath.row, [_quoteID objectAtIndex:indexPath.row]);
        return cell;
}

@end
