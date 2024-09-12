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
        let deviceId: String
        let name: String
    }

    @Published var items: [Section: [ItemInfo]] = [:]

    func load() {
        Task {
            do {
                let devices = try await GetUserDeviceListEntity().run().devices

                items[.list] = devices.map {
                    ItemInfo(id: $0.id, deviceId: $0.deviceId, name: $0.deviceName)
                }
            } catch {
                print("[UserDeviceListViewModel]", error.localizedDescription)
            }
        }
    }

    func remove(userDeviceId: Int) async {
        do {
            try await RemoveUserDeviceEntity(userDeviceId: userDeviceId).run()
        } catch {
            print("[UserDeviceListViewModel]", error.localizedDescription)
        }
    }
}
