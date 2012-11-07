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

@property NSNumber *pageCount;
@property NSOperationQueue *operationQueue;

@end

@implementation QDBViewController


- (void)viewDidLoad
{
    NSLog(@"App Load");
    [super viewDidLoad];
    _operationQueue = [[NSOperationQueue alloc] init];
    _pageCount = [[NSNumber alloc] initWithInt:1];
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
    NSString *strURL = [NSString stringWithFormat:@"https://sse.se.rit.edu/qdb/quotes.json?page=%@", _pageCount];
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
        [_quoteStream reloadData];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
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
    NSLog(@"Loading more data");
    _pageCount = @(_pageCount.intValue + 1);
    NSString *strURL = [NSString stringWithFormat:@"https://sse.se.rit.edu/qdb/quotes.json?page=%@", _pageCount];
    NSURL *url = [NSURL URLWithString:strURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
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
        [_quoteStream reloadData];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
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

- (CGFloat)tableView:(UITableView *)t heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    QDBCell *cell = [t dequeueReusableCellWithIdentifier:@"QuoteCell"];
    NSString *bodyText = [_body objectAtIndex:indexPath.row];
    NSString *discText = [_discription objectAtIndex:indexPath.row];
    CGSize template = CGSizeMake(300,1000);
    UIFont *bodyFont = [cell.body font];
    UIFont *discFont = [cell.description font];
    CGSize bodySize = [bodyText sizeWithFont:bodyFont constrainedToSize:template];
    CGSize discSize = [discText sizeWithFont:discFont constrainedToSize:template];
    return bodySize.height + discSize.height + 40;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSInteger *totalRows = [_quoteID count];
    if ((int)(totalRows - indexPath.row) < 1 && totalRows > 0) {
        NSOperation *addToQueue = [[NSOperation alloc] init]
        //[addToQueue ]
        [self addMoreQuoteToTable];
    }
    
    QDBCell *cell = [tableView dequeueReusableCellWithIdentifier:@"QuoteCell"];
    cell.quoteNumber.text = ((NSNumber *)[_quoteID objectAtIndex:indexPath.row]).stringValue;
    cell.body.text = [_body objectAtIndex:indexPath.row];
    cell.description.text = [_discription objectAtIndex:indexPath.row];
    return cell;
}

@end
