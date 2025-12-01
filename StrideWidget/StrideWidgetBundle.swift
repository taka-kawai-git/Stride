//
//  StrideWidgetBundle.swift
//  StrideWidget
//
//  Created by 川井孝之 on 2025/11/13.
//

import WidgetKit
import SwiftUI

@main
struct StrideWidgetBundle: WidgetBundle {
    var body: some Widget {
        StrideWidget()
        StrideWidgetLiveActivity()
    }
}
