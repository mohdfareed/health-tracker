import Foundation
import SwiftUI

let weightUnit = UnitDefinition<UnitMass>(usage: .personWeight)

struct PreviewUnit: View {
    @Environment(\.unitService) var unitService
    @AppLocale var locale: Locale
    @LocalizedMeasurement var weight: Measurement<UnitMass>

    init(_ weight: Binding<Double?>) {
        self._weight = LocalizedMeasurement(
            weight, unit: .grams, definition: weightUnit
        )
    }

    var body: some View {
        VStack {
            HStack {
                Spacer()
                let model = Measurement(value: 1_200_000, unit: UnitDuration.seconds)
                Button(
                    "\(model.duration.formatted(.units(allowed: [.weeks], width: .abbreviated)))"
                ) {
                    print(UnitDuration.seconds.symbol)
                }
                Spacer()
            }

            VStack {
                HStack {
                    Text("Weight").font(.headline)
                    Spacer()
                    Text("\(self.$weight.formatted(base: .measurement(width: .wide))))")
                        .fontDesign(.monospaced)
                        .foregroundStyle(.secondary)
                }
                Divider()

                Picker("Locale", selection: self.$locale.units) {
                    ForEach(MeasurementSystem.measurementSystems, id: \.identifier) {
                        locale in
                        Text(locale.rawValue).tag(locale)
                    }
                }
                let units: [UnitMass] = [
                    UnitMass.grams, UnitMass.kilograms,
                    UnitMass.ounces, UnitMass.pounds,
                ]
                Picker("Unit", selection: self.$weight.unit) {
                    ForEach(units, id: \.self) { unit in
                        Text(unit.symbol).tag(unit)
                    }
                }
            }
            .padding()
            .background(.background.secondary)
            .cornerRadius(25)

            VStack {
                HStack {
                    Text("Localized")
                    Spacer()
                    Text(
                        "\(self._weight.formatted())"
                    )
                }
                Divider()
                HStack {
                    Text("Base Unit")
                    Spacer()
                    Text(
                        "\(self._weight.formatted(as: .baseUnit()))"
                    )
                }
                Divider()
                HStack {
                    Text("Pounds")
                    Spacer()
                    Text(
                        "\(self._weight.formatted(as: .pounds))"
                    )
                }
                Divider()
                HStack {
                    Text("Metric Tons")
                    Spacer()
                    Text(
                        "\(self._weight.formatted(as: .metricTons))"
                    )
                }
                Divider()
                HStack {
                    Text("MilliGrams")
                    Spacer()
                    Text(
                        "\(self._weight.formatted(as: .milligrams))"
                    )
                }
            }
            .padding()
            .background(.background.secondary)
            .cornerRadius(25)

            HStack {
                Text("Weight")
                Spacer()
                TextField(
                    "\(self.weight.formatted())",
                    value: self.$weight.value,
                    format: .number.precision(.fractionLength(2))
                )
                .textFieldStyle(.automatic)
                .multilineTextAlignment(.trailing)
                Text("\(self.weight.unit.symbol)")
            }
            .padding()
        }
        // .animation(.default, value: self.locale)
        .animation(.default, value: self.weight)
    }
}

// MARK: Preview
// ============================================================================

#if DEBUG
    struct PreviewUnitView: View {
        @State var weightValue: Double = 0.0

        var body: some View {
            PreviewUnit(self.$weightValue.optional(0))
                .padding()
                .background(.background.secondary)
                .cornerRadius(25)
                .padding()
        }
    }
#endif

#Preview {
    PreviewUnitView()
        .preferredColorScheme(.dark)
}
