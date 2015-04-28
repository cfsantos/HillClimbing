//
//  GeneticAlgorithm.m
//  HillClimbing
//
//  Created by Claudio Santos on 4/21/15.
//  Copyright (c) 2015 Claudio Santos. All rights reserved.
//

#import "GeneticAlgorithm.h"

@interface GeneticAlgorithm ()

@property(nonatomic, strong)NSArray *bestDNA;
@property(nonatomic, strong)NSArray *parentsArray;
@property(nonatomic)int triesAfterGetBestDNA;

@end

#define ARC4RANDOM_MAX      0x100000000
#define MAXTRIESAFTERBESTVALUE 100

@implementation GeneticAlgorithm

-(void)calculateBestValue{
    NSMutableArray *fitnessArray = [NSMutableArray new];
    self.triesAfterGetBestDNA = 0;
    
    //starting my tests from 0
    self.bestDNA = @[@0,@0,@0,@0,@0,@0,@0,@0,@0,@0,@0,@0];
    
    //matrix used for comparing results
    self.parentsArray = @[    @[@0,@0,@0,@0,@0,@0,@0,@1,@0,@0,@0,@1],
                              @[@1,@0,@0,@0,@0,@0,@0,@1,@0,@0,@0,@0],
                              @[@0,@0,@0,@0,@0,@0,@0,@1,@0,@1,@0,@1],
                              @[@0,@0,@0,@0,@0,@1,@0,@1,@0,@1,@0,@0],
                              @[@0,@1,@0,@0,@0,@0,@0,@1,@0,@0,@0,@1],
                              @[@0,@0,@0,@0,@0,@0,@0,@1,@0,@0,@0,@0],
                              @[@1,@0,@0,@0,@0,@0,@0,@1,@0,@1,@0,@1],
                              @[@0,@0,@0,@0,@0,@0,@0,@1,@0,@1,@0,@0]  ];
    
//    self.parentsArray = @[@[@1,@0,@0,@0,@0,@1,@1,@1,@1,@0,@0,@0],
//      @[@0,@0,@1,@0,@0,@1,@1,@0,@1,@0,@1,@0],
//      @[@0,@0,@0,@1,@1,@0,@1,@0,@1,@0,@0,@0],
//      @[@0,@0,@1,@1,@1,@1,@1,@1,@0,@1,@1,@0],
//      @[@1,@0,@0,@0,@0,@1,@0,@1,@0,@0,@0,@0],
//      @[@0,@0,@1,@1,@0,@1,@1,@0,@1,@1,@0,@0],
//      @[@0,@0,@1,@1,@1,@0,@1,@1,@0,@1,@1,@1],
//                          @[@0,@0,@0,@1,@1,@0,@1,@1,@0,@1,@1,@1]];
//
    
    //I keep a copy of the parent matrix so I can recover after finished a try
    NSArray *auxCreatedArray = [self.parentsArray copy];
    
    int iteraction = 0;
    
    int position = 0;
    
    for (NSArray *compareArray in self.parentsArray) {
        int fitness = [self fitnessBetweenCreatedArray:compareArray andTargetArray:self.bestDNA];
        fitnessArray[position] = @(fitness);
        position++;
    }
    
    //try crossover from point 0 to point 7
    for (int crossoverPoint = 0; crossoverPoint <= 10; crossoverPoint++) {
        
        //try mutagenic factor from 1% to 95%
        for (int mutagenicFactor = 1; mutagenicFactor <= 95 ; mutagenicFactor++) {
            
            NSDate *start = [NSDate date];
            
            //stop condition: the algorithm can't find any better value after MAXTRIESAFTERBESTVALUE tries
            while (self.triesAfterGetBestDNA < MAXTRIESAFTERBESTVALUE) {
                
                for (NSArray *aParent in self.parentsArray) {
                    self.bestDNA = [self changeDNAForBestSequence:aParent];
                }
                
                fitnessArray = [self finalFitnessUsingCrossoverPoint:crossoverPoint
                                                     mutagenicFactor:mutagenicFactor
                                                        parentsArray:self.parentsArray
                                                 initialFitnessArray:fitnessArray
                                                      expectedResult:self.bestDNA];
                
                self.triesAfterGetBestDNA++;
                iteraction++;
            }
            
            NSLog(@" %f best value on iteration %d crossover %d mutagenic %d: %f",-[start timeIntervalSinceNow], iteraction, crossoverPoint, mutagenicFactor, [self functionForExercise:[self numberFromDNASequence:self.bestDNA]]);
            
            iteraction = 0;
            position = 0;
            self.bestDNA = @[@0,@0,@0,@0,@0,@0,@0,@0,@0,@0,@0,@0];
            self.parentsArray = auxCreatedArray;
            self.triesAfterGetBestDNA = 0;

            
            for (NSArray *compareArray in self.parentsArray) {
                int fitness = [self fitnessBetweenCreatedArray:compareArray andTargetArray:self.bestDNA];
                fitnessArray[position] = @(fitness);
                position++;
            }
        }
    }
    

}

//calculates the fitness of each DNA and returns an array of fitness
-(NSMutableArray *)finalFitnessUsingCrossoverPoint:(int)crossoverPoint
                                   mutagenicFactor:(int)mutagenicFactor
                                      parentsArray:(NSArray *)parentsArray
                               initialFitnessArray:(NSArray *)initialFitnessArray
                                    expectedResult:(NSArray *)expectedResult
{
    
    
    NSMutableArray *returnArray = [NSMutableArray new];
    NSArray *roulleteArray = [self roulleteDistributionForFitnessArray:initialFitnessArray];
    //NSLog(@"%d iteraction: %@ number of elements: %i", iteraction, fitnessArray, [fitnessArray count]);
    NSArray *createdArray = [self chosenParentsFromArray:parentsArray usingRoulleteValues:roulleteArray];
    self.parentsArray = [self childrenArrayFromParentsArray:createdArray inCrossoverPoint:crossoverPoint mutagenicValue:mutagenicFactor];
    for (int i = 0; i <= 7; i++) {
        NSArray *childArray = createdArray[i];
        int fitness = [self fitnessBetweenCreatedArray:childArray andTargetArray:expectedResult];
        returnArray[i] = @(fitness);
    }
    return returnArray;
}

#pragma mark - create children array

//this function returns the children's array based on parents' array, the crossoverpoint and the mutagenic factor
-(NSArray *)childrenArrayFromParentsArray:(NSArray *)parentsArray
                         inCrossoverPoint:(int)crossoverPoint
                           mutagenicValue:(int)mutagenicValue{
    
    //creates the children array based on parents' array and crossover point
    NSArray *childrenArray = [self crossoverArrayFromParentArray:parentsArray crossoverPoint:crossoverPoint];
    
    //changes the children's DNA based on the mutagenic factor
    childrenArray = [self applyMutagenicFactor:mutagenicValue inChildrenArray:childrenArray];
    
    return childrenArray;
}

#pragma mark - Mutagenic factor

-(NSArray *)applyMutagenicFactor:(int)mutagenicFactor inChildrenArray:(NSArray *)childrenArray{
    if (mutagenicFactor == 0) {
        //if there is no mutagenic factor, it just ignore the code
        return childrenArray;
    }
    
    //calculates the chances of changing some gene
    float chancesToApply = (float)mutagenicFactor / 100;
    NSMutableArray *returnArray = [NSMutableArray new];
    
    //iteract over all arrays in matrix
    for (NSArray *childArray in childrenArray) {
        NSMutableArray *mutableChildArray = [childArray mutableCopy];
        //iteract over all elements in array
        for (int i = 0; i <= 11; i++) {
            NSNumber *aGene = mutableChildArray[i];
            
            //choose a number to check the chances of changing a gene
            float randonValue = [self randonBetweenMinimunValue:0 andMaximunValue:1];
            
            //if the chances to apply are bigger than the randon number
            if (chancesToApply > randonValue) {
                
                //create a gene with replaced values and add to the array
                NSNumber *mutagenicNumber = ([aGene  isEqual: @0] ? @1 : @0);
                mutableChildArray[i] = mutagenicNumber;
            }
        }
        [returnArray addObject:mutableChildArray];
    }
    
    
    return returnArray;
}

#pragma mark - choose parents

//this function chooses which parents are intereting to generate the children's array, based on the roullete calculation
-(NSArray *)chosenParentsFromArray:(NSArray *)parentsArray usingRoulleteValues:(NSArray *)roulleteArray{
    NSMutableArray *returnArray = [NSMutableArray new];
    for (int i = 0; i <= 7; i++) {
        //generates a value to test the roullete and gets a parent
        float randonValue = [self randonBetweenMinimunValue:0 andMaximunValue:1];
        
        //j will iteract over the returnArray, setting the position of each parent on j position
        for (int j = 0; j <= 7; j++) {
            NSNumber *numberFromRoullete = roulleteArray[j];
            //condition of chosing: randon value is smaller than the angle
            if (randonValue < [numberFromRoullete floatValue]) {
                //stop condition for roullete (it has 8 positions, from 0 to 7)
                if (i > [returnArray count]) {
                    i--;
                }
                //gets the parent on position i and insert it on returnArray position j
                returnArray[i] = parentsArray[j];
                j = 8;
                
            }
            
        }
    }
    return returnArray;
}

#pragma mark - Fitness calculation

//calculates the fitness of a DNA, based on the target value
-(int)fitnessBetweenCreatedArray:(NSArray *)createdArray andTargetArray:(NSArray *)targetArray{
    int fitness = 0;
    
    //for each gene in DNA of created array
    for (int i = 0; i <= 11; i++) {
        //if the gene in position i of createdArray is the same gene in position i of the target array, increments the fitness
        if (createdArray[i] == targetArray[i])
            fitness++;
    }
    
    return fitness;
}

//generates the total sum in fitness' array
-(int)sumOfAllElementsInArray:(NSArray *)fitnessArray{
    int sum = 0;
    for (NSNumber *number in fitnessArray) {
        sum += [number intValue];
    }
    return sum;
}

//this functions returns the array of angles based on the fitness of each DNA
-(NSArray *)roulleteDistributionForFitnessArray:(NSArray *)fitnessArray{
    NSMutableArray *returnArray = [NSMutableArray new];
    
    //calculates the total sum of fitness array based on each DNA's fitness
    int sumOfElements = [self sumOfAllElementsInArray:fitnessArray];
    for (int i = 0; i <= 7; i++) {
        NSNumber *aValue = fitnessArray[i];
        
        
        if (i > 0) {
            //if this element is not the first, sums its value with the value before adding to returnArray
            
            //generates the angle
            float angle = [self angleForFitness:[aValue intValue] inSum:sumOfElements];
            
            //get the previous value and transforms it to float
            NSNumber *previousValue = returnArray[i - 1];
            float floatPreviousValue = [previousValue floatValue];
            
            //add the current angle to the previous angle and add the total in returnArray
            returnArray[i] = @(angle + floatPreviousValue);
        } else {
            //if this is the first element, just add the angle to returnArray
            
            returnArray[i] = @([self angleForFitness:[aValue intValue] inSum:sumOfElements]);
        }
        
    }
    return returnArray;
}

//this function returns the angle based on the fitness of DNA, where sumValueOfArray is total sum of the fitness array
-(float)angleForFitness:(int)fitness inSum:(int)sumValueOfArray{
    float angle = (float)fitness/(float)sumValueOfArray;
    return angle;
}

#pragma mark - Crossover

//this function creates the child's array based on parent's array
-(NSArray *)crossoverArrayFromParentArray:(NSArray *)parentArray crossoverPoint:(int)crossOverPoint{
    NSMutableArray *returnArray = [NSMutableArray new];
    //if there is no crossover point, returns the parents array
    if (crossOverPoint == 0) {
        return parentArray;
    } else {
        //it will iteract in all parents, where the array in i position is the fater and i + 1 position is the mother
        for (int i = 0; i <= 7; i += 2) {
            NSArray *fatherArray = parentArray[i];
            NSArray *motherArray = parentArray[i + 1];
            
            //generates the first child
            NSArray *firstChild = [self childArrayWithFatherArray:fatherArray
                                                      motherArray:motherArray
                                                   crossOverPoint:crossOverPoint
                                                     isFirstArray:YES];
            [returnArray addObject:firstChild];
            
            //generates the second child
            NSArray *secondChild = [self childArrayWithFatherArray:fatherArray
                                                       motherArray:motherArray
                                                    crossOverPoint:crossOverPoint
                                                      isFirstArray:NO];
            [returnArray addObject:secondChild];
        }
    }
    return returnArray;
}

//this function was created to generate a child based on parents array. The boolean is used for control: if first child was created using the first half of genes of the father, it will generate the other son.
-(NSArray *)childArrayWithFatherArray:(NSArray *)fatherArray
                          motherArray:(NSArray *)motherArray
                       crossOverPoint:(int)crossOverPoint
                         isFirstArray:(BOOL)isFirstArray{
    if (isFirstArray) {
        NSArray *firstHalfArray = [fatherArray subarrayWithRange:NSMakeRange(0, crossOverPoint)];
        NSArray *secondHalfArray = [motherArray subarrayWithRange:NSMakeRange(crossOverPoint, 12 - crossOverPoint)];
        return [firstHalfArray arrayByAddingObjectsFromArray:secondHalfArray];
    } else {
        NSArray *firstHalfArray = [fatherArray subarrayWithRange:NSMakeRange(crossOverPoint, 12 - crossOverPoint)];
        NSArray *secondHalfArray = [motherArray subarrayWithRange:NSMakeRange(0, crossOverPoint)];
        return [firstHalfArray arrayByAddingObjectsFromArray:secondHalfArray];
    }
}

#pragma mark - number from DNA sequence

//transforms DNA sequence into a float
-(float)numberFromDNASequence:(NSArray *)dnaSequence{
    float returnNumber = 0;
    
    if (!dnaSequence) {
        return 0;
    }
    
    for (int position = 0; position <= 11; position++) {
        //for each gene in DNA position
        
        float floatPosition = (float)position;
        
        NSNumber *geneNumber = dnaSequence[position];
        
        //if gene is equal 1, sums 1/2 ^ position of the number
        returnNumber+= pow(2, -(floatPosition + 1)) * [geneNumber intValue];
        
        //returnNumber = floatPosition / 10;
    }
    
    return returnNumber;
}

#pragma mark - Initial calls

//generates a float randon betwwen 2 values
-(float)randonBetweenMinimunValue:(float)minimunValue andMaximunValue:(float)maximunValue{
    return ((float)arc4random() / ARC4RANDOM_MAX * (maximunValue - minimunValue)) + minimunValue;
}

#pragma mark - Best values

-(NSArray *)changeDNAForBestSequence:(NSArray *)dnaSequence {
    float actualNumber = [self numberFromDNASequence:self.bestDNA];
    float tryNumber = [self numberFromDNASequence:dnaSequence];
    
    actualNumber = [self functionForExercise:actualNumber];
    tryNumber = [self functionForExercise:tryNumber];
    
    if (tryNumber > actualNumber){
        self.triesAfterGetBestDNA = 0;
        return dnaSequence;
    }
    
    
    return self.bestDNA;
}

#pragma mark - Function for exercise

-(float)functionForExercise:(float)initialValue{
    float part1 = (initialValue - 0.1) / 0.9;
    float part2 = powf(part1, 2);
    float part25 = -2*part2;
    float part3 = powf(2, part25);
    
    float part4 = powf(sin(5 * 3.14 * initialValue), 6);
    return part3 * part4;
    //return powf(2, powf(-2*(initialValue - 0.1) / (0.9), 2)) * sin(5*3.14*initialValue);
    
}


//creates an initial array of genes
//-(NSArray *)createInitialArray{
//    NSMutableArray *returnArray = [NSMutableArray new];
//    
//    
//    for (int i = 0; i <= 7; i++) {
//        NSMutableArray *rowArray = [NSMutableArray new];
//        for (int j = 0; j <= 11; j++) {
//            int zeroOrOne = [self zeroOrOne];
//            rowArray[j] = @(zeroOrOne);
//        }
//        [returnArray addObject:rowArray];
//    }
//    
//    return returnArray;
//}

//generate
//-(int)zeroOrOne{
//    float testNumber = [self randonBetweenMinimunValue:0 andMaximunValue:1] ;
//    if (testNumber > 0.5) {
//        return 1;
//    }
//    return 0;
//}


@end
