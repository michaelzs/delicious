//
//  ManageFollowTableViewCell.m
//  RecipeShare
//
//  Created by D L on 5/11/14.
//  Copyright (c) 2014 SongShiyu. All rights reserved.
//

#import "ManageFollowTableViewCell.h"

@implementation ManageFollowTableViewCell

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

- (IBAction)delete:(id)sender {
    if ([self.deleteButton.titleLabel.text isEqualToString:@"Delete"])
    {
        [sender setTitle:@"Deleted" forState:UIControlStateNormal];
        if ([self.delegate respondsToSelector:@selector(cellDeleteAtIndexpath:)]) {
            
            //activate delegate method
            [self.delegate cellDeleteAtIndexpath:self.path];
        }
    }
    else
    {
        [sender setTitle:@"Delete" forState:UIControlStateNormal];
        if ([self.delegate respondsToSelector:@selector(cellCancelDeleteAtIndexpath:)]) {
            
            //activate delegate method
            [self.delegate cellCancelDeleteAtIndexpath:self.path];        }
    }
}
@end
