//
//  HeadToHeadViewModel.swift
//  Cribble
//
//  Created by Claude Code on 1/25/26.
//

import Foundation
import CoreData
import Combine

class HeadToHeadViewModel: ObservableObject {
    @Published var stats: StatsService.HeadToHeadStats?
    @Published var allPlayers: [Player] = []
    @Published var isLoading: Bool = false

    private var statsService: StatsService?

    func loadPlayers(context: NSManagedObjectContext) {
        allPlayers = Player.fetchAllPlayers(in: context)
    }

    func loadStats(player1: Player?, player2: Player?, context: NSManagedObjectContext) {
        guard let p1 = player1, let p2 = player2, p1.id != p2.id else {
            stats = nil
            return
        }

        isLoading = true
        statsService = StatsService(context: context)
        stats = statsService?.headToHead(player1: p1, player2: p2)
        isLoading = false
    }
}
