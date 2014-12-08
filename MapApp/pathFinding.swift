//
//  pathFinding.swift
//  MapApp
//
//  Created by Pratistha Bhattarai on 12/8/14.
//  Copyright (c) 2014 Galen Long. All rights reserved.
//

import Foundation

//pseudocode for A-star algorithm
// Priority queue PQ begins empty.
//V (= set of previously visited (coordinates,f,parent)-triples) begins empty.
//• Put s into PQ and V with priority f(s) = g(s) + h(s)
//• Is PQ empty?
//Yes? admit there’s no solution
//No? Remove node with lowest f(n) from queue. Call it n.
//If n is a goal, stop and report success.
//Else, “expand” n : For each n' in successors(n)….
//• Let f’ = g(n') + h(n') = g(n) + cost(n,n') + h(n')
//• If n' not in V or n' previously expanded(means that it is in V) with
//f(n')>f’( and n' currently in PQ) with f(n')>f’
//  Then Place/promote n' on priority queue with priority f’
//  and update V to include (state=n', f ’, Parent=n).
//• Else Ignore n'


// Priority queue PQ begins empty.
//V (= set of previously visited (coordinates,f,parent)-triples) begins empty.
//• Put s into PQ and V with priority f(s) = g(s) + h(s)
//• Is PQ empty?
//Yes? admit there’s no solution
//No? Remove node with lowest f(n) from queue. Call it n.
//If n is a goal, stop and report success.
//Else, “expand” n : For each n' in successors(n)….
//• Let f’ = g(n') + h(n') = g(n) + cost(n,n') + h(n')
//• If n' not in V or n' previously expanded(means that it is in V) with
//f(n')>f’( and n' currently in PQ) with f(n')>f’
//  Then Place/promote n' on priority queue with priority f’
//• Else Ignore n'
//
//after all n' have been considered, update V to include (state=n, f , Parent=n).