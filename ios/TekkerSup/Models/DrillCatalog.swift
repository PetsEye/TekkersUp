enum DrillCatalog {
    static let powerShot = Drill(
        id: "power-shot",
        name: "Power Shot",
        category: "Shooting / Power",
        blurb: "Load the kicking leg, swing through the ball, and plant firmly. Measures backswing depth, base stability and balance.",
        cockAngle: 120,
        extendAngle: 150,
        cues: [
            "Plant foot beside the ball, slightly behind it.",
            "Bring the kicking heel back toward the glute to load the leg.",
            "Keep the chest over the ball and the head down.",
            "Open the arms for counterbalance through the strike.",
        ],
        metrics: [
            MetricTarget(
                key: .backswing,
                label: "Backswing knee bend",
                min: 60,
                max: 100,
                unit: "°",
                decimals: 0,
                tipLow: "Heel is tucked too tight. Open the hip slightly so the leg can swing through with full extension.",
                tipHigh: "Not enough cock. Bring the kicking heel back toward your glute to load more power."
            ),
            MetricTarget(
                key: .support,
                label: "Plant knee at contact",
                min: 150,
                max: 175,
                unit: "°",
                decimals: 0,
                tipLow: "Plant knee is sinking too far. Stand taller over the ball for a stable base.",
                tipHigh: "Plant knee is locked straight. Keep a slight bend so you stay balanced."
            ),
            MetricTarget(
                key: .lean,
                label: "Torso lean",
                min: 0,
                max: 15,
                unit: "°",
                decimals: 0,
                tipLow: "Torso lean is off in the other direction. Stay balanced over your base.",
                tipHigh: "Leaning too far back or forward. Keep the chest over the ball and the head down."
            ),
            MetricTarget(
                key: .arms,
                label: "Arm balance (wrist spread)",
                min: 1.0,
                max: 2.5,
                unit: "x",
                decimals: 2,
                tipLow: "Arms are tucked in. Open them out to counterbalance the swing.",
                tipHigh: "Arms are flailing wide. Keep them under control to stay balanced."
            ),
        ],
        tracksBall: true
    )

    static let insidePass = Drill(
        id: "inside-pass",
        name: "Inside-Foot Pass",
        category: "Passing / Technique",
        blurb: "Short, controlled pass with the inside of the foot. Checks a smaller backswing, a balanced plant and an upright posture.",
        cockAngle: 150,
        extendAngle: 165,
        cues: [
            "Open the hips so the non-kicking foot points at the target.",
            "Small backswing: the kicking foot only moves a short distance.",
            "Strike through the centre of the ball with the inside of the foot.",
            "Stay tall through the pass and keep the arms relaxed.",
        ],
        metrics: [
            MetricTarget(
                key: .backswing,
                label: "Backswing knee bend",
                min: 110,
                max: 140,
                unit: "°",
                decimals: 0,
                tipLow: "Backswing is too big for a controlled pass. Shorten the leg swing.",
                tipHigh: "Backswing is too small. Let the knee bend a little more before the strike."
            ),
            MetricTarget(
                key: .support,
                label: "Plant knee at contact",
                min: 145,
                max: 170,
                unit: "°",
                decimals: 0,
                tipLow: "Plant knee is sinking too far. Stand taller over the ball.",
                tipHigh: "Plant knee is locked. Keep a soft bend for balance and touch."
            ),
            MetricTarget(
                key: .lean,
                label: "Torso lean",
                min: 0,
                max: 12,
                unit: "°",
                decimals: 0,
                tipLow: "Torso lean is off in the other direction. Stay balanced.",
                tipHigh: "Leaning too much. Keep the body upright for accurate passes."
            ),
            MetricTarget(
                key: .arms,
                label: "Arm balance (wrist spread)",
                min: 0.8,
                max: 2.0,
                unit: "x",
                decimals: 2,
                tipLow: "Arms are pinned to the body. Let them move naturally for balance.",
                tipHigh: "Arms are too wide for a passing motion. Bring them in closer."
            ),
        ],
        tracksBall: true
    )

    static let all: [Drill] = [powerShot, insidePass]
}
