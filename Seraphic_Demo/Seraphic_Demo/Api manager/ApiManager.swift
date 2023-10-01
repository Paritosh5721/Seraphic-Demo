//
//  ApiManager.swift
//  Seraphic_Demo
//
//  Created by Paritosh on 30/09/23.
//

import Foundation
import Alamofire

class APIManager {
    static let shared = APIManager()
    func getEmployeeDataByURL(completion: @escaping (Result<EmployeeData, Error>) -> Void) {
        
        
        AF.request(getEmployeeData).responseDecodable(of: EmployeeData.self) { response in
            switch response.result {
            case .success(let employeeResponse):
                completion(.success(employeeResponse))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
