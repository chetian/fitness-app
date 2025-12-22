//
//  ChartView.swift
//  FitnessApp
//
//  Created on 12/21/25.
//

import SwiftUI
import Charts

struct WeeklyChartView: View {
    let data: [Date: Int]
    @Environment(\.colorScheme) var colorScheme
    
    var sortedData: [(Date, Int)] {
        data.sorted { $0.key < $1.key }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Weekly Steps")
                .font(.headline)
            
            if #available(iOS 16.0, *) {
                Chart {
                    ForEach(sortedData, id: \.0) { date, steps in
                        BarMark(
                            x: .value("Day", date, unit: .day),
                            y: .value("Steps", steps)
                        )
                        .foregroundStyle(Color.accentColor.gradient)
                        .cornerRadius(4)
                    }
                }
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day)) { value in
                        if let date = value.as(Date.self) {
                            AxisValueLabel {
                                Text(date, format: .dateTime.weekday(.abbreviated))
                                    .font(.caption)
                            }
                        }
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        if let steps = value.as(Int.self) {
                            AxisValueLabel {
                                Text("\(steps / 1000)K")
                                    .font(.caption)
                            }
                            AxisGridLine()
                        }
                    }
                }
                .frame(height: 150)
            } else {
                // Fallback for iOS < 16
                SimpleBarChartView(data: sortedData)
                    .frame(height: 150)
            }
            
            // Average
            if !sortedData.isEmpty {
                let average = sortedData.map(\.1).reduce(0, +) / sortedData.count
                
                HStack {
                    Text("Daily Average:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(average) steps")
                        .font(.caption)
                        .fontWeight(.semibold)
                }
            }
        }
    }
}

// MARK: - Simple Bar Chart (Fallback for iOS < 16)

struct SimpleBarChartView: View {
    let data: [(Date, Int)]
    
    var maxSteps: Int {
        data.map(\.1).max() ?? 1
    }
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            ForEach(data, id: \.0) { date, steps in
                VStack(spacing: 4) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.accentColor)
                        .frame(height: CGFloat(steps) / CGFloat(maxSteps) * 120)
                    
                    Text(date, format: .dateTime.weekday(.narrow))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .frame(height: 150)
    }
}

#Preview {
    let sampleData: [Date: Int] = {
        var data: [Date: Int] = [:]
        let calendar = Calendar.current
        for i in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: -i, to: Date()) {
                let startOfDay = calendar.startOfDay(for: date)
                data[startOfDay] = Int.random(in: 3000...12000)
            }
        }
        return data
    }()
    
    WeeklyChartView(data: sampleData)
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(16)
        .padding()
}

