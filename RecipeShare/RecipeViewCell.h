//
//  RecipeViewCell.h
//  RecipeShare
//
//  Created by Zhan Shu on 4/28/14.
//  Copyright (c) 2014 SongShiyu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RecipeViewCell : UITableViewCell



@property (weak, nonatomic) IBOutlet UIImageView *recipeImage1;
@property (weak, nonatomic) IBOutlet UIImageView *recipeImage2;
- (IBAction)loadRecipe1:(id)sender;
- (IBAction)loadRecipe2:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *load1;
@property (weak, nonatomic) IBOutlet UIButton *load2;
@property (nonatomic, retain) NSDictionary *detailData1;
@property (nonatomic, retain) NSDictionary *detailData2;
@property  int choose;
@end
