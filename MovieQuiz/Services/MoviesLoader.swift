import Foundation

protocol MoviesLoading {
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void)
}

struct MoviesLoader: MoviesLoading {
    // MARK: - NetworkClient
    private let networkClient: NetworkRouting
    
    init(networkClient: NetworkRouting) {
        self.networkClient = networkClient
    }
    
    // MARK: - URL
    private var mostPopularMoviesUrl: URL {
            guard let url = URL(string: "https://tv-api.com/en/API/Top250Movies/k_zcuw1ytf") else {
                preconditionFailure("Unable to construct mostPopularMoviesUrl")
            }
            return url
        }
    
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void) {
        print("Начинаем загрузку")
        networkClient.fetch(url: mostPopularMoviesUrl) {
            result in
            switch result {
            case .success(let data):
                print("✅ Данные успешно получены. Размер: \(data.count) байт")

                if let jsonString = String(data: data, encoding: .utf8) {
                    print("📦 JSON получен: \(jsonString)")
                }

                do {
                    let mostPopularMovies = try JSONDecoder().decode(MostPopularMovies.self, from: data)
                    print("🎉 Успешно декодировано \(mostPopularMovies.items.count) фильмов")
                    handler(.success(mostPopularMovies))
                } catch {
                    print("❌ Ошибка декодирования: \(error)")
                    handler(.failure(error))
                }
            case .failure(let error):
                print("❌ Ошибка при загрузке: \(error)")

                handler(.failure(error))
            }
        }
    }
}
