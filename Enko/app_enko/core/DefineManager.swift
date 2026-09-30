import Foundation
import SwiftUI

struct WebItem {
  let title: String
  let url: String
}

class DefineManager {
  private static func GetEnkoJson(completion: @escaping (Result<JSON, Error>) -> Void) {
    Task {
      do {
        let data = try await CacheNet.s.Request(url: EnkoInfo.enkoJson, cacheHours: EnkoInfo.enkoJsonHour)
        DispatchQueue.main.async {
          do {
            completion(.success(try JSON(data: data)))
          } catch {
            completion(.failure(error))
          }
        }
      } catch {
        DispatchQueue.main.async {
          completion(.failure(error))
        }
      }
    }
  }

  static func GetDonateUrl(completion: @escaping (Result<String, Error>) -> Void) {
    GetEnkoJson { result in
      switch result {
      case .success(let json):
        if let donateUrl = json["Donate"]["Url"].string ?? json["Donate"].string {
          completion(.success(donateUrl))
          return
        }
        let error = NSError(domain: "Enko", code: -1, userInfo: [NSLocalizedDescriptionKey: "Donate URL not found in enko.json"])
        completion(.failure(error))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }
}
