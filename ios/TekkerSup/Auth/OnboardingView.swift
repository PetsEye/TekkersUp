import SwiftUI

struct OnboardingView: View {
    let primaryLabel: String
    let showsBack: Bool
    let onPrimary: () -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Screen {
            if showsBack {
                Button("← Back") { dismiss() }
                    .buttonStyle(.tekker(.ghost, small: true))
            }

            BrandMark()

            Eyebrow("Onboarding / Read first", accent: true)

            Headline("Train smarter,\none rep at a time", size: Typo.title, color: Theme.text)

            HStack(alignment: .top, spacing: Space.sm) {
                Rectangle()
                    .fill(Theme.neon)
                    .frame(width: 2)
                Text("TEKKERSUP is a training companion for soccer players. Prop up your phone, run a drill, and get a clear read on your technique, along with specific things to work on before your next session.")
                    .font(Typo.font(Typo.body))
                    .foregroundStyle(Theme.text)
                    .lineSpacing(Space.xxs)
            }
            .fixedSize(horizontal: false, vertical: true)

            OnboardSection(title: "What the app does") {
                Text("Choose a drill, such as the Power Shot or the Inside-Foot Pass, and place your phone two to three metres away at waist height. TEKKERSUP follows your body through the camera and draws a live skeleton over your image, so you can see exactly what the app is tracking while you train.")
            }

            OnboardSection(title: "What it measures") {
                Text("For each drill, the app tracks the angles that matter most for that technique. For a power shot, that means how far your kicking knee bends as you load the leg, how firmly your plant knee holds at contact, how upright your torso stays, and how your arms balance the swing. Every measurement is compared against target ranges written for that drill.")
            }

            OnboardSection(title: "How reps are counted") {
                Text("Each strike is one rep. The app watches for your kicking leg to load back and then follow through, and it scores every rep on how many of its measurements landed inside the target range. You do not need to press anything between strikes. Start the set, train, and end it when you are done.")
            }

            OnboardSection(title: "What you get back") {
                Text("When a set ends, you receive a report with an overall score, the average value for each measurement, the share of reps that were in range, and a score for every rep. Where a measurement is often out of range, the report gives you a plain pointer on what to change, such as opening your hips or bringing your heel back further. Every session is saved to your log so you can see your progress over time.")
            }

            OnboardSection(title: "Before your first set") {
                VStack(alignment: .leading, spacing: Space.xs) {
                    BulletLine(text: "Film from the side so your kicking leg is clearly visible.")
                    BulletLine(text: "Keep your whole body in frame, from head to feet.")
                    BulletLine(text: "Train in good light and avoid standing with a bright window behind you.")
                    BulletLine(text: "Use a warm-up first, so your first reps are not your strongest.")
                }
            }

            OnboardSection(title: "About your data") {
                Text("Video from your camera is analysed on your device. Your sessions and account are saved on this device for now, so they stay on the phone you trained on. Measurements come from a single camera, which makes them estimates. Treat the pointers as coaching guidance and not as a medical assessment.")
            }

            Button(primaryLabel, action: onPrimary)
                .buttonStyle(.tekker(.primary, fullWidth: true))
                .padding(.top, Space.xs)
        }
    }
}

struct OnboardSection<Content: View>: View {
    let title: String
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: Space.sm) {
            Rule(weight: 1, color: Theme.line)
            Text(title)
                .font(Typo.font(Typo.body, .black).italic())
                .textCase(.uppercase)
                .tracking(Tracking.tight)
                .foregroundStyle(Theme.neon)
                .padding(.top, Space.md)
            content
                .font(Typo.font(Typo.body))
                .foregroundStyle(Theme.body)
                .lineSpacing(Space.xxs)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

struct BulletLine: View {
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: Space.xs) {
            Text("•")
                .foregroundStyle(Theme.neon)
            Text(text)
                .foregroundStyle(Theme.body)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .font(Typo.font(Typo.body))
        .lineSpacing(Space.xxs)
    }
}
