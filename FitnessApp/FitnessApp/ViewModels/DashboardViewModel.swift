//
//  DashboardViewModel.swift
//  FitnessApp
//
//  Created on 12/21/25.
//

import Foundation
import Combine

@MainActor
class DashboardViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var currentUser: User?
    @Published var todayMetrics: ActivityMetrics?
    @Published var weeklyData: [Date: Int] = [:]
    @Published var insights: [AIInsight] = []
    @Published var isLoading = false
    @Published var isRefreshing = false
    @Published var errorMessage: String?
    @Published var showError = false
    @Published var lastSyncDate: Date?
    
    // MARK: - Services
    
    private let databaseService = DatabaseService.shared
    private let healthKitService = HealthKitService.shared
    private let aiInsightsService = AIInsightsService.shared
    private let authService = AuthenticationService.shared
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Computed Properties
    
    var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good Morning"
        case 12..<17: return "Good Afternoon"
        case 17..<22: return "Good Evening"
        default: return "Hello"
        }
    }
    
    var userName: String {
        currentUser?.displayName.split(separator: " ").first.map(String.init) ?? "there"
    }
    
    var todaySteps: Int {
        todayMetrics?.steps ?? 0
    }
    
    var todayCalories: Int {
        todayMetrics?.activeEnergy ?? 0
    }
    
    var todayActiveMinutes: Int {
        todayMetrics?.activeMinutes ?? 0
    }
    
    // MARK: - Initialization
    
    init() {
        setupNotificationObservers()
        // TODO: Implement loadCachedData() for offline support
    }
    
    private func setupNotificationObservers() {
        NotificationCenter.default.publisher(for: NSNotification.Name(Constants.NotificationKeys.healthKitDataUpdated))
            .sink { [weak self] _ in
                Task { @MainActor in
                    await self?.syncHealthKitData()
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Load Data
    
    func loadDashboardData(user: User) async {
        self.currentUser = user
        isLoading = true
        
        async let metricsTask = loadTodayMetrics()
        async let weeklyTask = loadWeeklyData()
        async let insightsTask = loadInsights()
        
        // Wait for all tasks to complete
        _ = await (metricsTask, weeklyTask, insightsTask)
        
        isLoading = false
    }
    
    private func loadTodayMetrics() async {
        guard let user = currentUser else { return }
        
        // Try to load from cache first
        if let cached = loadCachedMetrics() {
            self.todayMetrics = cached
        }
        
        // Fetch from HealthKit if available
        if user.healthKitEnabled && healthKitService.isHealthKitAvailable {
            await syncHealthKitData()
        } else {
            // Try to fetch from MongoDB
            do {
                let metrics = try await databaseService.fetchFitnessMetrics(userId: user.firebaseUid, days: 1)
                if let today = metrics.first {
                    self.todayMetrics = today
                    cacheMetrics(today)
                }
            } catch {
                print("Failed to fetch metrics from MongoDB: \(error)")
            }
        }
    }
    
    private func loadWeeklyData() async {
        guard currentUser?.healthKitEnabled == true else { return }
        
        do {
            let weeklySteps = try await healthKitService.queryWeeklySteps()
            self.weeklyData = weeklySteps
        } catch {
            print("Failed to load weekly data: \(error)")
        }
    }
    
    private func loadInsights() async {
        guard let user = currentUser else { return }
        
        do {
            let fetchedInsights = try await aiInsightsService.fetchInsights(userId: user.firebaseUid)
            self.insights = fetchedInsights
        } catch {
            // Generate local insights
            let steps = todayMetrics?.steps ?? 0
            let calories = todayMetrics?.activeEnergy ?? 0
            self.insights = aiInsightsService.generateInsightsFromActivity(steps: steps, calories: calories)
        }
    }
    
    // MARK: - Refresh Data
    
    func refreshData() async {
        isRefreshing = true
        
        if let user = currentUser {
            await loadDashboardData(user: user)
        }
        
        isRefreshing = false
        lastSyncDate = Date()
    }
    
    // MARK: - HealthKit Sync
    
    func syncHealthKitData() async {
        guard let user = currentUser else { return }
        guard user.healthKitEnabled else { return }
        guard healthKitService.isHealthKitAvailable else { return }
        
        do {
            // Query all health data in parallel
            async let stepsTask = healthKitService.querySteps()
            async let caloriesTask = healthKitService.queryActiveEnergy()
            async let distanceTask = healthKitService.queryDistance()
            async let heartRateTask = healthKitService.queryLatestHeartRate()
            async let activeMinutesTask = healthKitService.calculateActiveMinutes()
            
            let (steps, calories, distance, heartRate, activeMinutes) = await (
                (try? stepsTask) ?? 0,
                (try? caloriesTask) ?? 0,
                (try? distanceTask) ?? 0,
                try? heartRateTask,
                (try? activeMinutesTask) ?? 0
            )
            
            // Create metrics object
            let metrics = ActivityMetrics(
                id: UUID().uuidString,
                userId: user.firebaseUid,
                date: Date(),
                steps: steps,
                activeEnergy: calories,
                activeMinutes: activeMinutes,
                restingHeartRate: heartRate,
                averageHeartRate: heartRate,
                maxHeartRate: nil,
                distance: distance,
                floorsClimbed: nil,
                dataSource: .healthkit,
                createdAt: Date(),
                updatedAt: Date()
            )
            
            self.todayMetrics = metrics
            cacheMetrics(metrics)
            
            // Upload to MongoDB (fire and forget)
            Task.detached {
                try? await self.databaseService.createFitnessMetrics(metrics)
            }
            
            // Generate new insights based on data
            self.insights = aiInsightsService.generateInsightsFromActivity(steps: steps, calories: calories)
            
            lastSyncDate = Date()
            
        } catch {
            errorMessage = "Failed to sync HealthKit data"
            showError = true
        }
    }
    
    // MARK: - Caching
    
    private func loadCachedMetrics() -> ActivityMetrics? {
        guard let data = UserDefaults.standard.data(forKey: Constants.UserDefaultsKeys.cachedMetrics) else {
            return nil
        }
        
        return try? JSONDecoder().decode(ActivityMetrics.self, from: data)
    }
    
    private func cacheMetrics(_ metrics: ActivityMetrics) {
        if let data = try? JSONEncoder().encode(metrics) {
            UserDefaults.standard.set(data, forKey: Constants.UserDefaultsKeys.cachedMetrics)
        }
        
        UserDefaults.standard.set(Date(), forKey: Constants.UserDefaultsKeys.lastSync)
    }
    
    func getLastSyncDate() -> Date? {
        return UserDefaults.standard.object(forKey: Constants.UserDefaultsKeys.lastSync) as? Date
    }
}

