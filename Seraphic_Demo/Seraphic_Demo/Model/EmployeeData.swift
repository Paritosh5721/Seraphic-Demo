//
//  EmployeeData.swift
//  Seraphic_Demo
//
//  Created by Paritosh on 30/09/23.
//

import Foundation
struct EmployeeData: Codable {
    let status: String
    let data: [Employee]
    let message: String
}

struct Employee: Codable {
    let id: Int
    let employeeName: String
    let employeeSalary: Int
    let employeeAge: Int
    let profileImage: String
    
    // CodingKeys to map the JSON keys to Swift property names
    enum CodingKeys: String, CodingKey {
        case id
        case employeeName = "employee_name"
        case employeeSalary = "employee_salary"
        case employeeAge = "employee_age"
        case profileImage = "profile_image"
    }
}
