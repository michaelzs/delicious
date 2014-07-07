//
//  TimeLineCommentViewController.h
//  RecipeShare
//
//  Created by D L on 5/11/14.
//  Copyright (c) 2014 SongShiyu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TimeLineCommentViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,UIAlertViewDelegate>
@property (strong, nonatomic) IBOutlet UILabel *text;

@property (strong, nonatomic) IBOutlet UILabel *time;
@property (strong, nonatomic) IBOutlet UILabel *user;
@property (strong, nonatomic) IBOutlet UIImageView *head;
@property (strong, nonatomic) IBOutlet UITableView *comments;
@property (strong, nonatomic) IBOutlet UITextField *myComment;
@property (strong, nonatomic) NSMutableDictionary *data;
@property (strong, nonatomic) IBOutlet UIImageView *image;
@property (strong, nonatomic) NSString *icon;
- (IBAction)send:(id)sender;
@property (strong, nonatomic) IBOutlet UILabel *text2;

@end
