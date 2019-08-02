//
//  CategoryWord.swift
//  App
//
//  Created by Denis Bystruev on 02/08/2019.
//

import Fluent
import FluentPostgreSQL
import Vapor

struct CategoryWord: Content, PostgreSQLModel, Migration {
    var id: Int?
    var category: Int
    var title: String
    var user: String
    var date: Date
}
