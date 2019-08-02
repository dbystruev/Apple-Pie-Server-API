//
//  Category.swift
//  App
//
//  Created by Denis Bystruev on 02/08/2019.
//

import Fluent
import FluentPostgreSQL
import Vapor

struct Category: Content, PostgreSQLModel, Migration {
    var id: Int?
    var name: String
}
