import SwiftUI

struct BrandMark: View {
    var body: some View {
        VStack(spacing: 0) {
            Text("TEKKERSUP")
                .font(Typo.font(Typo.title, .black).italic())
                .textCase(.uppercase)
                .tracking(Tracking.tight)
                .foregroundStyle(Theme.neon)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, Space.sm)
            Rule(weight: 2)
        }
    }
}
