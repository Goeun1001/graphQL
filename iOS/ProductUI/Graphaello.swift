// swiftlint:disable all
// This file was automatically generated and should not be edited.

import Apollo
import Combine
import Foundation
import SwiftUI

// MARK: Basic API

protocol Target {}

protocol API: Target {
    var client: ApolloClient { get }
}

extension API {
    func fetch<Query: GraphQLQuery>(query: Query, completion: @escaping (Result<Query.Data, GraphQLLoadingError<Self>>) -> Void) {
        client.fetch(query: query) { result in
            switch result {
            case let .success(result):
                guard let data = result.data else {
                    if let errors = result.errors, errors.count > 0 {
                        return completion(.failure(.graphQLErrors(errors)))
                    }
                    return completion(.failure(.emptyData(api: self)))
                }
                completion(.success(data))
            case let .failure(error):
                completion(.failure(.networkError(error)))
            }
        }
    }
}

protocol MutationTarget: Target {}

protocol Connection: Target {
    associatedtype Node
}

protocol Fragment {
    associatedtype UnderlyingType
    static var placeholder: Self { get }
}

extension Array: Fragment where Element: Fragment {
    typealias UnderlyingType = [Element.UnderlyingType]

    static var placeholder: [Element] {
        return Array(repeating: Element.placeholder, count: 5)
    }
}

extension Optional: Fragment where Wrapped: Fragment {
    typealias UnderlyingType = Wrapped.UnderlyingType?

    static var placeholder: Wrapped? {
        return Wrapped.placeholder
    }
}

protocol Mutation: ObservableObject {
    associatedtype Value

    var isLoading: Bool { get }
}

protocol CurrentValueMutation: ObservableObject {
    associatedtype Value

    var isLoading: Bool { get }
    var value: Value { get }
    var error: Error? { get }
}

// MARK: - Basic API: Paths

struct GraphQLPath<TargetType: Target, Value> {
    fileprivate init() {}
}

struct GraphQLFragmentPath<TargetType: Target, UnderlyingType> {
    fileprivate init() {}
}

extension GraphQLFragmentPath {
    typealias Path<V> = GraphQLPath<TargetType, V>
    typealias FragmentPath<V> = GraphQLFragmentPath<TargetType, V>
}

extension GraphQLFragmentPath {
    var _fragment: FragmentPath<UnderlyingType> {
        return self
    }
}

extension GraphQLFragmentPath {
    func _forEach<Value, Output>(_: KeyPath<GraphQLFragmentPath<TargetType, Value>, GraphQLPath<TargetType, Output>>) -> GraphQLPath<TargetType, [Output]> where UnderlyingType == [Value] {
        return .init()
    }

    func _forEach<Value, Output>(_: KeyPath<GraphQLFragmentPath<TargetType, Value>, GraphQLPath<TargetType, Output>>) -> GraphQLPath<TargetType, [Output]?> where UnderlyingType == [Value]? {
        return .init()
    }
}

extension GraphQLFragmentPath {
    func _forEach<Value, Output>(_: KeyPath<GraphQLFragmentPath<TargetType, Value>, GraphQLFragmentPath<TargetType, Output>>) -> GraphQLFragmentPath<TargetType, [Output]> where UnderlyingType == [Value] {
        return .init()
    }

    func _forEach<Value, Output>(_: KeyPath<GraphQLFragmentPath<TargetType, Value>, GraphQLFragmentPath<TargetType, Output>>) -> GraphQLFragmentPath<TargetType, [Output]?> where UnderlyingType == [Value]? {
        return .init()
    }
}

extension GraphQLFragmentPath {
    func _flatten<T>() -> GraphQLFragmentPath<TargetType, [T]> where UnderlyingType == [[T]] {
        return .init()
    }

    func _flatten<T>() -> GraphQLFragmentPath<TargetType, [T]?> where UnderlyingType == [[T]]? {
        return .init()
    }
}

extension GraphQLPath {
    func _flatten<T>() -> GraphQLPath<TargetType, [T]> where Value == [[T]] {
        return .init()
    }

    func _flatten<T>() -> GraphQLPath<TargetType, [T]?> where Value == [[T]]? {
        return .init()
    }
}

extension GraphQLFragmentPath {
    func _compactMap<T>() -> GraphQLFragmentPath<TargetType, [T]> where UnderlyingType == [T?] {
        return .init()
    }

    func _compactMap<T>() -> GraphQLFragmentPath<TargetType, [T]?> where UnderlyingType == [T?]? {
        return .init()
    }
}

extension GraphQLPath {
    func _compactMap<T>() -> GraphQLPath<TargetType, [T]> where Value == [T?] {
        return .init()
    }

    func _compactMap<T>() -> GraphQLPath<TargetType, [T]?> where Value == [T?]? {
        return .init()
    }
}

extension GraphQLFragmentPath {
    func _nonNull<T>() -> GraphQLFragmentPath<TargetType, T> where UnderlyingType == T? {
        return .init()
    }
}

extension GraphQLPath {
    func _nonNull<T>() -> GraphQLPath<TargetType, T> where Value == T? {
        return .init()
    }
}

extension GraphQLFragmentPath {
    func _withDefault<T>(_: @autoclosure () -> T) -> GraphQLFragmentPath<TargetType, T> where UnderlyingType == T? {
        return .init()
    }
}

extension GraphQLPath {
    func _withDefault<T>(_: @autoclosure () -> T) -> GraphQLPath<TargetType, T> where Value == T? {
        return .init()
    }
}

// MARK: - Basic API: Arguments

enum GraphQLArgument<Value> {
    enum QueryArgument {
        case withDefault(Value)
        case forced
    }

    case value(Value)
    case argument(QueryArgument)
}

extension GraphQLArgument {
    static var argument: GraphQLArgument<Value> {
        return .argument(.forced)
    }

    static func argument(default value: Value) -> GraphQLArgument<Value> {
        return .argument(.withDefault(value))
    }
}

// MARK: - Basic API: Paging

class Paging<Value: Fragment>: DynamicProperty, ObservableObject {
    fileprivate struct Response {
        let values: [Value]
        let cursor: String?
        let hasMore: Bool

        static var empty: Response {
            Response(values: [], cursor: nil, hasMore: false)
        }
    }

    fileprivate typealias Completion = (Result<Response, Error>) -> Void
    fileprivate typealias Loader = (String, Int?, @escaping Completion) -> Void

    private let loader: Loader

    @Published
    private(set) var isLoading: Bool = false

    @Published
    private(set) var values: [Value] = []

    private var cursor: String?

    @Published
    private(set) var hasMore: Bool = false

    @Published
    private(set) var error: Error? = nil

    fileprivate init(_ response: Response, loader: @escaping Loader) {
        self.loader = loader
        use(response)
    }

    func loadMore(pageSize: Int? = nil) {
        guard let cursor = cursor, !isLoading else { return }
        isLoading = true
        loader(cursor, pageSize) { [weak self] result in
            switch result {
            case let .success(response):
                self?.use(response)
            case let .failure(error):
                self?.handle(error)
            }
        }
    }

    private func use(_ response: Response) {
        isLoading = false
        values += response.values
        cursor = response.cursor
        hasMore = response.hasMore
    }

    private func handle(_ error: Error) {
        isLoading = false
        hasMore = false
        self.error = error
    }
}

// MARK: - Basic API: Error Types

enum GraphQLLoadingError<T: API>: Error {
    case emptyData(api: T)
    case graphQLErrors([GraphQLError])
    case networkError(Error)
}

// MARK: - Basic API: Refresh

protocol QueryRefreshController {
    func refresh()
    func refresh(completion: @escaping (Error?) -> Void)
}

private struct QueryRefreshControllerEnvironmentKey: EnvironmentKey {
    static let defaultValue: QueryRefreshController? = nil
}

extension EnvironmentValues {
    var queryRefreshController: QueryRefreshController? {
        get {
            self[QueryRefreshControllerEnvironmentKey.self]
        } set {
            self[QueryRefreshControllerEnvironmentKey.self] = newValue
        }
    }
}

// MARK: - Error Handling

enum QueryError {
    case network(Error)
    case graphql([GraphQLError])
}

extension QueryError: CustomStringConvertible {
    var description: String {
        switch self {
        case let .network(error):
            return error.localizedDescription
        case let .graphql(errors):
            return errors.map { $0.description }.joined(separator: ", ")
        }
    }
}

extension QueryError {
    var networkError: Error? {
        guard case let .network(error) = self else { return nil }
        return error
    }

    var graphQLErrors: [GraphQLError]? {
        guard case let .graphql(errors) = self else { return nil }
        return errors
    }
}

protocol QueryErrorController {
    var error: QueryError? { get }
    func clear()
}

private struct QueryErrorControllerEnvironmentKey: EnvironmentKey {
    static let defaultValue: QueryErrorController? = nil
}

extension EnvironmentValues {
    var queryErrorController: QueryErrorController? {
        get {
            self[QueryErrorControllerEnvironmentKey.self]
        } set {
            self[QueryErrorControllerEnvironmentKey.self] = newValue
        }
    }
}

// MARK: - Basic API: Views

private struct QueryRenderer<Query: GraphQLQuery, Loading: View, Error: View, Content: View>: View {
    typealias ContentFactory = (Query.Data) -> Content
    typealias ErrorFactory = (QueryError) -> Error

    private final class ViewModel: ObservableObject {
        @Published var isLoading: Bool = false
        @Published var value: Query.Data? = nil
        @Published var error: QueryError? = nil

        private var previous: Query?
        private var cancellable: Apollo.Cancellable?

        deinit {
            cancel()
        }

        func load(client: ApolloClient, query: Query) {
            guard previous !== query || (value == nil && !isLoading) else { return }
            perform(client: client, query: query)
        }

        func refresh(client: ApolloClient, query: Query, completion: ((Swift.Error?) -> Void)? = nil) {
            perform(client: client, query: query, cachePolicy: .fetchIgnoringCacheData, completion: completion)
        }

        private func perform(client: ApolloClient, query: Query, cachePolicy: CachePolicy = .returnCacheDataElseFetch, completion: ((Swift.Error?) -> Void)? = nil) {
            previous = query
            cancellable = client.fetch(query: query, cachePolicy: cachePolicy) { [weak self] result in
                defer {
                    self?.cancellable = nil
                    self?.isLoading = false
                }
                switch result {
                case let .success(result):
                    self?.value = result.data
                    self?.error = result.errors.map { .graphql($0) }
                    completion?(nil)
                case let .failure(error):
                    self?.error = .network(error)
                    completion?(error)
                }
            }
            isLoading = true
        }

        func cancel() {
            cancellable?.cancel()
        }
    }

    private struct RefreshController: QueryRefreshController {
        let client: ApolloClient
        let query: Query
        let viewModel: ViewModel

        func refresh() {
            viewModel.refresh(client: client, query: query)
        }

        func refresh(completion: @escaping (Swift.Error?) -> Void) {
            viewModel.refresh(client: client, query: query, completion: completion)
        }
    }

    private struct ErrorController: QueryErrorController {
        let viewModel: ViewModel

        var error: QueryError? {
            return viewModel.error
        }

        func clear() {
            viewModel.error = nil
        }
    }

    let client: ApolloClient
    let query: Query
    let loading: Loading
    let error: ErrorFactory
    let factory: ContentFactory

    @ObservedObject private var viewModel = ViewModel()
    @State private var hasAppeared = false

    var body: some View {
        if hasAppeared {
            self.viewModel.load(client: self.client, query: self.query)
        }
        return VStack {
            viewModel.isLoading && viewModel.value == nil && viewModel.error == nil ? loading : nil
            viewModel.value == nil ? viewModel.error.map(error) : nil
            viewModel
                .value
                .map(factory)
                .environment(\.queryRefreshController, RefreshController(client: client, query: query, viewModel: viewModel))
                .environment(\.queryErrorController, ErrorController(viewModel: viewModel))
        }
        .onAppear {
            DispatchQueue.main.async {
                self.hasAppeared = true
            }
            self.viewModel.load(client: self.client, query: self.query)
        }
        .onDisappear {
            DispatchQueue.main.async {
                self.hasAppeared = false
            }
            self.viewModel.cancel()
        }
    }
}

private struct BasicErrorView: View {
    let error: QueryError

    var body: some View {
        Text("Error: \(error.description)")
    }
}

private struct BasicLoadingView: View {
    var body: some View {
        Text("Loading")
    }
}

struct PagingView<Value: Fragment>: View {
    enum Mode {
        case list
        case vertical(alignment: HorizontalAlignment = .center, spacing: CGFloat? = nil, insets: EdgeInsets = EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
        case horizontal(alignment: VerticalAlignment = .center, spacing: CGFloat? = nil, insets: EdgeInsets = EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
    }

    enum Data {
        case item(Value, Int)
        case loading
        case error(Error)

        fileprivate var id: String {
            switch self {
            case let .item(_, int):
                return int.description
            case .error:
                return "error"
            case .loading:
                return "loading"
            }
        }
    }

    @ObservedObject private var paging: Paging<Value>
    private let mode: Mode
    private let pageSize: Int?
    private var loader: (Data) -> AnyView

    @State private var visibleRect: CGRect = .zero

    init(_ paging: Paging<Value>, mode: Mode = .list, pageSize: Int? = nil, loader: @escaping (Data) -> AnyView) {
        self.paging = paging
        self.mode = mode
        self.pageSize = pageSize
        self.loader = loader
    }

    var body: some View {
        let data = self.paging.values.enumerated().map { Data.item($0.element, $0.offset) } +
            [self.paging.isLoading ? Data.loading : nil, self.paging.error.map(Data.error)].compactMap { $0 }

        switch mode {
        case .list:
            return AnyView(
                List(data, id: \.id) { data in
                    self.loader(data).onAppear { self.onAppear(data: data) }
                }
            )
        case let .vertical(alignment, spacing, insets):
            return AnyView(
                ScrollView(.horizontal, showsIndicators: false) {
                    VStack(alignment: alignment, spacing: spacing) {
                        ForEach(data, id: \.id) { data in
                            self.loader(data).ifVisible(in: self.visibleRect, in: .named("InfiniteVerticalScroll")) { self.onAppear(data: data) }
                        }
                    }
                    .padding(insets)
                }
                .coordinateSpace(name: "InfiniteVerticalScroll")
                .rectReader($visibleRect, in: .named("InfiniteVerticalScroll"))
            )
        case let .horizontal(alignment, spacing, insets):
            return AnyView(
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: alignment, spacing: spacing) {
                        ForEach(data, id: \.id) { data in
                            self.loader(data).ifVisible(in: self.visibleRect, in: .named("InfiniteHorizontalScroll")) { self.onAppear(data: data) }
                        }
                    }
                    .padding(insets)
                }
                .coordinateSpace(name: "InfiniteHorizontalScroll")
                .rectReader($visibleRect, in: .named("InfiniteHorizontalScroll"))
            )
        }
    }

    private func onAppear(data: Data) {
        guard !paging.isLoading,
            paging.hasMore,
            case let .item(_, index) = data,
            index > paging.values.count - 2 else { return }

        DispatchQueue.main.async {
            paging.loadMore(pageSize: pageSize)
        }
    }
}

extension PagingView {
    init<Loading: View, Error: View, Data: View>(_ paging: Paging<Value>,
                                                 mode: Mode = .list,
                                                 pageSize: Int? = nil,
                                                 loading loadingView: @escaping () -> Loading,
                                                 error errorView: @escaping (Swift.Error) -> Error,
                                                 item itemView: @escaping (Value) -> Data) {
        self.init(paging, mode: mode, pageSize: pageSize) { data in
            switch data {
            case let .item(item, _):
                return AnyView(itemView(item))
            case let .error(error):
                return AnyView(errorView(error))
            case .loading:
                return AnyView(loadingView())
            }
        }
    }

    init<Error: View, Data: View>(_ paging: Paging<Value>,
                                  mode: Mode = .list,
                                  pageSize: Int? = nil,
                                  error errorView: @escaping (Swift.Error) -> Error,
                                  item itemView: @escaping (Value) -> Data) {
        self.init(paging,
                  mode: mode,
                  pageSize: pageSize,
                  loading: { PagingBasicLoadingView(content: itemView) },
                  error: errorView,
                  item: itemView)
    }

    init<Loading: View, Data: View>(_ paging: Paging<Value>,
                                    mode: Mode = .list,
                                    pageSize: Int? = nil,
                                    loading loadingView: @escaping () -> Loading,
                                    item itemView: @escaping (Value) -> Data) {
        self.init(paging,
                  mode: mode,
                  pageSize: pageSize,
                  loading: loadingView,
                  error: { Text("Error: \($0.localizedDescription)") },
                  item: itemView)
    }

    init<Data: View>(_ paging: Paging<Value>,
                     mode: Mode = .list,
                     pageSize: Int? = nil,
                     item itemView: @escaping (Value) -> Data) {
        self.init(paging,
                  mode: mode,
                  pageSize: pageSize,
                  loading: { PagingBasicLoadingView(content: itemView) },
                  error: { Text("Error: \($0.localizedDescription)") },
                  item: itemView)
    }
}

private struct PagingBasicLoadingView<Value: Fragment, Content: View>: View {
    let content: (Value) -> Content

    var body: some View {
        if #available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *) {
            content(.placeholder).disabled(true).redacted(reason: .placeholder)
        } else {
            BasicLoadingView()
        }
    }
}

extension PagingView.Mode {
    static func vertical(alignment: HorizontalAlignment = .center, spacing: CGFloat? = nil, padding edges: Edge.Set, by padding: CGFloat) -> PagingView.Mode {
        return .vertical(alignment: alignment,
                         spacing: spacing,
                         insets: EdgeInsets(top: edges.contains(.top) ? padding : 0,
                                            leading: edges.contains(.leading) ? padding : 0,
                                            bottom: edges.contains(.bottom) ? padding : 0,
                                            trailing: edges.contains(.trailing) ? padding : 0))
    }

    static func vertical(alignment: HorizontalAlignment = .center, spacing: CGFloat? = nil, padding: CGFloat) -> PagingView.Mode {
        return .vertical(alignment: alignment, spacing: spacing, padding: .all, by: padding)
    }

    static var vertical: PagingView.Mode { .vertical() }

    static func horizontal(alignment: VerticalAlignment = .center, spacing: CGFloat? = nil, padding edges: Edge.Set, by padding: CGFloat) -> PagingView.Mode {
        return .horizontal(alignment: alignment,
                           spacing: spacing,
                           insets: EdgeInsets(top: edges.contains(.top) ? padding : 0,
                                              leading: edges.contains(.leading) ? padding : 0,
                                              bottom: edges.contains(.bottom) ? padding : 0,
                                              trailing: edges.contains(.trailing) ? padding : 0))
    }

    static func horizontal(alignment: VerticalAlignment = .center, spacing: CGFloat? = nil, padding: CGFloat) -> PagingView.Mode {
        return .horizontal(alignment: alignment, spacing: spacing, padding: .all, by: padding)
    }

    static var horizontal: PagingView.Mode { .horizontal() }
}

extension View {
    fileprivate func rectReader(_ binding: Binding<CGRect>, in space: CoordinateSpace) -> some View {
        background(GeometryReader { (geometry) -> AnyView in
            let rect = geometry.frame(in: space)
            DispatchQueue.main.async {
                binding.wrappedValue = rect
            }
            return AnyView(Rectangle().fill(Color.clear))
        })
    }
}

extension View {
    fileprivate func ifVisible(in rect: CGRect, in space: CoordinateSpace, execute: @escaping () -> Void) -> some View {
        background(GeometryReader { (geometry) -> AnyView in
            let frame = geometry.frame(in: space)
            if frame.intersects(rect) {
                execute()
            }
            return AnyView(Rectangle().fill(Color.clear))
        })
    }
}

// MARK: - Basic API: Decoders

protocol GraphQLValueDecoder {
    associatedtype Encoded
    associatedtype Decoded

    static func decode(encoded: Encoded) throws -> Decoded
}

enum NoOpDecoder<T>: GraphQLValueDecoder {
    static func decode(encoded: T) throws -> T {
        return encoded
    }
}

// MARK: - Basic API: Scalar Handling

protocol GraphQLScalar {
    associatedtype Scalar
    static var placeholder: Self { get }
    init(from scalar: Scalar) throws
}

extension Array: GraphQLScalar where Element: GraphQLScalar {
    static var placeholder: [Element] {
        return Array(repeating: Element.placeholder, count: 5)
    }

    init(from scalar: [Element.Scalar]) throws {
        self = try scalar.map { try Element(from: $0) }
    }
}

extension Optional: GraphQLScalar where Wrapped: GraphQLScalar {
    static var placeholder: Wrapped? {
        return Wrapped.placeholder
    }

    init(from scalar: Wrapped.Scalar?) throws {
        guard let scalar = scalar else {
            self = .none
            return
        }
        self = .some(try Wrapped(from: scalar))
    }
}

extension URL: GraphQLScalar {
    typealias Scalar = String

    static let placeholder: URL = URL(string: "https://graphaello.dev/assets/logo.png")!

    private struct URLScalarDecodingError: Error {
        let string: String
    }

    init(from string: Scalar) throws {
        guard let url = URL(string: string) else {
            throw URLScalarDecodingError(string: string)
        }
        self = url
    }
}

enum ScalarDecoder<ScalarType: GraphQLScalar>: GraphQLValueDecoder {
    typealias Encoded = ScalarType.Scalar
    typealias Decoded = ScalarType

    static func decode(encoded: ScalarType.Scalar) throws -> ScalarType {
        if let encoded = encoded as? String, encoded == "__GRAPHAELLO_PLACEHOLDER__" {
            return Decoded.placeholder
        }
        return try ScalarType(from: encoded)
    }
}

// MARK: - Basic API: HACK - AnyObservableObject

private class AnyObservableObject: ObservableObject {
    let objectWillChange = ObservableObjectPublisher()
    var cancellable: AnyCancellable?

    func use<O: ObservableObject>(_ object: O) {
        cancellable?.cancel()
        cancellable = object.objectWillChange.sink { [unowned self] _ in self.objectWillChange.send() }
    }
}

// MARK: - Basic API: Graph QL Property Wrapper

@propertyWrapper
struct GraphQL<Decoder: GraphQLValueDecoder>: DynamicProperty {
    private let initialValue: Decoder.Decoded

    @State
    private var value: Decoder.Decoded? = nil

    @ObservedObject
    private var observed: AnyObservableObject = AnyObservableObject()
    private let updateObserved: ((Decoder.Decoded) -> Void)?

    var wrappedValue: Decoder.Decoded {
        get {
            return value ?? initialValue
        }
        nonmutating set {
            value = newValue
            updateObserved?(newValue)
        }
    }

    var projectedValue: Binding<Decoder.Decoded> {
        return Binding(get: { self.wrappedValue }, set: { newValue in self.wrappedValue = newValue })
    }

    init<T: Target>(_: @autoclosure () -> GraphQLPath<T, Decoder.Encoded>) {
        fatalError("Initializer with path only should never be used")
    }

    init<T: Target, Value>(_: @autoclosure () -> GraphQLPath<T, Value>) where Decoder == NoOpDecoder<Value> {
        fatalError("Initializer with path only should never be used")
    }

    init<T: Target, Value: GraphQLScalar>(_: @autoclosure () -> GraphQLPath<T, Value.Scalar>) where Decoder == ScalarDecoder<Value> {
        fatalError("Initializer with path only should never be used")
    }

    fileprivate init(_ wrappedValue: Decoder.Encoded) {
        initialValue = try! Decoder.decode(encoded: wrappedValue)
        updateObserved = nil
    }

    mutating func update() {
        _value.update()
        _observed.update()
    }
}

extension GraphQL where Decoder.Decoded: ObservableObject {
    fileprivate init(_ wrappedValue: Decoder.Encoded) {
        let value = try! Decoder.decode(encoded: wrappedValue)
        initialValue = value

        let observed = AnyObservableObject()
        observed.use(value)

        self.observed = observed
        updateObserved = { observed.use($0) }
    }
}

extension GraphQL {
    init<T: Target, Value: Fragment>(_: @autoclosure () -> GraphQLFragmentPath<T, Value.UnderlyingType>) where Decoder == NoOpDecoder<Value> {
        fatalError("Initializer with path only should never be used")
    }
}

extension GraphQL {
    init<T: API, C: Connection, F: Fragment>(_: @autoclosure () -> GraphQLFragmentPath<T, C>) where Decoder == NoOpDecoder<Paging<F>>, C.Node == F.UnderlyingType {
        fatalError("Initializer with path only should never be used")
    }

    init<T: API, C: Connection, F: Fragment>(_: @autoclosure () -> GraphQLFragmentPath<T, C?>) where Decoder == NoOpDecoder<Paging<F>?>, C.Node == F.UnderlyingType {
        fatalError("Initializer with path only should never be used")
    }
}

extension GraphQL {
    init<T: MutationTarget, MutationType: Mutation>(_: @autoclosure () -> GraphQLPath<T, MutationType.Value>) where Decoder == NoOpDecoder<MutationType> {
        fatalError("Initializer with path only should never be used")
    }

    init<T: MutationTarget, MutationType: Mutation>(_: @autoclosure () -> GraphQLFragmentPath<T, MutationType.Value.UnderlyingType>) where Decoder == NoOpDecoder<MutationType>, MutationType.Value: Fragment {
        fatalError("Initializer with path only should never be used")
    }
}

extension GraphQL {
    init<T: Target, M: MutationTarget, MutationType: CurrentValueMutation>(_: @autoclosure () -> GraphQLPath<T, MutationType.Value>, mutation _: @autoclosure () -> GraphQLPath<M, MutationType.Value>) where Decoder == NoOpDecoder<MutationType> {
        fatalError("Initializer with path only should never be used")
    }

    init<T: Target, M: MutationTarget, MutationType: CurrentValueMutation>(_: @autoclosure () -> GraphQLFragmentPath<T, MutationType.Value.UnderlyingType>, mutation _: @autoclosure () -> GraphQLFragmentPath<M, MutationType.Value.UnderlyingType>) where Decoder == NoOpDecoder<MutationType>, MutationType.Value: Fragment {
        fatalError("Initializer with path only should never be used")
    }
}


// MARK: - LOCAL

#if GRAPHAELLO_PRODUCT_UI_TARGET

    struct LOCAL: API {
        let client: ApolloClient

        typealias Query = LOCAL
        typealias Path<V> = GraphQLPath<LOCAL, V>
        typealias FragmentPath<V> = GraphQLFragmentPath<LOCAL, V>

        enum Mutation: MutationTarget {
            typealias Path<V> = GraphQLPath<LOCAL.Mutation, V>
            typealias FragmentPath<V> = GraphQLFragmentPath<LOCAL.Mutation, V>

            static func createProduct(category _: GraphQLArgument<[String?]?> = .argument,
                                      dateCreated _: GraphQLArgument<String?> = .argument,
                                      inStock _: GraphQLArgument<Bool?> = .argument,
                                      name _: GraphQLArgument<String?> = .argument,
                                      price _: GraphQLArgument<Double?> = .argument) -> FragmentPath<LOCAL.CreateProduct?> {
                return .init()
            }

            static var createProduct: FragmentPath<LOCAL.CreateProduct?> { .init() }

            static func updateProduct(category _: GraphQLArgument<[String?]?> = .argument,
                                      dateCreated _: GraphQLArgument<String?> = .argument,
                                      id _: GraphQLArgument<String?> = .argument,
                                      inStock _: GraphQLArgument<Bool?> = .argument,
                                      name _: GraphQLArgument<String?> = .argument,
                                      price _: GraphQLArgument<Double?> = .argument) -> FragmentPath<LOCAL.UpdateProduct?> {
                return .init()
            }

            static var updateProduct: FragmentPath<LOCAL.UpdateProduct?> { .init() }

            static func deleteProduct(id _: GraphQLArgument<String?> = .argument) -> FragmentPath<LOCAL.DeleteProduct?> {
                return .init()
            }

            static var deleteProduct: FragmentPath<LOCAL.DeleteProduct?> { .init() }

            static func createCategory(name _: GraphQLArgument<String?> = .argument) -> FragmentPath<LOCAL.CreateCategory?> {
                return .init()
            }

            static var createCategory: FragmentPath<LOCAL.CreateCategory?> { .init() }

            static func updateCategory(id _: GraphQLArgument<String?> = .argument,
                                       name _: GraphQLArgument<String?> = .argument) -> FragmentPath<LOCAL.UpdateCategory?> {
                return .init()
            }

            static var updateCategory: FragmentPath<LOCAL.UpdateCategory?> { .init() }

            static func deleteCategory(id _: GraphQLArgument<String?> = .argument) -> FragmentPath<LOCAL.DeleteCategory?> {
                return .init()
            }

            static var deleteCategory: FragmentPath<LOCAL.DeleteCategory?> { .init() }
        }

        static var allProducts: FragmentPath<[LOCAL.ProductType]?> { .init() }

        static func product(id _: GraphQLArgument<String?> = .argument) -> FragmentPath<LOCAL.ProductType?> {
            return .init()
        }

        static var product: FragmentPath<LOCAL.ProductType?> { .init() }

        static var allCategories: FragmentPath<[LOCAL.CategoryType?]?> { .init() }

        static func category(id _: GraphQLArgument<String?> = .argument) -> FragmentPath<LOCAL.CategoryType?> {
            return .init()
        }

        static var category: FragmentPath<LOCAL.CategoryType?> { .init() }

        enum ProductType: Target {
            typealias Path<V> = GraphQLPath<ProductType, V>
            typealias FragmentPath<V> = GraphQLFragmentPath<ProductType, V>

            static var id: Path<String> { .init() }

            static var name: Path<String> { .init() }

            static var price: Path<String> { .init() }

            static var category: FragmentPath<[LOCAL.CategoryType]> { .init() }

            static var inStock: Path<Bool> { .init() }

            static var dateCreated: Path<String?> { .init() }

            static var _fragment: FragmentPath<ProductType> { .init() }
        }

        enum CategoryType: Target {
            typealias Path<V> = GraphQLPath<CategoryType, V>
            typealias FragmentPath<V> = GraphQLFragmentPath<CategoryType, V>

            static var id: Path<String> { .init() }

            static var name: Path<String> { .init() }

            static var productSet: FragmentPath<[LOCAL.ProductType]> { .init() }

            static var _fragment: FragmentPath<CategoryType> { .init() }
        }

        enum CreateProduct: Target {
            typealias Path<V> = GraphQLPath<CreateProduct, V>
            typealias FragmentPath<V> = GraphQLFragmentPath<CreateProduct, V>

            static var product: FragmentPath<LOCAL.ProductType?> { .init() }

            static var _fragment: FragmentPath<CreateProduct> { .init() }
        }

        enum UpdateProduct: Target {
            typealias Path<V> = GraphQLPath<UpdateProduct, V>
            typealias FragmentPath<V> = GraphQLFragmentPath<UpdateProduct, V>

            static var product: FragmentPath<LOCAL.ProductType?> { .init() }

            static var _fragment: FragmentPath<UpdateProduct> { .init() }
        }

        enum DeleteProduct: Target {
            typealias Path<V> = GraphQLPath<DeleteProduct, V>
            typealias FragmentPath<V> = GraphQLFragmentPath<DeleteProduct, V>

            static var product: FragmentPath<LOCAL.ProductType?> { .init() }

            static var _fragment: FragmentPath<DeleteProduct> { .init() }
        }

        enum CreateCategory: Target {
            typealias Path<V> = GraphQLPath<CreateCategory, V>
            typealias FragmentPath<V> = GraphQLFragmentPath<CreateCategory, V>

            static var category: FragmentPath<LOCAL.CategoryType?> { .init() }

            static var _fragment: FragmentPath<CreateCategory> { .init() }
        }

        enum UpdateCategory: Target {
            typealias Path<V> = GraphQLPath<UpdateCategory, V>
            typealias FragmentPath<V> = GraphQLFragmentPath<UpdateCategory, V>

            static var category: FragmentPath<LOCAL.CategoryType?> { .init() }

            static var _fragment: FragmentPath<UpdateCategory> { .init() }
        }

        enum DeleteCategory: Target {
            typealias Path<V> = GraphQLPath<DeleteCategory, V>
            typealias FragmentPath<V> = GraphQLFragmentPath<DeleteCategory, V>

            static var category: FragmentPath<LOCAL.CategoryType?> { .init() }

            static var _fragment: FragmentPath<DeleteCategory> { .init() }
        }
    }

    extension LOCAL {
        init(url: URL = URL(string: "http://localhost:8000/graphql/")!,
             client: URLSessionClient = URLSessionClient(),
             useGETForQueries: Bool = false,
             enableAutoPersistedQueries: Bool = false,
             useGETForPersistedQueryRetry: Bool = false,
             requestBodyCreator: RequestBodyCreator = ApolloRequestBodyCreator(),
             store: ApolloStore = ApolloStore(cache: InMemoryNormalizedCache())) {
            let provider = LegacyInterceptorProvider(client: client, store: store)
            let networkTransport = RequestChainNetworkTransport(interceptorProvider: provider,
                                                                endpointURL: url,
                                                                autoPersistQueries: enableAutoPersistedQueries,
                                                                requestBodyCreator: requestBodyCreator,
                                                                useGETForQueries: useGETForQueries,
                                                                useGETForPersistedQueryRetry: useGETForPersistedQueryRetry)
            self.init(client: ApolloClient(networkTransport: networkTransport, store: store))
        }
    }

    extension GraphQLFragmentPath where UnderlyingType == LOCAL.ProductType {
        var id: Path<String> { .init() }

        var name: Path<String> { .init() }

        var price: Path<String> { .init() }

        var category: FragmentPath<[LOCAL.CategoryType]> { .init() }

        var inStock: Path<Bool> { .init() }

        var dateCreated: Path<String?> { .init() }
    }

    extension GraphQLFragmentPath where UnderlyingType == LOCAL.ProductType? {
        var id: Path<String?> { .init() }

        var name: Path<String?> { .init() }

        var price: Path<String?> { .init() }

        var category: FragmentPath<[LOCAL.CategoryType]?> { .init() }

        var inStock: Path<Bool?> { .init() }

        var dateCreated: Path<String?> { .init() }
    }

    extension GraphQLFragmentPath where UnderlyingType == LOCAL.CategoryType {
        var id: Path<String> { .init() }

        var name: Path<String> { .init() }

        var productSet: FragmentPath<[LOCAL.ProductType]> { .init() }
    }

    extension GraphQLFragmentPath where UnderlyingType == LOCAL.CategoryType? {
        var id: Path<String?> { .init() }

        var name: Path<String?> { .init() }

        var productSet: FragmentPath<[LOCAL.ProductType]?> { .init() }
    }

    extension GraphQLFragmentPath where UnderlyingType == LOCAL.CreateProduct {
        var product: FragmentPath<LOCAL.ProductType?> { .init() }
    }

    extension GraphQLFragmentPath where UnderlyingType == LOCAL.CreateProduct? {
        var product: FragmentPath<LOCAL.ProductType?> { .init() }
    }

    extension GraphQLFragmentPath where UnderlyingType == LOCAL.UpdateProduct {
        var product: FragmentPath<LOCAL.ProductType?> { .init() }
    }

    extension GraphQLFragmentPath where UnderlyingType == LOCAL.UpdateProduct? {
        var product: FragmentPath<LOCAL.ProductType?> { .init() }
    }

    extension GraphQLFragmentPath where UnderlyingType == LOCAL.DeleteProduct {
        var product: FragmentPath<LOCAL.ProductType?> { .init() }
    }

    extension GraphQLFragmentPath where UnderlyingType == LOCAL.DeleteProduct? {
        var product: FragmentPath<LOCAL.ProductType?> { .init() }
    }

    extension GraphQLFragmentPath where UnderlyingType == LOCAL.CreateCategory {
        var category: FragmentPath<LOCAL.CategoryType?> { .init() }
    }

    extension GraphQLFragmentPath where UnderlyingType == LOCAL.CreateCategory? {
        var category: FragmentPath<LOCAL.CategoryType?> { .init() }
    }

    extension GraphQLFragmentPath where UnderlyingType == LOCAL.UpdateCategory {
        var category: FragmentPath<LOCAL.CategoryType?> { .init() }
    }

    extension GraphQLFragmentPath where UnderlyingType == LOCAL.UpdateCategory? {
        var category: FragmentPath<LOCAL.CategoryType?> { .init() }
    }

    extension GraphQLFragmentPath where UnderlyingType == LOCAL.DeleteCategory {
        var category: FragmentPath<LOCAL.CategoryType?> { .init() }
    }

    extension GraphQLFragmentPath where UnderlyingType == LOCAL.DeleteCategory? {
        var category: FragmentPath<LOCAL.CategoryType?> { .init() }
    }

#endif




// MARK: - ProductCell

#if GRAPHAELLO_PRODUCT_UI_TARGET

    extension ApolloLOCAL.ProductCellProductType: Fragment {
        typealias UnderlyingType = LOCAL.ProductType
    }

    extension ProductCell {
        typealias ProductType = ApolloLOCAL.ProductCellProductType

        init(productType: ProductType) {
            self.init(name: GraphQL(productType.name),
                      price: GraphQL(productType.price))
        }

        @ViewBuilder
        static func placeholderView() -> some View {
            if #available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *) {
                Self(productType: .placeholder).disabled(true).redacted(reason: .placeholder)
            } else {
                BasicLoadingView()
            }
        }
    }

    extension ProductCell: Fragment {
        typealias UnderlyingType = LOCAL.ProductType

        static let placeholder = Self(productType: .placeholder)
    }

    extension ApolloLOCAL.ProductCellProductType {
        func referencedSingleFragmentStruct() -> ProductCell {
            return ProductCell(productType: self)
        }
    }

    extension ApolloLOCAL.ProductCellProductType {
        private static let placeholderMap: ResultMap = ["__typename": "ProductType", "name": "__GRAPHAELLO_PLACEHOLDER__", "price": "__GRAPHAELLO_PLACEHOLDER__"]

        static let placeholder = ApolloLOCAL.ProductCellProductType(
            unsafeResultMap: ApolloLOCAL.ProductCellProductType.placeholderMap
        )
    }

#endif


// MARK: - ContentView

#if GRAPHAELLO_PRODUCT_UI_TARGET

    extension ContentView {
        typealias Data = ApolloLOCAL.ContentViewQuery.Data

        init(data: Data) {
            self.init(products: GraphQL(data.allProducts?.map { ($0?.fragments.productCellProductType)! }))
        }

        @ViewBuilder
        static func placeholderView() -> some View {
            if #available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *) {
                Self(data: .placeholder).disabled(true).redacted(reason: .placeholder)
            } else {
                BasicLoadingView()
            }
        }
    }

    extension LOCAL {
        func contentView<Loading: View, Error: View>(
            @ViewBuilder loading: () -> Loading,
            @ViewBuilder error: @escaping (QueryError) -> Error
        ) -> some View {
            return QueryRenderer(client: client,
                                 query: ApolloLOCAL.ContentViewQuery(),
                                 loading: loading(),
                                 error: error) { (data: ApolloLOCAL.ContentViewQuery.Data) -> ContentView in

                ContentView(data: data)
            }
        }

        func contentView<Loading: View>(
            @ViewBuilder loading: () -> Loading
        ) -> some View {
            return QueryRenderer(client: client,
                                 query: ApolloLOCAL.ContentViewQuery(),
                                 loading: loading(),
                                 error: { BasicErrorView(error: $0) }) { (data: ApolloLOCAL.ContentViewQuery.Data) -> ContentView in

                ContentView(data: data)
            }
        }

        func contentView<Error: View>(
            @ViewBuilder error: @escaping (QueryError) -> Error
        ) -> some View {
            return QueryRenderer(client: client,
                                 query: ApolloLOCAL.ContentViewQuery(),
                                 loading: ContentView.placeholderView(),
                                 error: error) { (data: ApolloLOCAL.ContentViewQuery.Data) -> ContentView in

                ContentView(data: data)
            }
        }

        func contentView() -> some View {
            return QueryRenderer(client: client,
                                 query: ApolloLOCAL.ContentViewQuery(),
                                 loading: ContentView.placeholderView(),
                                 error: { BasicErrorView(error: $0) }) { (data: ApolloLOCAL.ContentViewQuery.Data) -> ContentView in

                ContentView(data: data)
            }
        }
    }

    extension ApolloLOCAL.ContentViewQuery.Data {
        private static let placeholderMap: ResultMap = ["allProducts": Array(repeating: ["__typename": "ProductType", "name": "__GRAPHAELLO_PLACEHOLDER__", "price": "__GRAPHAELLO_PLACEHOLDER__"], count: 5) as [ResultMap]]

        static let placeholder = ApolloLOCAL.ContentViewQuery.Data(
            unsafeResultMap: ApolloLOCAL.ContentViewQuery.Data.placeholderMap
        )
    }

#endif


// MARK: - ProductRow

#if GRAPHAELLO_PRODUCT_UI_TARGET

    extension ProductRow {
        typealias Data = ApolloLOCAL.ProductRowQuery.Data

        init(api: LOCAL,
             data: Data) {
            self.init(api: api,
                      name: GraphQL(data.product?.name),
                      price: GraphQL(data.product?.price))
        }

        @ViewBuilder
        static func placeholderView(api: LOCAL) -> some View {
            if #available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *) {
                Self(api: api,
                     data: .placeholder).disabled(true).redacted(reason: .placeholder)
            } else {
                BasicLoadingView()
            }
        }
    }

    extension LOCAL {
        func productRow<Loading: View, Error: View>(id: String? = nil,
                                                    
                                                    @ViewBuilder loading: () -> Loading,
                                                    @ViewBuilder error: @escaping (QueryError) -> Error) -> some View {
            return QueryRenderer(client: client,
                                 query: ApolloLOCAL.ProductRowQuery(id: id),
                                 loading: loading(),
                                 error: error) { (data: ApolloLOCAL.ProductRowQuery.Data) -> ProductRow in

                ProductRow(api: self,
                           data: data)
            }
        }

        func productRow<Loading: View>(id: String? = nil,
                                       
                                       @ViewBuilder loading: () -> Loading) -> some View {
            return QueryRenderer(client: client,
                                 query: ApolloLOCAL.ProductRowQuery(id: id),
                                 loading: loading(),
                                 error: { BasicErrorView(error: $0) }) { (data: ApolloLOCAL.ProductRowQuery.Data) -> ProductRow in

                ProductRow(api: self,
                           data: data)
            }
        }

        func productRow<Error: View>(id: String? = nil,
                                     
                                     @ViewBuilder error: @escaping (QueryError) -> Error) -> some View {
            return QueryRenderer(client: client,
                                 query: ApolloLOCAL.ProductRowQuery(id: id),
                                 loading: ProductRow.placeholderView(api: self),
                                 error: error) { (data: ApolloLOCAL.ProductRowQuery.Data) -> ProductRow in

                ProductRow(api: self,
                           data: data)
            }
        }

        func productRow(id: String? = nil) -> some View {
            return QueryRenderer(client: client,
                                 query: ApolloLOCAL.ProductRowQuery(id: id),
                                 loading: ProductRow.placeholderView(api: self),
                                 error: { BasicErrorView(error: $0) }) { (data: ApolloLOCAL.ProductRowQuery.Data) -> ProductRow in

                ProductRow(api: self,
                           data: data)
            }
        }
    }

    extension ApolloLOCAL.ProductRowQuery.Data {
        private static let placeholderMap: ResultMap = ["product": ["__typename": "ProductType", "name": "__GRAPHAELLO_PLACEHOLDER__", "price": "__GRAPHAELLO_PLACEHOLDER__"]]

        static let placeholder = ApolloLOCAL.ProductRowQuery.Data(
            unsafeResultMap: ApolloLOCAL.ProductRowQuery.Data.placeholderMap
        )
    }

#endif






// @generated
//  This file was automatically generated and should not be edited.

import Apollo
import Foundation

/// ApolloLOCAL namespace
public enum ApolloLOCAL {
  public final class ContentViewQuery: GraphQLQuery {
    /// The raw GraphQL definition of this operation.
    public let operationDefinition: String =
      """
      query ContentView {
        allProducts {
          __typename
          ...ProductCellProductType
        }
      }
      """

    public let operationName: String = "ContentView"

    public var queryDocument: String {
      var document: String = operationDefinition
      document.append("\n" + ProductCellProductType.fragmentDefinition)
      return document
    }

    public init() {
    }

    public struct Data: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["Query"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("allProducts", type: .list(.object(AllProduct.selections))),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(allProducts: [AllProduct?]? = nil) {
        self.init(unsafeResultMap: ["__typename": "Query", "allProducts": allProducts.flatMap { (value: [AllProduct?]) -> [ResultMap?] in value.map { (value: AllProduct?) -> ResultMap? in value.flatMap { (value: AllProduct) -> ResultMap in value.resultMap } } }])
      }

      public var allProducts: [AllProduct?]? {
        get {
          return (resultMap["allProducts"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [AllProduct?] in value.map { (value: ResultMap?) -> AllProduct? in value.flatMap { (value: ResultMap) -> AllProduct in AllProduct(unsafeResultMap: value) } } }
        }
        set {
          resultMap.updateValue(newValue.flatMap { (value: [AllProduct?]) -> [ResultMap?] in value.map { (value: AllProduct?) -> ResultMap? in value.flatMap { (value: AllProduct) -> ResultMap in value.resultMap } } }, forKey: "allProducts")
        }
      }

      public struct AllProduct: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["ProductType"]

        public static var selections: [GraphQLSelection] {
          return [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLFragmentSpread(ProductCellProductType.self),
          ]
        }

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(name: String, price: String) {
          self.init(unsafeResultMap: ["__typename": "ProductType", "name": name, "price": price])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var fragments: Fragments {
          get {
            return Fragments(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }

        public struct Fragments {
          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public var productCellProductType: ProductCellProductType {
            get {
              return ProductCellProductType(unsafeResultMap: resultMap)
            }
            set {
              resultMap += newValue.resultMap
            }
          }
        }
      }
    }
  }

  public final class ProductRowQuery: GraphQLQuery {
    /// The raw GraphQL definition of this operation.
    public let operationDefinition: String =
      """
      query ProductRow($id: ID) {
        product(id: $id) {
          __typename
          name
          price
        }
      }
      """

    public let operationName: String = "ProductRow"

    public var id: GraphQLID?

    public init(id: GraphQLID? = nil) {
      self.id = id
    }

    public var variables: GraphQLMap? {
      return ["id": id]
    }

    public struct Data: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["Query"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("product", arguments: ["id": GraphQLVariable("id")], type: .object(Product.selections)),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(product: Product? = nil) {
        self.init(unsafeResultMap: ["__typename": "Query", "product": product.flatMap { (value: Product) -> ResultMap in value.resultMap }])
      }

      public var product: Product? {
        get {
          return (resultMap["product"] as? ResultMap).flatMap { Product(unsafeResultMap: $0) }
        }
        set {
          resultMap.updateValue(newValue?.resultMap, forKey: "product")
        }
      }

      public struct Product: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["ProductType"]

        public static var selections: [GraphQLSelection] {
          return [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("name", type: .nonNull(.scalar(String.self))),
            GraphQLField("price", type: .nonNull(.scalar(String.self))),
          ]
        }

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(name: String, price: String) {
          self.init(unsafeResultMap: ["__typename": "ProductType", "name": name, "price": price])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var name: String {
          get {
            return resultMap["name"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "name")
          }
        }

        public var price: String {
          get {
            return resultMap["price"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "price")
          }
        }
      }
    }
  }

  public struct ProductCellProductType: GraphQLFragment {
    /// The raw GraphQL definition of this fragment.
    public static let fragmentDefinition: String =
      """
      fragment ProductCellProductType on ProductType {
        __typename
        name
        price
      }
      """

    public static let possibleTypes: [String] = ["ProductType"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("name", type: .nonNull(.scalar(String.self))),
        GraphQLField("price", type: .nonNull(.scalar(String.self))),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(name: String, price: String) {
      self.init(unsafeResultMap: ["__typename": "ProductType", "name": name, "price": price])
    }

    public var __typename: String {
      get {
        return resultMap["__typename"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "__typename")
      }
    }

    public var name: String {
      get {
        return resultMap["name"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "name")
      }
    }

    public var price: String {
      get {
        return resultMap["price"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "price")
      }
    }
  }
}



