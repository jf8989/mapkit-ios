// App/MapTab/Components/DistanceHeaderView.swift

import SwiftUI

struct DistanceHeader: View {
    let meters: Double

    var body: some View {
        HStack(spacing: 6) {
            Text("Distance:").font(.subheadline)
            Text(meters, format: .number.precision(.fractionLength(0)))
                .monospacedDigit()
                .font(.subheadline.weight(.semibold))
            Text("m").font(.footnote)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
    }
}
