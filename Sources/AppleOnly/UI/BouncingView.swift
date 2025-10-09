import SwiftUI

@available(tvOS 16, *)
public struct BouncingView<T: View>: View {
    @State private var scale: CGFloat = 1.0
    let content: () -> T

    public init(@ViewBuilder content: @escaping () -> T) {
        self.content = content
    }

    public var body: some View {
        content()
            .scaleEffect(scale)
            .onTapGesture {
                withAnimation {
                    scale = 0.8
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.10) {
                    withAnimation {
                        scale = 1.0
                    }
                }
            }
    }
}

@available(tvOS 16, *)
#Preview("Button") {
    BouncingView {
        Button(action: {}, label: { Text("Click Me!").font(.largeTitle) })
    }
}

@available(tvOS 16, *)
#Preview("Image") {
    BouncingView {
        Image(
            systemName: "square.and.arrow.up.trianglebadge.exclamationmark.fill"
        )
        .resizable()
        .aspectRatio(contentMode: .fit)
    }
}
