//
//  ViewController.m
//  WYLayoutCell
//
//  Created by 薇谙 on 2018/7/27.
//  Copyright © 2018年 WY. All rights reserved.
//

#import "ViewController.h"
#import "FDFeedEntity.h"
#import "UITableView+SDTemplateLayoutCell.h"
#import "FeedTableViewCell.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, copy) NSArray *prototypeEntitiesFromJSON;

@property (nonatomic, strong) NSMutableArray *feedEntitySections; // 2d array

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.title = @"WY";
    [self.tableView registerClass:[FeedTableViewCell class] forCellReuseIdentifier:@"FeedTableViewCell"];
    
    //  加载数据
    [self buildTestDataThen:^{
        self.feedEntitySections = @[].mutableCopy;
        [self.feedEntitySections addObject:self.prototypeEntitiesFromJSON.mutableCopy];
        [self.tableView reloadData];
    }];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.feedEntitySections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.feedEntitySections[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* reusedID = @"FeedTableViewCell";
    FeedTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:reusedID];
    [cell setSelfDataWithIndexPath:indexPath feedEntity:self.feedEntitySections[indexPath.section][indexPath.row]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [tableView sd_heightForCellWithIdentifier:@"FeedTableViewCell" cacheByIndexPath:indexPath configuration:^(id cell) {
        [cell setSelfDataWithIndexPath:indexPath feedEntity:self.feedEntitySections[indexPath.section][indexPath.row]];
    }];
}

#pragma mark - loadData
- (void)buildTestDataThen:(void (^)(void))then {
    // Simulate an async request
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        // Data from `data.json`
        NSString *dataFilePath = [[NSBundle mainBundle] pathForResource:@"baidu" ofType:@"json"];
        NSData *data = [NSData dataWithContentsOfFile:dataFilePath];
        NSDictionary *rootDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        NSArray *feedDicts = rootDict[@"feed"];
        
        // Convert to `FDFeedEntity`
        NSMutableArray *entities = @[].mutableCopy;
        [feedDicts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [entities addObject:[[FDFeedEntity alloc] initWithDictionary:obj]];
        }];
        self.prototypeEntitiesFromJSON = entities;
        
        // Callback
        dispatch_async(dispatch_get_main_queue(), ^{
            !then ?: then();
        });
    });
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
