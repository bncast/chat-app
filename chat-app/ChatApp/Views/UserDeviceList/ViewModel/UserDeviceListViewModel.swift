//
//  UserDeviceListViewModel.swift
//  ChatApp
//
//  Created by Niño Castorico on 9/11/24.
//

import Foundation

class UserDeviceListViewModel {
    enum Section: Hashable  {
        case list
    }

    struct ItemInfo: Hashable {
        let id: Int
        let name: String
    }

    @Published var items: [Section: [ItemInfo]] = [:]

    func load() {
        items = [.list: [
            ItemInfo(id: 1, name: "Nino iPhone"),
            ItemInfo(id: 2, name: "Nezuko iPhone")
        ] ]

        // TODO:
    }

}
