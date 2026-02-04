//
//  PexelsAPIService.swift
//  ShortVideoFeed
//
//  Created by Tes on 02/02/2026.
//

import Foundation

// MARK: - API Service Error
enum APIError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case networkError(Error)
    case decodingError(Error)
    case serverError(Int)
    case unauthorized
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .serverError(let code):
            return "Server error: \(code)"
        case .unauthorized:
            return "Unauthorized - Check your API key"
        }
    }
}

// MARK: - Pexels API Service
@MainActor
class PexelsAPIService: ObservableObject {
    static let shared = PexelsAPIService()
    
    // MARK: IMPORTANT - Replace with your Pexels API key
    // Get your free API key at: https://www.pexels.com/api/
//    private let apiKey = "YOUR_PEXELS_API_KEY"
    private let baseURL = "https://api.pexels.com/videos"
    
    private let urlSession: URLSession
    
    init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }
    
    // MARK: - Fetch Videos
    func fetchVideos(query: String = "people", perPage: Int = 80, page: Int = 1) async throws -> PexelsResponse {
        // Construct URL
        var components = URLComponents(string: "\(baseURL)/search")
        components?.queryItems = [
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "per_page", value: "\(perPage)"),
            URLQueryItem(name: "page", value: "\(page)")
        ]
        
        guard let url = components?.url else {
            throw APIError.invalidURL
        }
        
        // Create request
        var request = URLRequest(url: url)
        request.setValue(AppConstants.apiKey, forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 30
        
        // Make request
        do {
            let (data, response) = try await urlSession.data(for: request)
            
            // Check response
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            
            // Handle status codes
            switch httpResponse.statusCode {
            case 200...299:
                break
            case 401:
                throw APIError.unauthorized
            default:
                throw APIError.serverError(httpResponse.statusCode)
            }
            
            // Decode response
            let decoder = JSONDecoder()
            do {
                let pexelsResponse = try decoder.decode(PexelsResponse.self, from: data)
                return pexelsResponse
            } catch {
                throw APIError.decodingError(error)
            }
            
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }
    
    // MARK: - Fetch Multiple Pages
    func fetchMultiplePages(query: String = "people", totalVideos: Int = 200) async throws -> [Video] {
        let perPage = 80
        let totalPages = Int(ceil(Double(totalVideos) / Double(perPage)))
        
        var allVideos: [Video] = []
        
        for page in 1...min(totalPages, 3) { // Max 3 pages = 240 videos
            let response = try await fetchVideos(query: query, perPage: perPage, page: page)
            guard let videos = response.videos else {
                print("Error fetching videos.")
                continue
            }
            allVideos.append(contentsOf: videos)
            
            if allVideos.count >= totalVideos {
                break
            }
        }
        
        return Array(allVideos.prefix(totalVideos))
    }
}
