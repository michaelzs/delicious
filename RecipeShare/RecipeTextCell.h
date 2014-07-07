//
//  RecipeTextCell.h
//  RecipeShare
//
//  Created by Zhan Shu on 5/5/14.
//  Copyright (c) 2014 SongShiyu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RecipeTextCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *user;

@property (weak, nonatomic) IBOutlet UILabel *name;

@property (weak, nonatomic) IBOutlet UILabel *ingredient;

@property (weak, nonatomic) IBOutlet UILabel *process1;
@property (weak, nonatomic) IBOutlet UILabel *process2;

@property (weak, nonatomic) IBOutlet UILabel *process3;

@end
