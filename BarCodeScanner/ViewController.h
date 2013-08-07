//
//  ViewController.h
//  BarCodeScanner
//
//  Created by user on 29/07/13.
//  Copyright (c) 2013 Alitimetrik. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZBarSDK.h"


@interface ViewController : UIViewController <ZBarReaderDelegate,UIPickerViewDelegate,UIPickerViewDataSource>


@property (weak, nonatomic) IBOutlet UIImageView *resultImage;
@property (weak, nonatomic) IBOutlet UITextView *resultText;

- (IBAction) scanButtonTapped;

@end
