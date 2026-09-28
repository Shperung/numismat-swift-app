
import Observation

@Observable
class CountriesStore {
    var countries: [[String: Any]] = []
    var loading = true
    var error: String?

    func load() async {
        do {
            countries = try await fetchCollection("countries")
        } catch {
            self.error = String(describing: error)
        }
        loading = false
    }
}
