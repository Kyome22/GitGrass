//
//  GitGrassWidget.swift
//  GitGrassWidget
//
//  Created by Takuto Nakamura on 2020/10/16.
//  Copyright 2020 Takuto Nakamura
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {

    private func makeDefaultSimpleEntry(date: Date) -> SimpleEntry {
        let dm = DataManager.shared
        return SimpleEntry(date: date,
                           username: dm.labelText,
                           dayData: dm.dayData,
                           color: dm.color,
                           style: dm.style)
    }


    func placeholder(in context: Context) -> SimpleEntry {
        return makeDefaultSimpleEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        completion(makeDefaultSimpleEntry(date: Date()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {

        let date = Date()
        let afterDate = Calendar.current.date(byAdding: .minute, value: 30, to: date)!
        if context.isPreview {
            let entry = makeDefaultSimpleEntry(date: date)
            completion(Timeline(entries: [entry], policy: .after(afterDate)))
        } else {
            let dm = DataManager.shared
            GitAccess.getGrass(username: dm.username) { (username, html) in
                if let html = html {
                    dm.dayData = GrassParser.parse(html: html)
                }
                let entry = makeDefaultSimpleEntry(date: date)
                completion(Timeline(entries: [entry], policy: .after(afterDate)))
            }
        }
    }

}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let username: String
    let dayData: [[DayData]]
    let color: GGColor
    let style: GGStyle
}

struct GitGrassWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        let aspect = ceil(0.5 * CGFloat(entry.dayData[0].count)) / 7.0
        return VStack(alignment: .leading, spacing: 8) {
            Text(entry.username)
                .font(.headline)
                .foregroundColor(Color.primary)
            GrassView(dayData: entry.dayData,
                      color: entry.color,
                      style: entry.style)
                .aspectRatio(aspect, contentMode: .fit)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .padding(16)
        .background(Color("WidgetBackground"))
    }
}

@main
struct GitGrassWidget: Widget {
    let kind: String = "GitGrassWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            GitGrassWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("GitGrass")
        .description("You can check your GitHub contributions.")
        .supportedFamilies([.systemMedium])
    }
}

struct GitGrassWidget_Previews: PreviewProvider {
    static var previews: some View {
        let entry = SimpleEntry(date: Date(),
                                username: "UserName",
                                dayData: DayData.default,
                                color: GGColor.greenGrass,
                                style: GGStyle.block)
        return GitGrassWidgetEntryView(entry: entry)
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
