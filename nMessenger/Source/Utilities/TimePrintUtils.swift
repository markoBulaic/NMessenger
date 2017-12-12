//
//  TimePrintUtils.swift
//  nMessenger
//
//  Created by Alexander Dodatko on 8/28/17.
//  Copyright © 2017 Ebay Inc. All rights reserved.
//

import Foundation


public class TimePrintUtils
{
    private static let oneMinute: Int = 60
    private static let oneHour  : Int = 60 * oneMinute
    
    private static let tOneMinute: TimeInterval = TimeInterval(TimePrintUtils.oneMinute)
    private static let tOneHour  : TimeInterval = TimeInterval(TimePrintUtils.oneHour)
    
    public static func timeIntervalToString(
        _ t: TimeInterval)
    -> String
    {
        precondition(t >= 0)
        
        let tHours: TimeInterval = floor(t / tOneHour)
        let hours = Int(tHours)
        let hasHours: Bool = (hours > 0)
        let withoutHours = t - (tHours * tOneHour)
        
        
        let tMinutes: TimeInterval = floor(withoutHours / tOneMinute)
        let minutes = Int(tMinutes)
        let withoutMinutes = withoutHours - (tMinutes * tOneMinute)
        
        let seconds = Int(withoutMinutes)
        
        var result: String = ""
        if (hasHours)
        {
            result =
                String(
                    format: "%02d:%02d:%02d",
                    hours,
                    minutes,
                    seconds)
        }
        else
        {
            result =
                String(
                    format: "%02d:%02d",
                    minutes,
                    seconds)
        }
        
        return result
    }
}

