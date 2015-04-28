//
//  ViewController.m
//  HillClimbing
//
//  Created by Claudio Santos on 3/20/15.
//  Copyright (c) 2015 Claudio Santos. All rights reserved.
//

#import "ViewController.h"
#import "GeneticAlgorithm.h"

@interface ViewController ()

@property(nonatomic, strong)NSMutableArray *iteractionsForHillClimbing;
@property(nonatomic, strong)NSMutableArray *iteractionsForSimulatedAnnealing;

@end

@implementation ViewController

#define ARC4RANDOM_MAX 0x100000000
#define STOPCONDITION 100


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.iteractionsForHillClimbing = [NSMutableArray new];
    self.iteractionsForSimulatedAnnealing = [NSMutableArray new];
    
    for (NSInteger counter = 1; counter <= 100; counter++) {
        NSLog(@"------ try %li ------", (long)counter);
        NSLog(@"Final result for hillClimbingWithNoSteps: %f",[self hillClimbingWithNoStepsWithLog:YES]);
        NSLog(@"Final result for hillClimbingWithSteps: %f",[self hillClimbingWithSteps:1000]);
        NSLog(@"Final result for iteractiveHillClimbingWithSeeds: %f",[self iteractiveHillClimbingWithSeeds:50]);
        NSLog(@"Final result for iteractiveHillClimbingWithSteps: %f",[self iteractiveHillClimbingWithSteps:1000 seeds:50]);
        NSLog(@"Final result for stochasticHillClimbingWithSteps: %f",[self stochasticHillClimbingWithSteps:1000]);
        NSLog(@"Final result for simulatedAnnealingWithinitialTemperature: %f",[self simulatedAnnealingWithInitialTemperature:373]);
        NSLog(@"Final result for simulatedAnnealingWithSteps: %f",[self simulatedAnnealingWithSteps:10000 initialTemperature:373]);
        NSLog(@"------ end try %li ------ \n\n", (long)counter);
        
    }
    
    GeneticAlgorithm *test = [GeneticAlgorithm new];
    [test calculateBestValue];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(float)simulatedAnnealingWithSteps:(NSInteger)steps initialTemperature:(float)temperature{
    //cfsantos: I decided to work with values between 0 and 1
    float initialValue = [self randonBetweenMinimunValue:0 andMaximunValue:1];
    float result = [self functionForHillClimbingWithInitialValue:initialValue];
    
    //cfsantos: stop criteria - the number of steps
    for (NSInteger counter = 1; counter <= steps; counter++) {
        float newTestValue = [self upsetSeed:initialValue];
        float newResult = [self functionForHillClimbingWithInitialValue:newTestValue];
        //cfsantos: if newResult is better than older result, I replace the values
        if (newResult > result) {
            result = newResult;
            initialValue = newTestValue;
        } else {
            float chancesToChange = [self randonBetweenMinimunValue:0 andMaximunValue:1];
            float chancesNotToChange = exp((newResult - result)/temperature);
            
            //cfsantos: simulated annealing in action - here I decide if I will replace the older value by chance or not
            if (chancesToChange < chancesNotToChange) {
                result = newResult;
                initialValue = newTestValue;
            }
        }
        temperature = [self reduceTemperature:temperature];
    }
    
    return result;
    
}

-(float)simulatedAnnealingWithInitialTemperature:(float)temperature{

    NSDate *start = [NSDate date];
    //cfsantos: I decided to work with values between 0 and 1
    float initialValue = [self randonBetweenMinimunValue:0 andMaximunValue:1];
    float result = [self functionForHillClimbingWithInitialValue:initialValue];
    
    int stopCondition = 0;
    int iteraction = 0;
    //cfsantos: stop criteria - the number of steps
    while (stopCondition < STOPCONDITION) {
        stopCondition++;
        
        float newTestValue = [self upsetSeed:initialValue];
        float newResult = [self functionForHillClimbingWithInitialValue:newTestValue];
        //cfsantos: if newResult is better than older result, I replace the values
        if (newResult > result) {
            result = newResult;
            initialValue = newTestValue;
            stopCondition = 0;
        } else {
            float chancesToChange = [self randonBetweenMinimunValue:0 andMaximunValue:1];
            float chancesNotToChange = exp((newResult - result)/temperature);
            
            //cfsantos: simulated annealing in action - here I decide if I will replace the older value by chance or not
            if (chancesToChange < chancesNotToChange) {
                result = newResult;
                initialValue = newTestValue;
                stopCondition = 0;
            }
        }
        temperature = [self reduceTemperature:temperature];
        
        iteraction++;
    }
    
    [self.iteractionsForSimulatedAnnealing addObject:@(iteraction)];
    
    NSLog(@"Best on simulatedAnnealingWithInitialTemperature on iteraction %d temperature %f time %f", iteraction, temperature, -[start timeIntervalSinceNow]);
    
    return result;
    
}


-(float)stochasticHillClimbingWithSteps:(NSInteger)steps{
    float initialValue = [self randonBetweenMinimunValue:0 andMaximunValue:1];
    float result = [self functionForHillClimbingWithInitialValue:initialValue];
    for (NSInteger counter = 1; counter <= steps; counter++) {
        float newTestValue = [self upsetSeed:initialValue];
        float newResult = [self functionForHillClimbingWithInitialValue:newTestValue];
        
        NSInteger T = steps - counter;
        
        float chancesToChange = [self randonBetweenMinimunValue:0 andMaximunValue:1];
        float chancesNotToChange = exp(1/(result - newResult)/T);
        
        if (chancesToChange < chancesNotToChange) {
            result = newResult;
            initialValue = newTestValue;
        }
    }
    
    
    
    return result;
}

-(float)iteractiveHillClimbingWithSeeds:(int)seeds{
    float initialValue = [self randonBetweenMinimunValue:0 andMaximunValue:1];
    float result = [self functionForHillClimbingWithInitialValue:initialValue];
    
    int stopCondition = 0;
    int iteraction = 0;
    while (stopCondition < STOPCONDITION) {
        stopCondition++;
        for (NSInteger counter = 1; counter <= seeds; counter++) {
            float newTestValue = [self hillClimbingWithNoStepsWithLog:NO];
            if (newTestValue > result) {
                result = newTestValue;
                stopCondition = 0;
            }
        }
        iteraction++;
    }
    
    NSLog(@"Best result on iteractiveHillClimbingWithSeeds found on iteraction %d",iteraction);
    
    return result;
}


-(float)iteractiveHillClimbingWithSteps:(NSInteger)steps seeds:(int)seeds{
    float initialValue = [self randonBetweenMinimunValue:0 andMaximunValue:1];
    float result = [self functionForHillClimbingWithInitialValue:initialValue];
    for (NSInteger counter = 1; counter <= steps; counter++) {
        float newTestValue = [self hillClimbingWithSteps:100];
        if (newTestValue > result) {
            result = newTestValue;
        }
    }
    return result;
}

-(float)hillClimbingWithNoStepsWithLog:(BOOL)hasLog{
    
    NSDate *start = [NSDate date];
    
    //cfsantos: get a randon value between 0 and 1
    float initialValue = [self randonBetweenMinimunValue:0 andMaximunValue:1];
    
    //cfsantos: calculate de value of the function for this number
    float result = [self functionForHillClimbingWithInitialValue:initialValue];
    
    int stopCondition = 0;
    int iteraction = 0;
    
    //cfsantos: iteract the number of steps given
    while (stopCondition < STOPCONDITION) {
        stopCondition++;
        float newTestValue = [self upsetSeed:initialValue];
        //cfsantos: calculate the value of this function after upset the seed
        float newResult = [self functionForHillClimbingWithInitialValue:newTestValue];
        
        //cfsantos: if the new result is better than original, replace the return value
        if (newResult > result) {
            
            result = newResult;
            initialValue = newTestValue;
            stopCondition = 0;
        }
        iteraction++;
        
    }
    if (hasLog)
         NSLog(@"Best result on hillClimbingWithNoSteps found on iteraction %d time %f",iteraction, -[start timeIntervalSinceNow]);
   
    return result;
}


-(float)hillClimbingWithSteps:(NSInteger)steps{
    //cfsantos: get a randon value between 0 and 1
    float initialValue = [self randonBetweenMinimunValue:0 andMaximunValue:1];
    
    //cfsantos: calculate de value of the function for this number
    float result = [self functionForHillClimbingWithInitialValue:initialValue];
    
    int stopCondition = 0;
    
    
    //cfsantos: iteract the number of steps given
    for (NSInteger counter = 1; counter <= steps; counter++) {
        float newTestValue = [self upsetSeed:initialValue];
        //cfsantos: calculate the value of this function after upset the seed
        float newResult = [self functionForHillClimbingWithInitialValue:newTestValue];
        
        //cfsantos: if the new result is better than original, replace the return value
        if (newResult > result) {
            
            result = newResult;
            initialValue = newTestValue;
        }
        

    }
    
    return result;
}

-(float)hillClimbingWithSteps:(NSInteger)steps initialValue:(float)value{
    float initialValue;
    
    initialValue = (value ? value : [self randonBetweenMinimunValue:-100 andMaximunValue:100]);

    float result = [self functionForHillClimbingWithInitialValue:initialValue];
    for (NSInteger counter = 1; counter <= steps; counter++) {
        float newTestValue = [self upsetSeed:initialValue];
        float newResult = [self functionForHillClimbingWithInitialValue:newTestValue];
        if (newResult > result) {
            result = newResult;
            initialValue = newTestValue;
        }
        
        NSLog(@"result = %f, newResult = %f", result, newResult);
    }
    
    return result;
}


-(float)reduceTemperature:(float)temperature{
    return temperature * 0.99;
}

/*-(float)functionForHillClimbingWithInitialValue:(float)initialValue{
    return initialValue*initialValue*initialValue + initialValue + 3;
}*/

-(float)functionForHillClimbingWithInitialValue:(float)initialValue{
    float part1 = (initialValue - 0.1) / 0.9;
    float part2 = powf(part1, 2);
    float part25 = -2*part2;
    float part3 = powf(2, part25);
    
    float part4 = powf(sin(5 * 3.14 * initialValue), 6);
    return part3 * part4;
    //return powf(2, powf(-2*(initialValue - 0.1) / (0.9), 2)) * sin(5*3.14*initialValue);

}

-(float)randonBetweenMinimunValue:(float)minimunValue andMaximunValue:(float)maximunValue{
    return ((float)arc4random() / ARC4RANDOM_MAX * (maximunValue - minimunValue)) + minimunValue;
}

-(float)upsetSeed:(float)seed{
    return seed + [self randonBetweenMinimunValue:-0.1 andMaximunValue:0.1];
}

#pragma mark - CSV File

-(void)createCSVFile{
//    NSMutableString *strOutput = [NSMutableString stringWithCapacity:1000];
//    
//    CkoCsv *csv = [[[CkoCsv alloc] init] autorelease];
//    
//    //  Indicate that the 1st row
//    //  should be treated as column names:
//    csv.HasColumnNames = YES;
//    
//    [csv SetColumnName: [NSNumber numberWithInt: 0] columnName: @"year"];
//    [csv SetColumnName: [NSNumber numberWithInt: 1] columnName: @"color"];
//    [csv SetColumnName: [NSNumber numberWithInt: 2] columnName: @"country"];
//    [csv SetColumnName: [NSNumber numberWithInt: 3] columnName: @"food"];
//    
//    [csv SetCell: [NSNumber numberWithInt: 0] col: [NSNumber numberWithInt: 0] content: @"2001"];
//    [csv SetCell: [NSNumber numberWithInt: 0] col: [NSNumber numberWithInt: 1] content: @"red"];
//    [csv SetCell: [NSNumber numberWithInt: 0] col: [NSNumber numberWithInt: 2] content: @"France"];
//    [csv SetCell: [NSNumber numberWithInt: 0] col: [NSNumber numberWithInt: 3] content: @"cheese"];
//    
//    [csv SetCell: [NSNumber numberWithInt: 1] col: [NSNumber numberWithInt: 0] content: @"2005"];
//    [csv SetCell: [NSNumber numberWithInt: 1] col: [NSNumber numberWithInt: 1] content: @"blue"];
//    [csv SetCell: [NSNumber numberWithInt: 1] col: [NSNumber numberWithInt: 2] content: @"United States"];
//    [csv SetCell: [NSNumber numberWithInt: 1] col: [NSNumber numberWithInt: 3] content: @"hamburger"];
//    
//    //  Write the CSV to a string and display:
//    NSString *csvDoc;
//    csvDoc = [csv SaveToString];
//    [strOutput appendString: csvDoc];
//    [strOutput appendString: @"\n"];
//    
//    BOOL success;
//    
//    //  Save the CSV to a file:
//    success = [csv SaveFile: @"out.csv"];
//    if (success != YES) {
//        [strOutput appendString: csv.LastErrorText];
//        [strOutput appendString: @"\n"];
//    }
//
//    
}


@end
