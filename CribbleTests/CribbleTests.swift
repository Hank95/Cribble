//
//  CribbleTests.swift
//  CribbleTests
//
//  Created by Henry Pendleton on 6/24/25.
//

import Testing
import CoreData
@testable import Cribble

// MARK: - Game+Extensions Tests

@Suite(.serialized)
struct GameExtensionsTests {
    let stack: TestCoreDataStack

    init() {
        stack = TestCoreDataStack()
    }

    // MARK: - Skunk Detection Tests

    @Test func regularWin_notSkunk() {
        let game = createTestGame(in: stack.context, winnerScore: 121, loserScore: 100)

        #expect(game.isSkunk == false)
        #expect(game.isDoubleSkunk == false)
    }

    @Test func skunkAt90Points() {
        let game = createTestGame(in: stack.context, winnerScore: 121, loserScore: 90)

        #expect(game.isSkunk == true)
        #expect(game.isDoubleSkunk == false)
    }

    @Test func skunkAt61Points() {
        let game = createTestGame(in: stack.context, winnerScore: 121, loserScore: 61)

        #expect(game.isSkunk == true)
        #expect(game.isDoubleSkunk == false)
    }

    @Test func doubleSkunkAt60Points() {
        let game = createTestGame(in: stack.context, winnerScore: 121, loserScore: 60)

        #expect(game.isSkunk == false, "Double skunk should not also be skunk")
        #expect(game.isDoubleSkunk == true)
    }

    @Test func doubleSkunkAt0Points() {
        let game = createTestGame(in: stack.context, winnerScore: 121, loserScore: 0)

        #expect(game.isSkunk == false)
        #expect(game.isDoubleSkunk == true)
    }

    @Test func boundaryAt91Points_notSkunk() {
        let game = createTestGame(in: stack.context, winnerScore: 121, loserScore: 91)

        #expect(game.isSkunk == false, "91 points should NOT be a skunk")
        #expect(game.isDoubleSkunk == false)
    }

    // MARK: - Match Points Tests

    @Test func regularWin_1MatchPoint() {
        let game = createTestGame(in: stack.context, winnerScore: 121, loserScore: 100)

        #expect(game.matchPoints == 1)
    }

    @Test func skunk_2MatchPoints() {
        let game = createTestGame(in: stack.context, winnerScore: 121, loserScore: 85)

        #expect(game.matchPoints == 2)
    }

    @Test func doubleSkunk_3MatchPoints() {
        let game = createTestGame(in: stack.context, winnerScore: 121, loserScore: 45)

        #expect(game.matchPoints == 3)
    }

    // MARK: - Margin Tests

    @Test func margin_calculatesCorrectly() {
        let game = createTestGame(in: stack.context, winnerScore: 121, loserScore: 89)

        #expect(game.margin == 32)
    }

    @Test func margin_closeGame() {
        let game = createTestGame(in: stack.context, winnerScore: 121, loserScore: 120)

        #expect(game.margin == 1)
    }

    // MARK: - Duration Formatting Tests

    @Test func formattedDuration_minutesOnly() {
        let game = Game(context: stack.context)
        game.duration = 15 * 60 // 15 minutes

        #expect(game.formattedDuration == "15m")
    }

    @Test func formattedDuration_hoursAndMinutes() {
        let game = Game(context: stack.context)
        game.duration = 83 * 60 // 1 hour 23 minutes

        #expect(game.formattedDuration == "1h 23m")
    }

    @Test func formattedDuration_exactHour() {
        let game = Game(context: stack.context)
        game.duration = 60 * 60 // 1 hour exactly

        #expect(game.formattedDuration == "1h")
    }
}

// MARK: - StatsService Tests

@Suite(.serialized)
struct StatsServiceTests {
    let stack: TestCoreDataStack

    init() {
        stack = TestCoreDataStack()
    }

    @Test func leagueTable_calculatesWinsAndLosses() {
        let context = stack.context
        let alice = createTestPlayer(in: context, name: "Alice")
        let bob = createTestPlayer(in: context, name: "Bob")

        // Alice wins 2 games, Bob wins 1
        _ = createTestGame(in: context, winnerScore: 121, loserScore: 100, winner: alice, loser: bob)
        _ = createTestGame(in: context, winnerScore: 121, loserScore: 95, winner: alice, loser: bob)
        _ = createTestGame(in: context, winnerScore: 121, loserScore: 110, winner: bob, loser: alice)

        try? context.save()

        let service = StatsService(context: context)
        let standings = service.fetchLeagueTable()

        let aliceStats = standings.first { $0.player.name == "Alice" }
        let bobStats = standings.first { $0.player.name == "Bob" }

        #expect(aliceStats?.wins == 2)
        #expect(aliceStats?.losses == 1)
        #expect(aliceStats?.gamesPlayed == 3)

        #expect(bobStats?.wins == 1)
        #expect(bobStats?.losses == 2)
        #expect(bobStats?.gamesPlayed == 3)
    }

    @Test func leagueTable_calculatesMatchPoints() {
        let context = stack.context
        let alice = createTestPlayer(in: context, name: "Alice")
        let bob = createTestPlayer(in: context, name: "Bob")

        // Alice: regular win (1pt) + skunk (2pt) = 3 match points
        _ = createTestGame(in: context, winnerScore: 121, loserScore: 100, winner: alice, loser: bob)
        _ = createTestGame(in: context, winnerScore: 121, loserScore: 80, winner: alice, loser: bob)

        // Bob: double skunk (3pt) = 3 match points
        _ = createTestGame(in: context, winnerScore: 121, loserScore: 50, winner: bob, loser: alice)

        try? context.save()

        let service = StatsService(context: context)
        let standings = service.fetchLeagueTable()

        let aliceStats = standings.first { $0.player.name == "Alice" }
        let bobStats = standings.first { $0.player.name == "Bob" }

        #expect(aliceStats?.matchPoints == 3)
        #expect(bobStats?.matchPoints == 3)
    }

    @Test func leagueTable_tracksSkunkCounts() {
        let context = stack.context
        let alice = createTestPlayer(in: context, name: "Alice")
        let bob = createTestPlayer(in: context, name: "Bob")

        // Alice deals a skunk and a double skunk
        _ = createTestGame(in: context, winnerScore: 121, loserScore: 85, winner: alice, loser: bob)
        _ = createTestGame(in: context, winnerScore: 121, loserScore: 40, winner: alice, loser: bob)

        try? context.save()

        let service = StatsService(context: context)
        let standings = service.fetchLeagueTable()

        let aliceStats = standings.first { $0.player.name == "Alice" }
        let bobStats = standings.first { $0.player.name == "Bob" }

        #expect(aliceStats?.skunks == 1)
        #expect(aliceStats?.doubleSkunks == 1)

        #expect(bobStats?.skunkedBy == 1)
        #expect(bobStats?.doubleSkunkedBy == 1)
    }

    @Test func leagueTable_sortsByMatchPoints() {
        let context = stack.context
        let alice = createTestPlayer(in: context, name: "Alice")
        let bob = createTestPlayer(in: context, name: "Bob")
        let charlie = createTestPlayer(in: context, name: "Charlie")

        // Charlie: 2 regular wins = 2 pts
        _ = createTestGame(in: context, winnerScore: 121, loserScore: 100, winner: charlie, loser: alice)
        _ = createTestGame(in: context, winnerScore: 121, loserScore: 100, winner: charlie, loser: bob)

        // Alice: 1 double skunk = 3 pts
        _ = createTestGame(in: context, winnerScore: 121, loserScore: 50, winner: alice, loser: bob)

        // Bob: 1 regular win = 1 pt
        _ = createTestGame(in: context, winnerScore: 121, loserScore: 100, winner: bob, loser: alice)

        try? context.save()

        let service = StatsService(context: context)
        let standings = service.fetchLeagueTable()

        #expect(standings.count == 3)
        #expect(standings[0].player.name == "Alice", "Alice should be first with 3 match points")
        #expect(standings[1].player.name == "Charlie", "Charlie should be second with 2 match points")
        #expect(standings[2].player.name == "Bob", "Bob should be third with 1 match point")
    }

    @Test func headToHead_calculatesRecordBetweenPlayers() {
        let context = stack.context
        let alice = createTestPlayer(in: context, name: "Alice")
        let bob = createTestPlayer(in: context, name: "Bob")

        // Alice beats Bob twice, Bob beats Alice once (with a skunk)
        _ = createTestGame(in: context, winnerScore: 121, loserScore: 100, winner: alice, loser: bob)
        _ = createTestGame(in: context, winnerScore: 121, loserScore: 95, winner: alice, loser: bob)
        _ = createTestGame(in: context, winnerScore: 121, loserScore: 85, winner: bob, loser: alice)

        try? context.save()

        let service = StatsService(context: context)
        let h2h = service.headToHead(player1: alice, player2: bob)

        #expect(h2h.totalGames == 3)
        #expect(h2h.player1Wins == 2)
        #expect(h2h.player2Wins == 1)
        #expect(h2h.player1MatchPoints == 2) // 2 regular wins
        #expect(h2h.player2MatchPoints == 2) // 1 skunk
        #expect(h2h.player2Skunks == 1)
    }

    @Test func headToHead_winPercentageCalculation() {
        let context = stack.context
        let alice = createTestPlayer(in: context, name: "Alice")
        let bob = createTestPlayer(in: context, name: "Bob")

        // Alice wins 3 out of 4 games = 75%
        _ = createTestGame(in: context, winnerScore: 121, loserScore: 100, winner: alice, loser: bob)
        _ = createTestGame(in: context, winnerScore: 121, loserScore: 100, winner: alice, loser: bob)
        _ = createTestGame(in: context, winnerScore: 121, loserScore: 100, winner: alice, loser: bob)
        _ = createTestGame(in: context, winnerScore: 121, loserScore: 100, winner: bob, loser: alice)

        try? context.save()

        let service = StatsService(context: context)
        let h2h = service.headToHead(player1: alice, player2: bob)

        #expect(h2h.player1WinPercentage == 75.0)
        #expect(h2h.player2WinPercentage == 25.0)
    }

    @Test func winPercentage_calculatesCorrectly() {
        let context = stack.context
        let alice = createTestPlayer(in: context, name: "Alice")
        let bob = createTestPlayer(in: context, name: "Bob")

        // Alice wins 2 out of 3 games = 66.67%
        _ = createTestGame(in: context, winnerScore: 121, loserScore: 100, winner: alice, loser: bob)
        _ = createTestGame(in: context, winnerScore: 121, loserScore: 100, winner: alice, loser: bob)
        _ = createTestGame(in: context, winnerScore: 121, loserScore: 100, winner: bob, loser: alice)

        try? context.save()

        let service = StatsService(context: context)
        let standings = service.fetchLeagueTable()

        let aliceStats = standings.first { $0.player.name == "Alice" }

        // 2/3 = 66.666...%
        #expect(aliceStats!.winPercentage > 66.6)
        #expect(aliceStats!.winPercentage < 66.7)
    }
}
