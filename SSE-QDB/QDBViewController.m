//
//  QDBViewController.m
//  SSE-QDB
//
//  Created by Michael on 11/1/12.
//  Copyright (c) 2012 Michael Timbrook. All rights reserved.
//

#import "QDBViewController.h"
#import "AFNetworking/AFNetworking.h"
#import "QDBCell.h"

@interface QDBViewController ()

@end

@implementation QDBViewController

@synthesize quoteID;
@synthesize body;
@synthesize discription;
@synthesize quoteStream;
@synthesize refresh;

@synthesize addQuote;

@synthesize attributedTitle;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Code for button
    
    
    
    
    // == END ==
    self.quoteStream.dataSource = self;
    self.quoteID = [[NSMutableArray alloc] init];
    self.body = [[NSMutableArray alloc] init];
    self.discription = [[NSMutableArray alloc] init];
    self.refresh = [[UIRefreshControl alloc] init];
    [self.refresh addTarget:self action:@selector(loadQuotes) forControlEvents:UIControlEventValueChanged];
    [self.quoteStream addSubview:self.refresh];
    [self loadQuotes];
}

-(void)loadQuotes{
    NSURL *url = [NSURL URLWithString:@"http://129.21.132.205:3000/qdb/quotes.json"]; // DEV-URL http://129.21.132.205:3000/qdb/quotes.json
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        [quoteID removeAllObjects];
        [body removeAllObjects];
        [discription removeAllObjects];
        for (id quotes in JSON){
            if ([quotes valueForKeyPath:@"approved"]) {
                [quoteID addObject:[quotes valueForKeyPath:@"id"]];
                [body addObject:[quotes valueForKeyPath:@"body"]];
                if ([quotes valueForKeyPath:@"description"]) {
                    [discription addObject:[quotes valueForKeyPath:@"description"]];
                } else {
                    [discription addObject:@"None"];
                }
            }
        }
        NSDate *date = [NSDate date];
        NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"'Last updated ' h:mm:ss a 'on' MM/d/YY"];
        NSString *dateFull = [formatter stringFromDate:date];
        self.refresh.attributedTitle = [[NSAttributedString alloc] initWithString:dateFull];
        [self.refresh endRefreshing];
        [self.quoteStream reloadData];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
    } failure:^(NSURLRequest *request , NSHTTPURLResponse *response , NSError *error , id JSON){
        NSLog(@"%@", error.description);
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Network Error" message:@"There was an error recieving data from the server." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [errorAlert show];
        [self.refresh endRefreshing];
    }];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [operation start];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark TableView DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.quoteID count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    QDBCell *cell = [tableView dequeueReusableCellWithIdentifier:@"QuoteCell"];
    cell.quoteNumber.text = ((NSNumber *)[self.quoteID objectAtIndex:indexPath.row]).stringValue;
    cell.body.text = [self.body objectAtIndex:indexPath.row];
    cell.description.text = [self.discription objectAtIndex:indexPath.row];
    return cell;
}

@end
