//
//  ManageFollowTableViewCell.h
//  RecipeShare
//
//  Created by D L on 5/11/14.
//  Copyright (c) 2014 SongShiyu. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol ManageCellDelegate <NSObject>

@optional
-(void)cellDeleteAtIndexpath:(NSIndexPath*)path;
-(void)cellCancelDeleteAtIndexpath:(NSIndexPath*)path;
@end
@interface ManageFollowTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *name;
@property (strong, nonatomic) IBOutlet UIImageView *head;
- (IBAction)delete:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *deleteButton;
@property(nonatomic, strong)id <ManageCellDelegate> delegate;
@property(nonatomic, strong) NSIndexPath *path;
@end
