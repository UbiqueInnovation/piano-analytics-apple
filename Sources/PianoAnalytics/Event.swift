//
//  Event.swift
//
//  This SDK is licensed under the MIT license (MIT)
//  Copyright (c) 2015- Applied Technologies Internet SAS (registration number B 403 261 258 - Trade and Companies Register of Bordeaux – France)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import Foundation

public final class Event {

    public final let name: String
    public final let data: [String: Any]

    public init(_ name: String, data: [String: Any]) {
        self.name = name
        self.data = PianoAnalyticsUtils.toFlatten(src: data)
    }
    
    public init(_ name: String) {
        self.name = name
        self.data = [:]
    }
    
    public convenience init(_ name: String, properties: Set<Property>) {
        self.init(name, data: properties.toMap())
    }

    final func toMap(context: [String: ContextProperty] = [:]) -> [String: Any] {

        // add context keys depending on the options they have
        // if no options we send them
        var contextProperties: [String: Any] = [:]
        for (key, value) in context {
            if let events = value.options?.events {
                if events.contains(where: { $0 == self.name }) {
                    contextProperties[key] = value.value
                }
            } else {
                contextProperties[key] = value.value
            }
        }

        return [
            "name": self.name,
            "data": self.data.merging(contextProperties, uniquingKeysWith: { _, contextValue in
                contextValue
            })
        ]
    }
    
    final func toEventMap(context: [String: ContextProperty] = [:]) -> Event {

        // add context keys depending on the options they have
        // if no options we send them
        var contextProperties: [String: Any] = [:]
        for (key, value) in context {
            if let events = value.options?.events {
                if PianoAnalyticsUtils.isEventAuthorized(eventName: self.name, authorizedEvents: events) {
                    contextProperties[key] = value.value
                }
            } else {
                contextProperties[key] = value.value
            }
        }

        return Event(self.name, data: self.data.merging(contextProperties, uniquingKeysWith: { _, contextValue in
            contextValue}))
    }
}
