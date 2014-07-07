//
//  ManageFollowViewController.h
//  RecipeShare
//
//  Created by D L on 5/11/14.
//  Copyright (c) 2014 SongShiyu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ManageFollowTableViewCell.h"
@interface ManageFollowViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,ManageCellDelegate>
@property (strong, nonatomic) IBOutlet UITableView *table;
- (IBAction)confirm:(id)sender;

@end
