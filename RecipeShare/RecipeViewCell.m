//
//  RecipeViewCell.m
//  RecipeShare
//
//  Created by Zhan Shu on 4/28/14.
//  Copyright (c) 2014 SongShiyu. All rights reserved.
//

#import "RecipeViewCell.h"
@implementation RecipeViewCell
@synthesize detailData1;
@synthesize detailData2;
@synthesize choose;


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

- (IBAction)loadRecipe1:(id)sender {

    
}

- (IBAction)loadRecipe2:(id)sender {
 

}
/*
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    UIViewController *viewControler=segue.destinationViewController;
    RecipeDetailViewController *detail=(RecipeDetailViewController *)viewControler;
    if (self.choose==1){
        detail.detailData=self.detailData1;
        NSLog(@"%@",self.detailData1);
    }
    else{
        detail.detailData=self.detailData2;
        NSLog(@"%@",self.detailData2);
    }
    
}*/
@end
