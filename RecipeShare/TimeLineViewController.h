//
//  TimeLineViewController.h
//  RecipeShare
//
//  Created by D L on 5/3/14.
//  Copyright (c) 2014 SongShiyu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QuadCurveMenu.h"
@interface TimeLineViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UINavigationControllerDelegate,QuadCurveMenuDelegate>

@property (strong, nonatomic) IBOutlet UITableView *timeLineTable;
- (IBAction)manage:(id)sender;

@end
