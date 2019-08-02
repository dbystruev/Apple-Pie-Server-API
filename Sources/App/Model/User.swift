//
//  User.swift
//  App
//
//  Created by Denis Bystruev on 02/08/2019.
//

import Fluent
import FluentPostgreSQL
import Vapor

struct User: Content, PostgreSQLModel, Migration {
    var id: Int?
    var username: String
    var password: String
}
