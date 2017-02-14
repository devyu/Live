//
//  TableViewController.m
//  LiveDemo
//
//  Created by mac on 2017/2/9.
//  Copyright © 2017年 JY. All rights reserved.
//

#import "TableViewController.h"
#import "CatchImageViewController.h"
#import "CatchVideoViewController.h"
#import "CatchAudioAndVideoViewController.h"
#import "BeautifyFilterViewController.h"

@interface TableViewController ()
@property (strong, nonatomic) NSArray *dataSource;
@end


static NSString *const cellIdent = @"liveCell";
@implementation TableViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  _dataSource = @[@"捕捉图片(真机)", @"捕捉视频(真机)", @"捕捉音视频(真机)", @"使用GPUImage美颜", @"保存美颜处理后的视频"];
  [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellIdent];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return _dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdent forIndexPath:indexPath];
  cell.textLabel.text = _dataSource[indexPath.row];
  return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.row == 0) {
    [self.navigationController pushViewController:[CatchImageViewController new] animated:YES];
  } else if (indexPath.row == 1) {
    [self.navigationController pushViewController:[CatchVideoViewController new] animated:YES];
  } else if (indexPath.row == 2) {
    [self.navigationController pushViewController:[CatchAudioAndVideoViewController new] animated:YES];
  } else if (indexPath.row == 3) {
    [self performSegueWithIdentifier:@"BeautifyFilterVC" sender:indexPath];
  } else if (indexPath.row == 4) {
    [self performSegueWithIdentifier:@"VideoRecordingSegue" sender:indexPath];
  }
}




/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  NSIndexPath *index = sender;
  UIViewController *destionationVC = [segue destinationViewController];
  destionationVC.title = [NSString stringWithFormat:@"%@", self.dataSource[index.row]];
}

@end
