//
//  GeneticAlgorithm.h
//  HillClimbing
//
//  Created by Claudio Santos on 4/21/15.
//  Copyright (c) 2015 Claudio Santos. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GeneticAlgorithm : NSObject

@property(nonatomic, strong)NSMutableArray *iteractionsForGeneticAlgorithm;
@property(nonatomic, strong)NSMutableArray *timesForGeneticAlgorithm;
@property(nonatomic, strong)NSMutableArray *valuesForGeneticAlgorithm;

-(void)calculateBestValue;

@end
