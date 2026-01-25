//
//  LeagueViewModel.swift
//  Cribble
//
//  Created by Claude Code on 1/25/26.
//

import Foundation
import CoreData
import Combine

class LeagueViewModel: ObservableObject {
    @Published var standings: [StatsService.PlayerLeagueStats] = []
    @Published var isLoading: Bool = false

    private var statsService: StatsService?

    func loadStats(context: NSManagedObjectContext) {
        isLoading = true
        statsService = StatsService(context: context)
        standings = statsService?.fetchLeagueTable() ?? []
        isLoading = false
    }

    func refresh(context: NSManagedObjectContext) {
        loadStats(context: context)
    }
}
