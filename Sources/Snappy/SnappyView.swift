
import SwiftUI

/// `SnappyView` is a view that allows its content to be dragged and snaps it to specified points.
///
/// You can define snap points and the coordinate space in which the drag gesture operates.
///
/// - Example:
/// ```
/// SnappyView(snapPoints: .all - .top - .bottomLeading)
/// ```
///
///  This will create a view that can be dragged around and would snap to top left and right corners, left and right sides and bottom center and trailing side.
public struct SnappyView<Content: View, SnapPointContent: View>: View {
    
    @Binding var rememberedTranslation: CGSize

    @State private var translation: CGSize = .zero

    @State private var maxX: CGFloat = 0
    @State private var maxY: CGFloat = 0
    @State private var minX: CGFloat = 0
    @State private var minY: CGFloat = 0

    private var snapPoints: Set<UnitPoint>
    private var content: Content
    private var snapPointContent: SnapPointContent?
    private var coordinateSpace: CoordinateSpace
    private var shouldShowSnapPoints: Bool
    
    /// Initializes a new `SnappyView` with the given parameters.
    /// - Parameters:
    ///   - coordinateSpace: The coordinate space used for drag gestures. Defaults to `.local`.
    ///   - rememberedTranslation: An optional `Binding` to a `CGSize` that remembers the translation between interactions. Defaults to `nil`.
    ///   - snapPoints: A set of snap points (`UnitPoint`) to which the view will snap after dragging ends. Defaults to `Set<UnitPoint>.all`.
    ///   - content: The content of the view as a `ViewBuilder`.
    ///
    /// - Note:
    ///  This initializer will not show the snap points.
    ///  If you want to show the snap points, use the other initializer.
    ///
    public init(coordinateSpace: CoordinateSpace = .local
                , rememberedTranslation: Binding<CGSize>? = nil
                , snapPoints: Set<UnitPoint> = .all
                , @ViewBuilder content: () -> Content) where SnapPointContent == EmptyView {
        self.init(coordinateSpace: coordinateSpace
                  , rememberedTranslation: rememberedTranslation
                  , snapPoints: snapPoints
                  , content: content
                  , snapPointContent: { EmptyView() })
        shouldShowSnapPoints = false
    }
    
    /// Initializes a new `SnappyView` with the given parameters.
    /// - Parameters:
    ///   - coordinateSpace: The coordinate space used for drag gestures. Defaults to `.local`.
    ///   - rememberedTranslation: An optional `Binding` to a `CGSize` that remembers the translation between interactions. Defaults to `nil`.
    ///   - snapPoints: A set of snap points (`UnitPoint`) to which the view will snap after dragging ends. Defaults to `Set<UnitPoint>.all`.
    ///   - content: The content of the view as a `ViewBuilder`.
    ///   - snapPointContent: An content that will be displayed at the snap points. Can be used to mark the locations.
    ///
    ///   - Note:
    ///   This initializer will show the snap points.
    ///   If you do not want to show the snap points, use the other initializer.

    public init(coordinateSpace: CoordinateSpace = .local
                , rememberedTranslation: Binding<CGSize>? = nil
                , snapPoints: Set<UnitPoint> = .all
                , @ViewBuilder content: () -> Content
                , snapPointContent: () -> SnapPointContent) {
        self.content = content()
        self.snapPointContent = snapPointContent()
        self.coordinateSpace = coordinateSpace
        self.snapPoints = snapPoints
        self.shouldShowSnapPoints = true
        
        var tr: CGSize = .zero
        let translationBinding: Binding<CGSize> = rememberedTranslation
        ?? .init(
            get: { tr },
            set: { tr = $0 }
        )
        
        self._rememberedTranslation = translationBinding
    }
    
    public var body: some View {
        GeometryReader { geometry in
            content
                .background(GeometryReader { geo in
                    Color.clear
                        .preference(key: SnappyViewSizePreferenceKey.self, value: geo.size)
                })
                .onPreferenceChange(SnappyViewSizePreferenceKey.self) { size in
                    let limitOfMovement = limitOfMovement(in: geometry)
                    print(limitOfMovement)
                    let limitedRect = CGRect(x: limitOfMovement.minX,
                                             y: limitOfMovement.minY,
                                             width: limitOfMovement.width - size.width,
                                             height: limitOfMovement.height - size.height)
                    let halfWidth = size.width / 2
                    let halfHeight = size.height / 2
                    minX = limitedRect.minX + halfWidth
                    maxX = limitedRect.maxX + halfWidth
                    minY = limitedRect.minY + halfHeight
                    maxY = limitedRect.maxY + halfHeight
                }
            
                .offset(constrainTranslation(translation + rememberedTranslation))
                .overlay {
                    if let snapPointContent = snapPointContent {
                        ForEach(Array(snapPoints), id: \.self) { pt in
                            snapPointContent
                                .offset(x: pt.x * limitOfMovement(in: geometry).width, y: pt.y * limitOfMovement(in: geometry).height)
                        }
                    }
                }
                .animation(.interpolatingSpring(stiffness: 300, damping: 20), value: rememberedTranslation)
                .position(.zero)
                .gesture(
                    dragGesture(in: geometry)
                )
                .successFeedbackIfPossible(translation, { oldValue, newValue in
                    oldValue != .zero && newValue == .zero
                })
        }
        
    }
    
    private func limitOfMovement(in geometry: GeometryProxy) -> CGRect { geometry.frame(in: coordinateSpace) }
    
    private func closestSnapPoint(for location: CGPoint, in geometry: GeometryProxy) -> CGPoint? {
        guard !snapPoints.isEmpty
        else { return nil }
        let limitOfMovement = limitOfMovement(in: geometry)

        return snapPoints
            .map { ($0, CGPoint(x: $0.x * limitOfMovement.width, y: $0.y * limitOfMovement.height)) }
            .min(by: { $0.1.distance(to: location) < $1.1.distance(to: location) })!
            .1
    }
    
    private func dragGesture(in geometry: GeometryProxy) -> some Gesture {
        DragGesture(coordinateSpace: coordinateSpace)
            .onChanged { value in
                translation = value.translation
            }
            .onEnded { value in
                let endTranslation = value.predictedEndTranslation
                let newTranslation = endTranslation + rememberedTranslation
                
                var constrainedNewPosition = constrainTranslation(newTranslation)
                
                if let point = closestSnapPoint(for: value.predictedEndLocation, in: geometry) {
                    
                    constrainedNewPosition = constrainTranslation(CGSize(width: point.x
                                                                         , height: point.y))
                }
                
                rememberedTranslation =  constrainedNewPosition
                translation = .zero
            }
    }
    
    private func constrainTranslation(_ newTranslation: CGSize) -> CGSize {
        
        let constrainedX = min(max(newTranslation.width, minX), maxX)
        let constrainedY = min(max(newTranslation.height, minY), maxY)
        
        return CGSize(width: constrainedX, height: constrainedY)
    }
    
    struct SnappyViewSizePreferenceKey: PreferenceKey {
        nonisolated(unsafe) static var defaultValue: CGSize { .zero }
        
        static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
            // NO-OP
        }
    }
}

fileprivate extension View {
    @ViewBuilder
    func successFeedbackIfPossible<E: Equatable>(_ trigger: E, _ feedback: @escaping (E, E) -> Bool) -> some View {
        if #available(iOS 17.0, *) {
            self
                .sensoryFeedback(trigger: trigger, { feedback($0, $1) ? .success : nil })
        } else {
            self
        }
    }
}

