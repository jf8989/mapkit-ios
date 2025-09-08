// App/Shared/TaskBag.swift

import Combine
import Foundation

/// A tiny utility to keep async Tasks and Combine cancellables under control.
/// - For Combine pipelines: store AnyCancellable in `cancellables`.
/// - For structured-concurrency Tasks (if used in non-async/await contexts): insert and they auto-cancel on deinit.
public final class TaskBag {
    // MARK: - Combine

    public var cancellables = Set<AnyCancellable>()

    // MARK: - Tasks

    private var tasks = [Task<Void, Never>]()

    public init() {}

    @discardableResult
    public func insert(_ task: Task<Void, Never>) -> Task<Void, Never> {
        tasks.append(task)
        return task
    }

    deinit {
        tasks.forEach { $0.cancel() }
        tasks.removeAll()
        cancellables.removeAll()
    }
}
