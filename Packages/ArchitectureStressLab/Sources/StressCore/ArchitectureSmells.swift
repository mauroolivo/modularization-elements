import Foundation

public struct AntiPatternExercise: Sendable {
    public let name: String
    public let harmfulObservation: String
    public let smell: String
    public let fix: String
    public let detectionRule: String

    public init(
        name: String,
        harmfulObservation: String,
        smell: String,
        fix: String,
        detectionRule: String
    ) {
        self.name = name
        self.harmfulObservation = harmfulObservation
        self.smell = smell
        self.fix = fix
        self.detectionRule = detectionRule
    }
}

public enum Stage16StressKit {
    public static let exercises: [AntiPatternExercise] = [
        AntiPatternExercise(
            name: "Feature cycle",
            harmfulObservation: "Two feature modules that import each other create compile-order deadlocks and hidden ownership conflicts.",
            smell: "Bidirectional compile-time dependency between vertical features.",
            fix: "Extract shared concepts to a dedicated domain boundary and keep app-level orchestration in the app layer.",
            detectionRule: "Reject any PR that introduces A -> B and B -> A between feature targets."
        ),
        AntiPatternExercise(
            name: "Giant Core",
            harmfulObservation: "A single Core module with mixed concerns becomes a high-fan-in bottleneck and broad rebuild trigger.",
            smell: "One shared target owning unrelated models, infrastructure, formatting, navigation, and utilities.",
            fix: "Split by responsibility: domain, infrastructure, and UI boundaries with explicit ownership.",
            detectionRule: "Flag shared modules that import unrelated frameworks or exceed a defined fan-in threshold."
        ),
        AntiPatternExercise(
            name: "Protocol explosion",
            harmfulObservation: "Tiny one-off protocols add indirection without improving substitutability or test seams.",
            smell: "Abstractions that mirror concrete implementations one-to-one.",
            fix: "Keep concrete types until multiple consumers need a stable seam, then introduce a focused protocol.",
            detectionRule: "Require at least two meaningful consumers before adding a new protocol boundary."
        ),
        AntiPatternExercise(
            name: "Micro-modules",
            harmfulObservation: "Over-splitting into tiny modules increases manifest churn and cognitive overhead for little isolation value.",
            smell: "Modules with minimal API surface and no independent evolution path.",
            fix: "Group tightly-coupled concepts into cohesive modules and split only at real volatility seams.",
            detectionRule: "Avoid new modules unless they have clear ownership, reuse, and independent change cadence."
        ),
        AntiPatternExercise(
            name: "Under-modularization",
            harmfulObservation: "A giant unrestricted target hides coupling and blocks independent testing and previews.",
            smell: "Unbounded feature, domain, and infrastructure code inside one module.",
            fix: "Extract vertical feature boundaries and enforce import direction from app composition to features.",
            detectionRule: "Disallow unrelated feature folders being compiled into a single long-lived target without rationale."
        )
    ]

    public static func stage16Report() -> String {
        exercises
            .map { item in
                """
                - \(item.name)
                  harmful: \(item.harmfulObservation)
                  smell: \(item.smell)
                  fix: \(item.fix)
                  rule: \(item.detectionRule)
                """
            }
            .joined(separator: "\n")
    }
}
