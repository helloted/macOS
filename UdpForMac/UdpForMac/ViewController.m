//
//  ViewController.m
//  UdpForMac
//
//  Created by 曹操 on 16/9/12.
//  Copyright © 2016年 Xydawn. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (weak) IBOutlet NSTextField *msgFiled;
@property (weak) IBOutlet NSTextField *ipFiled;
@property BOOL end;
@property (weak) IBOutlet NSTextField *statusLabel;

@end

@implementation ViewController
//{
//    UdpSocket *udp;
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    udp = [UdpSocket shareUdpScoket];

    // Do any additional setup after loading the view.
    
//    NSHost* myhost =[NSHost currentHost];
//    
//    NSString *ad = [myhost address];
//    
//    NSLog(@"%@",ad);
    
//    self.ipFiled.stringValue = @"";
    
  
    
    self.title = @"wifi广播助手 -- by Xydawn";
    
}
- (IBAction)pushBtnClick:(id)sender {
    
    self.end = YES  ;
    
    self.statusLabel.stringValue = @"正在发送";
    
    [self pushUdpLoop];
    


}
- (IBAction)endbtnClick:(id)sender {
    
    

    
    self.end = NO;
    
    self.statusLabel.stringValue = @"停止发送";
  
}

-(void)pushUdpLoop{
    

    

            

         
            
//        dispatch_async(dispatch_get_global_queue(0, 0), ^{
//                
//            while (self.end) {
//                
//                [NSThread sleepForTimeInterval:1];
//                
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    
//                    udp = [UdpSocket shareUdpScoket];
//                    
//                    [udp creatTCPSendWithMsg:self.msgFiled.stringValue andHost:self.ipFiled.stringValue andPort:9998];
//                });
//                
//           }
//                
//        });
//            
  
//
//    

}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

@end
