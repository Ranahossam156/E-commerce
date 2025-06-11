import shared

@MainActor
class ArticlesViewModelWrapper: ObservableObject {
    let articlesViewModel: ArticleViewModel
    @Published var articleState: ArticleState

    init() {
        articlesViewModel = ArticleViewModel()
        articleState = articlesViewModel.articleStateFlow.value
        startObserving()
    }

    func startObserving() {
        Task {
            for await state in articlesViewModel.articleStateFlow {
                self.articleState = state
            }
        }
    }
}

