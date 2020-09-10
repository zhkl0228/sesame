//
//  InterfaceController.m
//  sesame WatchKit Extension
//
//  Created by 廖正凯 on 2020/9/8.
//  Copyright © 2020 廖正凯. All rights reserved.
//

#import "InterfaceController.h"

@interface InterfaceController ()

@property (weak, nonatomic) IBOutlet WKInterfaceLabel* guardLabel;

@end


@implementation InterfaceController

static InterfaceController *instance;

+ (InterfaceController *)sharedController {
    return instance;
}

- (void)setGuardName: (NSString *) guardName {
    if(guardName) {
        [[self guardLabel] setText:guardName];
    } else {
        [[self guardLabel] setText:@"芝麻开门"];
    }
}

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];

    instance = self;
    NSLog(@"awakeWithContext context=%@, guardLabel=%@", context, self.guardLabel);
    [self setGuardName:nil];
}

- (void)willActivate {
    [super willActivate];

    NSLog(@"willActivate guardLabel=%@", self.guardLabel);
}

- (void)didDeactivate {
    [super didDeactivate];

    NSLog(@"didDeactivate guardLabel=%@", self.guardLabel);
}

@end



