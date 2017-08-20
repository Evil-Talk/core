/// Copies output from an output stream into an array
/// of stream split deltas.
public final class OutputStreamSplitter<O: OutputStream> {
    let outputStream: O

    /// Split handlers can throw, we will report
    /// to the error stream
    public typealias Splits = (O.Output) throws -> ()

    /// The stored stream deltas
    public var splits: [Splits]

    /// Create a new stream splitter from an output stream
    public init(_ outputStream: O) {
        self.outputStream = outputStream
        splits = []
        self.outputStream.outputStream = { output in
            for delta in self.splits {
                do {
                    try delta(output)
                } catch {
                    outputStream.errorStream?(error)
                }
            }
        }
    }

    /// Split the output stream to this new handler.
    public func split(closure: @escaping Splits) {
        self.splits.append(closure)
    }
}
