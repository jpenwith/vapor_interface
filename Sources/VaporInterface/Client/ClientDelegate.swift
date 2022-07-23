//
//  ClientDelegate.swift
//  
//
//  Created by me on 23/07/2022.
//

import Foundation
import Vapor


public protocol ClientDelegate {
    func client<NetworkAdapter: ClientNetworkAdapter>(
        _ client: Client<NetworkAdapter>,
        modifyNetworkRequest networkRequest: NetworkAdapter.Request
    ) -> NetworkAdapter.Request
    func client<NetworkAdapter: ClientNetworkAdapter>(
        _ client: Client<NetworkAdapter>,
        modifyNetworkResponse networkResponse: NetworkAdapter.Response
    ) -> NetworkAdapter.Response
}

extension ClientDelegate {
    func client<NetworkAdapter: ClientNetworkAdapter>(
        _ client: Client<NetworkAdapter>,
        modifyNetworkRequest networkRequest: NetworkAdapter.Request
    ) -> NetworkAdapter.Request {
        return networkRequest
    }

    func client<NetworkAdapter: ClientNetworkAdapter>(
        _ client: Client<NetworkAdapter>,
        modifyNetworkResponse networkResponse: NetworkAdapter.Response
    ) -> NetworkAdapter.Response {
        return networkResponse
    }
}
