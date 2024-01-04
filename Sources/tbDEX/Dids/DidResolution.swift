import Foundation

enum DidResolution {

    /// Representation of the result of a DID (Decentralized Identifier) resolution
    ///
    /// [Specification Reference](https://www.w3.org/TR/did-core/#resolution)
    struct Result: Codable, Equatable {

        /// The metadata associated with the DID resolution process.
        ///
        /// This includes information about the resolution process itself, such as any errors
        /// that occurred. If not provided in the constructor, it defaults to an empty
        /// `DidResolution.Metadata`.
        let didResolutionMetadata: DidResolution.Metadata

        /// The resolved DID document, if available.
        ///
        /// This is the document that represents the resolved state of the DID. It may be `null`
        /// if the DID could not be resolved or if the document is not available.
        let didDocument: DidDocument?

        /// The metadata associated with the DID document.
        ///
        /// This includes information about the document such as when it was created and
        /// any other relevant metadata. If not provided in the constructor, it defaults to an
        /// empty `DidDocument.Metadata`.
        let didDocumentMetadata: DidDocument.Metadata

        init(
            didResolutionMetadata: DidResolution.Metadata = DidResolution.Metadata(),
            didDocument: DidDocument? = nil,
            didDocumentMetadata: DidDocument.Metadata = DidDocument.Metadata()
        ) {
            self.didResolutionMetadata = didResolutionMetadata
            self.didDocument = didDocument
            self.didDocumentMetadata = didDocumentMetadata
        }

        static func invalidDid() -> Result {
            Result(
                didResolutionMetadata: Metadata(error: "invalidDid"),
                didDocument: nil,
                didDocumentMetadata: DidDocument.Metadata()
            )
        }
    }

    /// A metadata structure consisting of values relating to the results of the
    /// DID resolution process which typically changes between invocations of the
    /// resolve and resolveRepresentation functions, as it represents data about
    /// the resolution process itself
    ///
    /// [Specification Reference](https://www.w3.org/TR/did-core/#dfn-didresolutionmetadata)
    struct Metadata: Codable, Equatable {

        /// The Media Type of the returned didDocumentStream. This property is
        /// REQUIRED if resolution is successful and if the resolveRepresentation
        /// function was called.
        let contentType: String?

        /// The error code from the resolution process. This property is REQUIRED
        /// when there is an error in the resolution process. The value of this
        /// property MUST be a single keyword ASCII string. The possible property
        /// values of this field SHOULD be registered in the
        /// [DID Specification Registries](https://www.w3.org/TR/did-spec-registries/#error)
        let error: String?

        init(
            contentType: String? = nil,
            error: String? = nil
        ) {
            self.contentType = contentType
            self.error = error
        }
    }

}
