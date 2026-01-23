import Foundation

struct MockMoviesLoader: MoviesLoading {
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void) {
        print("📦 Загружаем данные из MoviesMock.json")

        guard let url = Bundle.main.url(forResource: "MoviesMock", withExtension: "json") else {
            handler(.failure(NSError(domain: "MockMoviesLoader", code: 1, userInfo: [NSLocalizedDescriptionKey: "Файл не найден"])))
            return
        }

        do {
            let data = try Data(contentsOf: url)
            print("✅ JSON успешно прочитан из файла")

            let movies = try JSONDecoder().decode(MostPopularMovies.self, from: data)
            print("🎉 Успешно декодировано \(movies.items.count) фильмов")
            handler(.success(movies))
        } catch {
            print("❌ Ошибка при декодировании: \(error)")
            handler(.failure(error))
        }
    }
}
