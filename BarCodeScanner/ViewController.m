//
//  ViewController.m
//  BarCodeScanner
//
//  Created by ShriHarsha on 29/07/13.
//  Copyright (c) 2013 Alitimetrik. All rights reserved.

#import "ViewController.h"
#import "XMLWriter.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    __autoreleasing  UIPickerView *pickerView = [[UIPickerView alloc] initWithFrame:CGRectZero];
    
    pickerView.delegate = self;
    
    pickerView.dataSource = self;
    
    pickerView.showsSelectionIndicator = YES;
    
    CGAffineTransform t0 = CGAffineTransformMakeTranslation (0, pickerView.bounds.size.height/2);
    
    CGAffineTransform s0 = CGAffineTransformMakeScale(0.7, 0.7);
    
    CGAffineTransform t1 = CGAffineTransformMakeTranslation (0, -pickerView.bounds.size.height/2);
    
    pickerView.frame = CGRectMake(235, 110, 60, 162);
    
    pickerView.transform = CGAffineTransformConcat(t0, CGAffineTransformConcat(s0, t1));
    
    pickerView.transform = CGAffineTransformRotate(pickerView.transform, -M_PI/2);
    
    [self.view addSubview: pickerView];
    
	// Do any additional setup after loading the view, typically from a nib.
}

-(UIView *) pickerView: (UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view

{
    
    CGRect rect = CGRectMake(0, 0, 230, 21);
    
    UILabel * label = [[UILabel alloc]initWithFrame:rect];
    
    label.text = @"1 2 3 4 5 6 7 8 9 0";
    
    label.opaque = NO;
    
    label.textAlignment = UITextAlignmentCenter;
    
    label.backgroundColor = [UIColor clearColor];
    
    label.clipsToBounds = YES;
    
    label.transform = CGAffineTransformRotate(label.transform, M_PI/2);
    
    return label;
    
}

// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {

    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{

    return 1;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction) scanButtonTapped {

    NSLog(@"TBD: scan barcode here...!");
    
    // ADD: present a barcode reader that scans from the camera feed
    ZBarReaderViewController *reader = [ZBarReaderViewController new];
    reader.readerDelegate = self;
    reader.supportedOrientationsMask = ZBarOrientationMaskAll;
    
    ZBarImageScanner *scanner = reader.scanner;
    // TODO: (optional) additional reader configuration here
    
    // EXAMPLE: disable rarely used I2/5 to improve performance
    [scanner setSymbology: ZBAR_I25
                   config: ZBAR_CFG_ENABLE
                       to: 0];
    
    // present and release the controller
    [self presentModalViewController: reader
                            animated: YES];
}

- (void) imagePickerController: (UIImagePickerController*) reader
 didFinishPickingMediaWithInfo: (NSDictionary*) info
{
    // ADD: get the decode results
    id<NSFastEnumeration> results =
    [info objectForKey: ZBarReaderControllerResults];
    ZBarSymbol *symbol = nil;
    for(symbol in results)
        // EXAMPLE: just grab the first barcode
        break;
    
    // EXAMPLE: do something useful with the barcode data
    self.resultText.text = symbol.data;
    
    // EXAMPLE: do something useful with the barcode image
    self.resultImage.image = [info objectForKey: UIImagePickerControllerOriginalImage];
    
    
    XMLWriter *xml_writer = [[XMLWriter alloc]init];
    [xml_writer writeStartDocumentWithEncodingAndVersion:@"UTF-8" version:@"1.0"];
    [xml_writer writeStartElement:@"WA2WCGetProductRequest"];
    [xml_writer writeStartElement:@"User"]; 
    [xml_writer writeCharacters:@"dhanraj@gmail.com"];
    [xml_writer writeEndElement];
    [xml_writer writeStartElement:@"BarcodeDetail"];
    
    [xml_writer writeStartElement:@"BarCode"];
    [xml_writer writeCharacters:self.resultText.text];
    [xml_writer writeEndElement];

    [xml_writer writeEndElement];
    [xml_writer writeEndElement];
    
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSData *data = nil;
    
    NSString *urlString = @"http://192.168.1.65:5050/wp-stub/api/getProductInfo";

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[[NSURL URLWithString:urlString] standardizedURL]];
    
    NSData *scannedDetails = [[xml_writer toString] dataUsingEncoding:NSUTF8StringEncoding];
    
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:scannedDetails];
    [request setValue:@"application/xml" forHTTPHeaderField:@"Content-Type"];
    [request setTimeoutInterval:15];
    [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
    
    NSLog(@"%@ \nis the HTTP request description" , [request description]);
    
    data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if (data == nil) {
        
        if (error != nil) {
            NSString *errorIdentifier = [NSString stringWithFormat:@"(%@)[%d]",error.domain,error.code];
            NSLog(@"%@ \n is the error error on connecting to the server." , errorIdentifier);
            
        }
    }
    NSString *respondedData=[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"%@ \n is the response data from the server." , respondedData);

    
    // ADD: dismiss the controller (NB dismiss from the *reader*!)
    [reader dismissModalViewControllerAnimated: YES];
}

@end
