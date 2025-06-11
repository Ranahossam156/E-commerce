package com.example.kmpday1

interface Platform {
    val name: String
}

expect fun getPlatform(): Platform