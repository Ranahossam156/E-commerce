package com.example.kmpday1.article

data class ArticleState (
    val articles: List<Article> = listOf(),
    val loading : Boolean = false,
    val error: String? = null
)




