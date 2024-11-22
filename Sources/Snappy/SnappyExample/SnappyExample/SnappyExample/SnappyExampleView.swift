import SwiftUI
import Snappy

struct SnappyExampleView: View {
    @State var transition: CGSize = .zero
    var body: some View {
        VStack {
            Button("Reset") { transition = .zero }
                .buttonStyle(.borderedProminent)
            if #available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *) {
                Text("Position: \(transition)")
                    .contentTransition(.numericText(countsDown: true))
                    .animation(.default, value: transition)
            } else {
                Text("Position: \(transition)")
                    .animation(.default, value: transition)
            }
            SnappyView(coordinateSpace: .local
                       , rememberedTranslation: $transition
                       , snapPoints: .all - .top - .bottomLeading
            ) {
                Image(systemName: "music.note")
                    .font(.system(size: 60))
                    .foregroundColor(.accentColor)
                    .frame(width: 150, height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 30)
                            .fill(.tertiary.opacity(0.8))
                    )
            } snapPointContent: {
                Rectangle()
                    .fill(Color.accentColor)
                    .frame(width: 10, height: 10)
            }
            
        }
        .padding()
    }
}

#Preview {
    SnappyExampleView()
}
