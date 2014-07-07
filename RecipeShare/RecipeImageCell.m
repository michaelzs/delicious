//
//  RecipeImageCell.m
//  RecipeShare
//
//  Created by Zhan Shu on 5/5/14.
//  Copyright (c) 2014 SongShiyu. All rights reserved.
//

#import "RecipeImageCell.h"

@implementation RecipeImageCell
@synthesize RecipeImage;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
