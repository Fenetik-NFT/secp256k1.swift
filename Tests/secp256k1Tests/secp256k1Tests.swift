import XCTest
@testable import secp256k1

final class secp256k1Tests: XCTestCase {
    /// Uncompressed Key pair test
    func testUncompressedKeypairCreation() {
        // Initialize context
        let context = secp256k1_context_create(UInt32(SECP256K1_CONTEXT_SIGN | SECP256K1_CONTEXT_VERIFY))!

        // Destory context after execution
        defer { secp256k1_context_destroy(context) }

        // Setup private and public key variables
        var pubkeyLen = 65
        var cPubkey = secp256k1_pubkey()
        var publicKey = [UInt8](repeating: 0, count: pubkeyLen)

        let privateKey = try! "14E4A74438858920D8A35FB2D88677580B6A2EE9BE4E711AE34EC6B396D87B5C".byteArray()

        // Verify the context and keys are setup correctly
        XCTAssertEqual(secp256k1_context_randomize(context, privateKey), 1)
        XCTAssertEqual(secp256k1_ec_pubkey_create(context, &cPubkey, privateKey), 1)
        XCTAssertEqual(secp256k1_ec_pubkey_serialize(context, &publicKey, &pubkeyLen, &cPubkey, UInt32(SECP256K1_EC_UNCOMPRESSED)), 1)

        let hexString = """
        04734B3511150A60FC8CAC329CD5FF804555728740F2F2E98BC4242135EF5D5E4E6C4918116B0866F50C46614F3015D8667FBFB058471D662A642B8EA2C9C78E8A
        """

        // Define the expected public key
        let expectedPublicKey = try! hexString.byteArray()
        
        // Verify the generated public key matches the expected public key
        XCTAssertEqual(expectedPublicKey, publicKey)
        XCTAssertEqual(hexString.lowercased(), String(byteArray: publicKey))
    }

    /// Compressed Key pair test
    func testCompressedKeypairCreation() {
        // Initialize context
        let context = secp256k1_context_create(UInt32(SECP256K1_CONTEXT_SIGN | SECP256K1_CONTEXT_VERIFY))!

        // Destory context after execution
        defer { secp256k1_context_destroy(context) }

        // Setup private and public key variables
        var pubkeyLen = 33
        var cPubkey = secp256k1_pubkey()
        var publicKey = [UInt8](repeating: 0, count: pubkeyLen)
        let privateKey = try! "B035FCFC6ABF660856C5F3A6F9AC51FCA897BB4E76AD9ACA3EFD40DA6B9C864B".byteArray()

        // Verify the context and keys are setup correctly
        XCTAssertEqual(secp256k1_context_randomize(context, privateKey), 1)
        XCTAssertEqual(secp256k1_ec_pubkey_create(context, &cPubkey, privateKey), 1)
        XCTAssertEqual(secp256k1_ec_pubkey_serialize(context, &publicKey, &pubkeyLen, &cPubkey, UInt32(SECP256K1_EC_COMPRESSED)), 1)

        // Define the expected public key
        let expectedPublicKey = try! "02EA724B70B48B61FB87E4310871A48C65BF38BF3FDFEFE73C2B90F8F32F9C1794".byteArray()

        // Verify the generated public key matches the expected public key
        XCTAssertEqual(expectedPublicKey, publicKey)
    }
    
    /// Compressed Key pair test
    func testCompressedKeypairImplementationWithRaw() {
        let expectedPrivateKey = "7da12cc39bb4189ac72d34fc2225df5cf36aaacdcac7e5a43963299bc8d888ed"
        let expectedPublicKey = "023521df7b94248ffdf0d37f738a4792cc3932b6b1b89ef71cddde8251383b26e7"
        let privateKeyBytes = try! expectedPrivateKey.byteArray()
        let privateKey = try! secp256k1.Signing.PrivateKey(rawRepresentation: privateKeyBytes)

        // Verify the keys matches the expected keys output
        XCTAssertEqual(expectedPrivateKey, String(byteArray: privateKey.rawRepresentation))
        XCTAssertEqual(expectedPublicKey, String(byteArray: privateKey.publicKey.rawRepresentation))
    }

    /// SHA256 test
    func testSha256() {
        let expectedHashDigest = "f08a78cbbaee082b052ae0708f32fa1e50c5c421aa772ba5dbb406a2ea6be342"
        let data = "For this sample, this 63-byte string will be used as input data".data(using: .utf8)!

        let digest = SHA256.hash(data: data)

        // Verify the hash digest matches the expected output
        XCTAssertEqual(expectedHashDigest, String(byteArray: Array(digest)))
    }

    func testSigning() {
        let expectedDerSignature = "MEQCIGGvTtSQybMOSym7XmH9EofU3LLNaZo4jvFi1ZClPKA5AiBxjmZjAblJ11zKo76o/b4dhDvamwktCerS5SsTdyGqrg=="
        let expectedSignature = "OaA8pZDVYvGOOJppzbLc1IcS/WFeuylLDrPJkNROr2GuqiF3Eyvl0uoJLQmb2juEHb79qL6jylzXSbkBY2aOcQ=="
        let expectedPrivateKey = "5f6d5afecc677d66fb3d41eee7a8ad8195659ceff588edaf416a9a17daf38fdd"
        let privateKeyBytes = try! expectedPrivateKey.byteArray()
        let privateKey = try! secp256k1.Signing.PrivateKey(rawRepresentation: privateKeyBytes)
        let messageData = "Hello".data(using: .utf8)!

        let signature = try! privateKey.signature(for: messageData)

        // Verify the signature matches the expected output
        XCTAssertEqual(expectedSignature, signature.rawRepresentation.base64EncodedString())
        XCTAssertEqual(expectedDerSignature, try! signature.derRepresentation().base64EncodedString())
    }

    func testVerifying() {
//        let expectedDerSignature = "MEQCIGGvTtSQybMOSym7XmH9EofU3LLNaZo4jvFi1ZClPKA5AiBxjmZjAblJ11zKo76o/b4dhDvamwktCerS5SsTdyGqrg=="
//        let expectedSignature = "OaA8pZDVYvGOOJppzbLc1IcS/WFeuylLDrPJkNROr2GuqiF3Eyvl0uoJLQmb2juEHb79qL6jylzXSbkBY2aOcQ=="
        let expectedPrivateKey = "5f6d5afecc677d66fb3d41eee7a8ad8195659ceff588edaf416a9a17daf38fdd"
        let privateKeyBytes = try! expectedPrivateKey.byteArray()
        let privateKey = try! secp256k1.Signing.PrivateKey(rawRepresentation: privateKeyBytes)
        let messageData = "Hello".data(using: .utf8)!

        let signature = try! privateKey.signature(for: messageData)

        // Test the verification of the signature output
        XCTAssertTrue(privateKey.publicKey.isValidSignature(signature, for: SHA256.hash(data: messageData)))
//        XCTAssertEqual(expectedSignature, signature.rawRepresentation.base64EncodedString())
    }

    func testVerifyingDER() {
        let expectedDerSignature = Data(base64Encoded: "MEQCIGGvTtSQybMOSym7XmH9EofU3LLNaZo4jvFi1ZClPKA5AiBxjmZjAblJ11zKo76o/b4dhDvamwktCerS5SsTdyGqrg==", options: .ignoreUnknownCharacters)!
//        let expectedSignature = "OaA8pZDVYvGOOJppzbLc1IcS/WFeuylLDrPJkNROr2GuqiF3Eyvl0uoJLQmb2juEHb79qL6jylzXSbkBY2aOcQ=="
        let expectedPrivateKey = "5f6d5afecc677d66fb3d41eee7a8ad8195659ceff588edaf416a9a17daf38fdd"
        let privateKeyBytes = try! expectedPrivateKey.byteArray()
        let privateKey = try! secp256k1.Signing.PrivateKey(rawRepresentation: privateKeyBytes)
        let messageData = "Hello".data(using: .utf8)!

        let signature = try! secp256k1.Signing.ECDSASignature(derRepresentation: expectedDerSignature)

        // Test the verification of the signature output
        XCTAssertTrue(privateKey.publicKey.isValidSignature(signature, for: SHA256.hash(data: messageData)))
//        XCTAssertEqual(expectedSignature, signature.rawRepresentation.base64EncodedString())
    }

    static var allTests = [
        ("testUncompressedKeypairCreation", testUncompressedKeypairCreation),
        ("testCompressedKeypairCreation", testCompressedKeypairCreation),
        ("testCompressedKeypairImplementationWithRaw", testCompressedKeypairImplementationWithRaw),
        ("testSha256", testSha256),
        ("testSigning", testSigning),
        ("testVerifying", testVerifying),
        ("testVerifyingDER", testVerifyingDER),
    ]
}
    

