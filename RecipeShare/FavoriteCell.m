//
//  FavoriteCell.m
//  RecipeShare
//
//  Created by SongShiyu on 5/5/14.
//  Copyright (c) 2014 SongShiyu. All rights reserved.
//

#import "FavoriteCell.h"


@implementation FavoriteCell

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
