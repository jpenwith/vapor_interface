//
//  AuthenticatableRequest.swift
//  
//
//  Created by me on 20/07/2022.
//

import Foundation


public protocol AuthenticatableRequest {
    var authenticationMethod: AuthenticationMethod { get }
}
