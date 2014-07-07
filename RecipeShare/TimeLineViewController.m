//
//  TimeLineViewController.m
//  RecipeShare
//
//  Created by D L on 5/3/14.
//  Copyright (c) 2014 SongShiyu. All rights reserved.
//

#import "TimeLineViewController.h"
#import "TimeLineCell.h"
#import "Constants.h"
#import <AWSRuntime/AWSRuntime.h>
#import <AWSS3/AWSS3.h>
#import <AWSDynamoDB/AWSDynamoDB.h>
#import "MBProgressHUD.h"
#import "ss4556AppDelegate.h"
#import "TimeLineCommentViewController.h"
@interface TimeLineViewController ()
@property (nonatomic, retain) AmazonS3Client *s3;
@property (nonatomic, retain) AmazonDynamoDBClient *ddb;
@property (nonatomic, strong)NSMutableArray *tableData;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) NSMutableDictionary *icons;
@property (nonatomic, strong) NSString *uid;
@property (nonatomic, strong) NSMutableArray *followee;
@property (nonatomic, strong) NSString *refreshFlag;
@property (nonatomic, strong) NSMutableDictionary *sendData;
@end

@implementation TimeLineViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)viewWillAppear:(BOOL)animated{
    [self loadFollower];
    [self loadData:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.timeLineTable reloadData];
        });
    }];
    [super viewDidLoad];
}
#pragma mark load the follower list
- (void)loadFollower
{
    ss4556AppDelegate *appDelegate=[[UIApplication sharedApplication] delegate];
    self.uid= appDelegate.username;
    AmazonCredentials *credentials = [[AmazonCredentials alloc] initWithAccessKey:ACCESS_KEY_ID withSecretKey:SECRET_KEY];
    self.ddb = [[AmazonDynamoDBClient alloc] initWithCredentials:credentials];
    NSMutableArray *follower = [[NSMutableArray alloc]init];
    @try {
        DynamoDBCondition *condition = [DynamoDBCondition new];
        condition.comparisonOperator = @"EQ";
        DynamoDBAttributeValue * ID= [[DynamoDBAttributeValue alloc] initWithS:self.uid];
        [condition addAttributeValueList:ID];
        NSMutableDictionary *queryStartKey = nil;
        do {
            DynamoDBQueryRequest *queryRequest = [DynamoDBQueryRequest new];
            queryRequest.tableName = @"Followed";
            queryRequest.exclusiveStartKey = queryStartKey;
            queryRequest.keyConditions = [NSMutableDictionary dictionaryWithObject:condition forKey:@"UID2"];
            DynamoDBQueryResponse *queryResponse = [ self.ddb query:queryRequest];
            for (NSDictionary *dic in  queryResponse.items) {
                DynamoDBAttributeValue *flag = [dic objectForKey:@"Flag"];
                if ([flag.s isEqualToString:@"1"]) {
                    
                }
                DynamoDBAttributeValue *uid =[dic objectForKey:@"UID1"];
                [follower addObject:uid.s];
            }
            queryStartKey = queryResponse.lastEvaluatedKey;
            //NSLog(@"lastevaluatedkey = '%@'", queryStartKey );
        } while ([queryStartKey count] != 0);
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception);
    }
    @finally {
        
    }
    appDelegate.followed = follower;
    self.followee = follower;
}
- (void)viewDidLoad
{
    ss4556AppDelegate *appDelegate=[[UIApplication sharedApplication] delegate];
    self.uid= appDelegate.username;
    self.followee = appDelegate.followed;
    self.refreshControl = [[UIRefreshControl alloc]init];
    [self.timeLineTable addSubview:self.refreshControl];
    [self.refreshControl addTarget:self action:@selector(refreshTable) forControlEvents:UIControlEventValueChanged];
    //self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
    //self.timeLineTable.refreshControl = refresh;
    //set the QuardMenu
    UIImage *storyMenuItemImage = [UIImage imageNamed:@"bg-menuitem.png"];
    UIImage *storyMenuItemImagePressed = [UIImage imageNamed:@"bg-menuitem-highlighted.png"];
    // message MenuItem.
    CGSize size = CGSizeMake(40.0f, 40.0f);
    QuadCurveMenuItem *messageMenuItem = [[QuadCurveMenuItem alloc] initWithImage:storyMenuItemImage
                                                                highlightedImage:storyMenuItemImagePressed
                                                                    ContentImage:[self imageByScalingAndCroppingForSize:size from:[UIImage imageNamed:@"message-icon.png"]]
                                                         highlightedContentImage:nil];
    // photo MenuItem.
    QuadCurveMenuItem *photoMenuItem = [[QuadCurveMenuItem alloc] initWithImage:storyMenuItemImage
                                                                highlightedImage:storyMenuItemImagePressed
                                                                    ContentImage:[self imageByScalingAndCroppingForSize:size from:[UIImage imageNamed:@"addimage.png"]]
                                                        highlightedContentImage:nil];
    QuadCurveMenuItem *cameraMenuItem = [[QuadCurveMenuItem alloc] initWithImage:storyMenuItemImage
                                                               highlightedImage:storyMenuItemImagePressed
                                                                   ContentImage:[self imageByScalingAndCroppingForSize:size from:[UIImage imageNamed:@"camera-icon.png"]]
                                                        highlightedContentImage:nil];
    
    
    NSArray *menus = [NSArray arrayWithObjects:messageMenuItem, photoMenuItem,cameraMenuItem,nil];
    QuadCurveMenu *menu = [[QuadCurveMenu alloc] initWithFrame:self.view.bounds menus:menus];
    menu.delegate = self;
    [self.view addSubview:menu];
}
- (void)refreshTable {
    //TODO: refresh your data
    //self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Refreshing data..."];
    [self loadData:^{
        //NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        //[formatter setDateFormat:@"MMM d, h:mm a"];
        //NSString *lastUpdated = [NSString stringWithFormat:@"Last updated on %@",[formatter stringFromDate:[NSDate date]]];
        //self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:lastUpdated];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.timeLineTable reloadData];
            //[self.timeLineTable reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationMiddle];
            [self.refreshControl endRefreshing];
        });
    }];
}
#pragma mark load all the shares in batch
- (void)loadData:(void(^)())completion
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"Loading";
        [hud show:YES];
    self.refreshFlag = @"1";
    dispatch_async(loadQueue, ^{
        self.s3 = [[AmazonS3Client alloc] initWithAccessKey:ACCESS_KEY_ID withSecretKey:SECRET_KEY];
        self.s3.endpoint = [AmazonEndpoints s3Endpoint:US_WEST_2];
        AmazonCredentials *credentials = [[AmazonCredentials alloc] initWithAccessKey:ACCESS_KEY_ID withSecretKey:SECRET_KEY];
        self.ddb = [[AmazonDynamoDBClient alloc] initWithCredentials:credentials];
        NSMutableArray *temp = [[NSMutableArray alloc] init];
        
        @try {
            DynamoDBCondition *condition = [DynamoDBCondition new];
            condition.comparisonOperator = @"EQ";
            DynamoDBAttributeValue * ID= [[DynamoDBAttributeValue alloc] initWithS:self.uid];
            [condition addAttributeValueList:ID];
            
            NSMutableDictionary *queryStartKey = nil;
            do {
                DynamoDBQueryRequest *queryRequest = [DynamoDBQueryRequest new];
                queryRequest.tableName = @"TimeLine";
                queryRequest.exclusiveStartKey = queryStartKey;
                queryRequest.keyConditions = [NSMutableDictionary dictionaryWithObject:condition forKey:@"UID"];
                DynamoDBQueryResponse *queryResponse = [ self.ddb query:queryRequest];
                // Each item in the result set is a NSDictionary of DynamoDBAttributeValue
                for (NSDictionary *item in queryResponse.items) {
                    //DynamoDBAttributeValue *time = [item objectForKey:@"Time"];
                    //NSLog(@"Type = '%@'", item);
                    NSMutableDictionary *oneItem = [[NSMutableDictionary alloc]init];
                    DynamoDBAttributeValue *itemType = item[@"type"];
                    [oneItem setValue:[NSString stringWithFormat:@"%@",itemType.n] forKey:@"Type"];
                    DynamoDBAttributeValue *itemUID = item[@"UID2"];
                    [oneItem setValue:itemUID.s forKey:@"UID2"];
                    DynamoDBAttributeValue *itemTime = item[@"Time"];
                    [oneItem setValue:itemTime.s forKey:@"Time"];
                    DynamoDBAttributeValue *itemString1 = item[@"String1"];
                    [oneItem setValue:itemString1.s forKey:@"String1"];
                    if([itemType.n isEqualToString:@"1"]){
                        ;
                    }else if([itemType.n isEqualToString:@"2"]){
                        DynamoDBAttributeValue *itemString2 = item[@"String2"];
                        NSString *imagefile1=[NSString stringWithFormat:@"%@%@", @"https://s3-us-west-2.amazonaws.com/jaycolumbia12345/",itemString2.s];
                        NSLog(@"%@",imagefile1);
                        NSData *imageData1=[NSData dataWithContentsOfURL:[NSURL URLWithString:imagefile1]];
                        [oneItem setValue:imageData1 forKey:@"Image"];
                    }
                    [temp addObject:oneItem];                }
                
                // If the response lastEvaluatedKey has contents, that means there are more results
                queryStartKey = queryResponse.lastEvaluatedKey;
                //NSLog(@"lastevaluatedkey = '%@'", queryStartKey );
            } while ([queryStartKey count] != 0);
            self.tableData=temp;
            dispatch_sync(dispatch_get_main_queue(), ^{
                [hud hide:YES];
            });
        }
        @catch (NSException *exception) {
            NSLog(@"%@",exception);
        }
        @finally {
        }
        NSMutableDictionary *followYou = [[NSMutableDictionary alloc]init];
        for (NSString *iconUid in self.followee) {
            NSString *imagefile1=[NSString stringWithFormat:@"%@%@%@", @"https://s3-us-west-2.amazonaws.com/jaycolumbia12345/",iconUid,@"-profile.jpeg"];
            //NSLog(imagefile1);
            [followYou setObject:imagefile1 forKey:iconUid];
        }
        NSString *imagefile1=[NSString stringWithFormat:@"%@%@%@", @"https://s3-us-west-2.amazonaws.com/jaycolumbia12345/",self.uid,@"-profile.jpeg"];
        [followYou setObject:imagefile1 forKey:self.uid];
        self.icons = followYou;
        [self.timeLineTable reloadData];
        completion();
    });
}
#pragma mark menu selection
- (void)quadCurveMenu:(QuadCurveMenu *)menu didSelectIndex:(NSInteger)idx
{
    if(idx == 0){
        [self performSegueWithIdentifier:@"AddTimeLineText" sender:self];
    }else if (idx == 1) {
        [self performSegueWithIdentifier:@"AddTimeLineImage" sender:self];
    }else if(idx == 2){
        [self performSegueWithIdentifier:@"TimeLineToPhoto" sender:self];
    }else if(idx == 3){
        
    }

}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier ] isEqualToString:@"AddTimeLineText"]){
        
    }else if([[segue identifier ] isEqualToString:@"AddTimeLineImage"]){
        
    }else if([[segue identifier ] isEqualToString:@"TimeLineToComment"]){
        UITableViewController *viewControler=segue.destinationViewController;
        TimeLineCommentViewController *detail =(TimeLineCommentViewController *)viewControler;
        detail.data= self.sendData;
        detail.icon = [self.icons objectForKey:self.sendData[@"UID2"]];
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tableData.count;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString * identifier=@"TimeLineCell";
    TimeLineCell *cell=[tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell=[[TimeLineCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    NSMutableDictionary *data=[self.tableData objectAtIndex:self.tableData.count-1-indexPath.row];
    enum messageCellStyle style;
    if ([[data objectForKey:@"Type"] isEqualToString:TEXT_TYPE_STRING]) {
        //NSLog(@"It is a text");
        style = messageCellStyleText;
    }else if([[data objectForKey:@"Type"] isEqualToString:IMAGE_TYPE_STRING]){
        style = messageCellStyleImage;
    }else{
        style = messageCellStyleText;
    }
    switch (style) {
            case messageCellStyleText:
            //NSLog(@"set text");
            [cell setMessage:[data objectForKey:@"String1"]];
            [cell setChatTime:[data objectForKey:@"Time"] withUser:[data objectForKey:@"UID2"] tag:indexPath.row];
            [cell setHeadImage:[self.icons objectForKey:data[@"UID2"]] tag:indexPath.row];
            break;
            case messageCellStyleImage:
            [cell setChatImage:[data objectForKey:@"Image"] withText:[data objectForKey:@"String1"] tag:indexPath.row];
            [cell setHeadImage:[self.icons objectForKey:data[@"UID2"]] tag:indexPath.row];
            [cell setChatTime:[data objectForKey:@"Time"] withUser:[data objectForKey:@"UID2"] tag:indexPath.row];
            break;
            case messageCellStyleRecipe:
            [cell setHeadImage:NULL tag:indexPath.row];
            break;
            case messageCellStyleLocation:{
                [cell setHeadImage:NULL tag:indexPath.row];
            }
            break;
        default:
            break;
    }
    [cell setMsgStyle:style];
    return cell;
}

#pragma set so comeback still white
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)newIndexPath{
    self.sendData=[self.tableData objectAtIndex:self.tableData.count-1-newIndexPath.row];
    [self.timeLineTable deselectRowAtIndexPath:newIndexPath animated:YES];
    [self performSegueWithIdentifier:@"TimeLineToComment" sender:self];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* ddbType = self.tableData[self.tableData.count-1-indexPath.row][@"Type"];
    NSString *ddbString1 = [self.tableData[self.tableData.count-1-indexPath.row] objectForKey:@"String1"];
    NSString *ddbUID = self.tableData[self.tableData.count-1-indexPath.row][@"UID2"];
    NSString *ddbTime =self.tableData[self.tableData.count-1-indexPath.row][@"Time"];
    
    CGSize textSize=[ddbString1 boundingRectWithSize:CGSizeMake(320, TEXT_MAX_HEIGHT) options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) attributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:15], NSFontAttributeName, nil] context:nil].size;
    //CGSize textSize=[textC sizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:CGSizeMake((320-HEAD_SIZE-3*INSETS-40), TEXT_MAX_HEIGHT) lineBreakMode:NSLineBreakByWordWrapping];
    
    CGSize UIDSize=[ddbUID boundingRectWithSize:CGSizeMake(((320-HEAD_SIZE-3*INSETS-40)/2), TEXT_MAX_HEIGHT) options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) attributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:12], NSFontAttributeName,nil] context:nil].size;
    //CGSize userTextSize=[textU sizeWithFont:[UIFont systemFontOfSize:12] constrainedToSize:CGSizeMake(((320-HEAD_SIZE-3*INSETS-40)/2), TEXT_MAX_HEIGHT) lineBreakMode:NSLineBreakByWordWrapping];
    
    CGSize timeSize=[ddbTime boundingRectWithSize:CGSizeMake((320-HEAD_SIZE-3*INSETS-40), TEXT_MAX_HEIGHT) options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) attributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:11],NSFontAttributeName, nil] context:nil].size;
    //CGSize textSize=[ddbString1 sizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:CGSizeMake((320-HEAD_SIZE-3*INSETS-40), TEXT_MAX_HEIGHT) lineBreakMode:NSLineBreakByWordWrapping];
    //CGSize UIDSize=[ddbUID sizeWithFont:[UIFont systemFontOfSize:12] constrainedToSize:CGSizeMake(((320-HEAD_SIZE-3*INSETS-40)/2), TEXT_MAX_HEIGHT) lineBreakMode:NSLineBreakByWordWrapping];
    //CGSize timeSize=[ddbTime sizeWithFont:[UIFont systemFontOfSize:11] constrainedToSize:CGSizeMake((320-HEAD_SIZE-3*INSETS-40), TEXT_MAX_HEIGHT) lineBreakMode:NSLineBreakByWordWrapping];
    
    if( [ddbType integerValue]==messageTypeImage)
        
        return 100+textSize.height+5*INSETS+timeSize.height;
    else if ([ddbType integerValue]==messageTypeText){
        return (textSize.height+timeSize.height+INSETS*4>HEAD_SIZE+INSETS*3+UIDSize.height?textSize.height+timeSize.height+INSETS*4:HEAD_SIZE+INSETS*3+UIDSize.height);
    }else{
        return 100;
    }
}
#pragma mark resize image method
- (UIImage*)imageByScalingAndCroppingForSize:(CGSize)targetSize from:(UIImage*)image
{
    UIImage *sourceImage = image;
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    if (CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        if (widthFactor > heightFactor)
            scaleFactor = widthFactor; // scale to fit height
        else
            scaleFactor = heightFactor; // scale to fit width
        scaledWidth= width * scaleFactor;
        scaledHeight = height * scaleFactor;
        // center the image
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else if (widthFactor < heightFactor)
        {
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    UIGraphicsBeginImageContext(targetSize); // this will crop
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width= scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    [sourceImage drawInRect:thumbnailRect];
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil)
        NSLog(@"could not scale image");
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    return newImage;
}
- (IBAction)manage:(id)sender {
    [self performSegueWithIdentifier:@"TimeLineToManage" sender:self];
}
@end
