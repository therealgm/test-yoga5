//
//  ProgressDataModel.swift
//  test-yoga5
//
//  Created by user@22 on 05/11/24.
//
import Foundation

struct ProgressDataModel {
    let completed: Int
    let inProgress: Int
    let remaining: Int
    let totalTime: Int
    let completedTime: Int

    // Initialize a LifeExpectancyModel based on completed poses
    var lifeExpectancy: LifeExpectancyModel {
        return LifeExpectancyModel(completedPoses: completed)
    }

    // Completion percentages for progress bars
    var completionPercentage: CGFloat {
        let totalTasks = completed + inProgress + remaining
        return totalTasks > 0 ? CGFloat(completed) / CGFloat(totalTasks) : 0
    }
    
    var timeCompletionPercentage: CGFloat {
        return totalTime > 0 ? CGFloat(completedTime) / CGFloat(totalTime) : 0
    }
}


