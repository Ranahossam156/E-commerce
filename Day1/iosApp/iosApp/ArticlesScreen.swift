import SwiftUI
import shared

struct ArticlesScreen: View {
    @StateObject var viewModel = ArticlesViewModelWrapper()

    var body: some View {
        NavigationView {
            Group {
                if viewModel.articleState.loading {
                    ProgressView("Loading...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                } else if let error = viewModel.articleState.error {
                    Text("Error: \(error)")
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                } else if viewModel.articleState.articles.isEmpty {
                    Text("No articles found.")
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                } else {
                    List(viewModel.articleState.articles, id: \.title) { article in
                        ArticleItemView(article: article)
                    }
                }
            }
            .navigationTitle("Articles")
            .navigationBarItems(trailing: Button(action: {
            }, label: {
                Image(systemName: "info.circle")
            }))
        }
    }
}
