//
//  ViewController.m
//  HillClimbing
//
//  Created by Claudio Santos on 3/20/15.
//  Copyright (c) 2015 Claudio Santos. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

#define ARC4RANDOM_MAX 0x100000000

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    for (NSInteger counter = 1; counter <= 100; counter++) {
        NSLog(@"------ try %li ------", (long)counter);
        NSLog(@"Final result for hillClimbingWithSteps: %f",[self hillClimbingWithSteps:1000]);
        NSLog(@"Final result for iteractiveHillClimbingWithSteps: %f",[self iteractiveHillClimbingWithSteps:1000 seeds:50]);
        NSLog(@"Final result for stochasticHillClimbingWithSteps: %f",[self stochasticHillClimbingWithSteps:1000]);
        NSLog(@"------ end try %li ------ \n\n", (long)counter);
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(float)stochasticHillClimbingWithSteps:(NSInteger)steps{
    float initialValue = [self randonBetweenMinimunValue:-100 andMaximunValue:100];
    float result = [self functionForHillClimbingWithInitialValue:initialValue];
    for (NSInteger counter = 1; counter <= steps; counter++) {
        float newTestValue = [self upsetSeed:initialValue];
        float newResult = [self functionForHillClimbingWithInitialValue:newTestValue];
        
        NSInteger T = steps - counter;
        
        float chancesToChange = [self randonBetweenMinimunValue:0 andMaximunValue:1];
        float chancesNotToChange = exp(1/(newResult - result)/T);
        
        if (chancesToChange < chancesNotToChange) {
            result = newResult;
            initialValue = newTestValue;
        }
    }
    
    return result;
}


-(float)iteractiveHillClimbingWithSteps:(NSInteger)steps seeds:(int)seeds{
    float initialValue = [self randonBetweenMinimunValue:-100 andMaximunValue:100];
    float result = [self functionForHillClimbingWithInitialValue:initialValue];
    for (NSInteger counter = 1; counter <= steps; counter++) {
        float newTestValue = [self hillClimbingWithSteps:1000];
        if (newTestValue < result) {
            result = newTestValue;
        }
    }
    return result;
}

-(float)hillClimbingWithSteps:(NSInteger)steps{
    float initialValue = [self randonBetweenMinimunValue:-100 andMaximunValue:100];
    float result = [self functionForHillClimbingWithInitialValue:initialValue];
    for (NSInteger counter = 1; counter <= steps; counter++) {
        float newTestValue = [self upsetSeed:initialValue];
        float newResult = [self functionForHillClimbingWithInitialValue:newTestValue];
        if (newResult < result) {
            result = newResult;
            initialValue = newTestValue;
        }
    }
    
    return result;
}



-(float)functionForHillClimbingWithInitialValue:(float)initialValue{
    return initialValue*initialValue*initialValue + initialValue + 3;
}

-(float)randonBetweenMinimunValue:(float)minimunValue andMaximunValue:(float)maximunValue{
    return ((float)arc4random() / ARC4RANDOM_MAX * (maximunValue - minimunValue)) + minimunValue;
}

-(float)upsetSeed:(float)seed{
    return seed + [self randonBetweenMinimunValue:-1 andMaximunValue:1];
}

@end
