//
//  BCConstants.swift
//  BCount
//
//  Created by Vikas Varma on 1/13/16.
//  Copyright © 2016 Vikas Varma. All rights reserved.
//

import Foundation
extension BCClient {
    
    struct Constants {
        static let baseSecuredBCountURL: String = "https://jbossews-soulbuzz.rhcloud.com"
        static let api_key: String = "5e572e694e4d61763b567059273a4d3d"
        static let secret_key: String = "316457735c4055642744596b302e2151"
        static let max_count_per_page = 21
        static let BCountSignUpURL: String = "https://jbossews-soulbuzz.rhcloud.com/signup.html"
    }
    
    // MARK: - Methods
    struct Methods {
        static let login_method = "/oauth/token"
        static let getUserInfo = "/v1.0/me/"
        static let bCount = "/v1.0/bcount/"
        static let getBCounts = "/v1.0/bcount/counts"
    }
    struct Parameters {
        static let username = "username"
        static let grantType = "grant_type"
        static let password = "password"
    }
}