package com.example.kmpday1.android.view

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Info
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.kmpday1.article.ArticleViewModel

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ArticlesScreen(
    articlesViewModel: ArticleViewModel,
    onAboutClick: () -> Unit = {}
) {
    val articlesState = articlesViewModel.articleState.collectAsState()
    val state = articlesState.value

    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Text(text = "Articles", fontSize = 20.sp)
                },
                actions = {
                    IconButton(onClick = onAboutClick) {
                        Icon(
                            imageVector = Icons.Default.Info,
                            contentDescription = "About"
                        )
                    }
                }
            )
        }
    ) { padding ->
        Box(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding)
        ) {
            when {
                state.loading -> {
                    CircularProgressIndicator(
                        modifier = Modifier.align(Alignment.Center)
                    )
                }
                state.error != null -> {
                    Text(
                        text = "Error: ${state.error}",
                        color = Color.Red,
                        modifier = Modifier
                            .align(Alignment.Center)
                            .padding(16.dp)
                    )
                }
                state.articles.isNotEmpty() -> {
                    LazyColumn {
                        items(state.articles) { article ->
                            ArticleItemView(article = article)
                        }
                    }
                }
                else -> {
                    Text(
                        text = "No articles found.",
                        modifier = Modifier.align(Alignment.Center)
                    )
                }
            }
        }
    }
}



