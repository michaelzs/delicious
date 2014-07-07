//
//  TimeLineCommentTableViewCell.h
//  RecipeShare
//
//  Created by D L on 5/11/14.
//  Copyright (c) 2014 SongShiyu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TimeLineCommentTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *comment;
@property (strong, nonatomic) IBOutlet UILabel *name;
@property (strong, nonatomic) IBOutlet UILabel *time;
@property (strong, nonatomic) IBOutlet UIImageView *head;

@end
