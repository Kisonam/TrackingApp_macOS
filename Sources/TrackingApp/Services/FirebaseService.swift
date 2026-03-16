import Foundation

final class FirebaseService {
    static let shared = FirebaseService()
    private init() {}

    private var isSyncing = false

    // MARK: - Sync to Firestore

    func syncUsageData(
        projectId: String,
        apiKey: String,
        collection: String,
        completion: @escaping (Result<Int, Error>) -> Void
    ) {
        guard !projectId.isEmpty else {
            completion(.failure(FirebaseError.missingProjectId))
            return
        }
        guard !isSyncing else {
            completion(.failure(FirebaseError.alreadySyncing))
            return
        }

        isSyncing = true
        let records = DatabaseManager.shared.allTimeUsage()
        guard !records.isEmpty else {
            isSyncing = false
            completion(.success(0))
            return
        }

        let group = DispatchGroup()
        var successCount = 0
        var lastError: Error?

        for record in records {
            group.enter()

            let docId = record.bundleIdentifier
                .replacingOccurrences(of: ".", with: "_")
                .replacingOccurrences(of: "/", with: "_")

            let urlString: String
            if apiKey.isEmpty {
                urlString = "https://firestore.googleapis.com/v1/projects/\(projectId)/databases/(default)/documents/\(collection)/\(docId)"
            } else {
                urlString = "https://firestore.googleapis.com/v1/projects/\(projectId)/databases/(default)/documents/\(collection)/\(docId)?key=\(apiKey)"
            }

            guard let url = URL(string: urlString) else {
                lastError = FirebaseError.invalidURL
                group.leave()
                continue
            }

            let body: [String: Any] = [
                "fields": [
                    "appName": ["stringValue": record.appName],
                    "bundleIdentifier": ["stringValue": record.bundleIdentifier],
                    "totalSeconds": ["integerValue": String(record.totalSeconds)],
                    "lastSync": ["stringValue": ISO8601DateFormatter().string(from: Date())]
                ]
            ]

            guard let jsonData = try? JSONSerialization.data(withJSONObject: body) else {
                lastError = FirebaseError.encodingFailed
                group.leave()
                continue
            }

            var request = URLRequest(url: url)
            request.httpMethod = "PATCH"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = jsonData

            URLSession.shared.dataTask(with: request) { data, response, error in
                defer { group.leave() }
                if let error = error {
                    lastError = error
                    return
                }
                if let http = response as? HTTPURLResponse, http.statusCode >= 200, http.statusCode < 300 {
                    successCount += 1
                } else if let data = data,
                          let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                          let error = json["error"] as? [String: Any],
                          let message = error["message"] as? String {
                    lastError = FirebaseError.serverError(message)
                } else {
                    let code = (response as? HTTPURLResponse)?.statusCode ?? -1
                    lastError = FirebaseError.serverError("HTTP \(code)")
                }
            }.resume()
        }

        group.notify(queue: .main) { [weak self] in
            self?.isSyncing = false
            if successCount > 0 {
                completion(.success(successCount))
            } else if let error = lastError {
                completion(.failure(error))
            } else {
                completion(.success(0))
            }
        }
    }
}

// MARK: - Errors

enum FirebaseError: LocalizedError {
    case missingProjectId
    case alreadySyncing
    case invalidURL
    case encodingFailed
    case serverError(String)

    var errorDescription: String? {
        switch self {
        case .missingProjectId: return "Firebase Project ID is missing"
        case .alreadySyncing: return "Sync already in progress"
        case .invalidURL: return "Invalid Firestore URL"
        case .encodingFailed: return "Failed to encode data"
        case .serverError(let msg): return "Server: \(msg)"
        }
    }
}
