//
//  ServerListViewModel.swift
//  ChatApp
//
//  Created by Ramon Jr Bahio on 9/9/24.
//

import UIKit

final class ServerListViewModel {
    struct ItemInfo: Hashable, Codable {
        var id: Int
        var name: String
        var ipAddress: String
        var port: String
        var status: ConnectionStatus

        static func == (lhs: ItemInfo, rhs: ItemInfo) -> Bool {
            lhs.hashValue == rhs.hashValue
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
            hasher.combine(name)
            hasher.combine(ipAddress)
            hasher.combine(port)
            hasher.combine(status)
        }
    }

    enum ConnectionStatus: String, Hashable, Codable {
        case connected = "Connected"
        case available = "Available"
        case unavailable = "Unavailable"

        func getPrio() -> Int {
            switch self {
            case .connected: 0
            case .available: 1
            case .unavailable: 2
            }
        }
    }

    typealias ServerInfo = ServerListViewController.ServerInfo
    @Published var items: [ItemInfo] = [ItemInfo]()

    func load() async throws {
        addCurrentServer()
        guard let serverList = AppConstant.shared.serverList,
              let savedServerList = Self.serverInfosForData(serverList)
        else { return }

        var itemsToLoad = [ItemInfo]()
        for info in savedServerList {
            await checkAvailability(of: info) { [weak self] availabilityNew, infoPassed in
                guard let name = infoPassed.name,
                      let address = infoPassed.address,
                      let port = infoPassed.port else { return }
                let availability = address == AppConstant.shared.hostAddress && availabilityNew == .available ?
                    .connected: availabilityNew
                itemsToLoad.append(
                    ItemInfo(id: itemsToLoad.max(by: { $0.id < $1.id })?.id ?? 0,
                             name: name,
                             ipAddress: address,
                             port: port,
                             status: availability)
                )
                self?.sort(list: itemsToLoad)
            }
        }
    }

    private func sort(list: [ItemInfo]) {
        items = list.sorted { (($0.status.getPrio(), $0.name) < ($1.status.getPrio(), $1.name)) }
    }

    private func addCurrentServer() {
        addServerInApp(info: ServerInfo(address: AppConstant.shared.hostAddress,
                                        port: AppConstant.shared.port))
    }

    func addServer(info: ServerInfo) async {
        await checkAvailability(of: info, completion: { [weak self] availability, infoPassed in
            guard let self,
                  let name = infoPassed.name,
                  let address = infoPassed.address,
                  let port = infoPassed.port else { return }
            var itemsToLoad = items
            itemsToLoad.append(
                ItemInfo(
                    id: itemsToLoad.max(by: { $0.id < $1.id })?.id ?? 0,
                    name: name,
                    ipAddress: address,
                    port: port,
                    status: availability
                )
            )
            sort(list: itemsToLoad)

            addServerInApp(info: info)
        })
    }

    func checkInfoHasDuplicate(_ info: ServerInfo) -> Bool {
        var serverInfos = Self.serverInfosForData(AppConstant.shared.serverList ?? Data()) ?? [ServerInfo]()
        guard let _ = (serverInfos.first { $0.isEqual(to: info) }) else { return false }
        return true
    }

    func checkInfoIncomplete(info: ServerInfo) -> Bool {
        if let name = info.name, name.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty {
            return true
        }
        if let address = info.address, address.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty {
            return true
        }
        if let port = info.port, port.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty {
            return true
        }
        return false
    }

    private func addServerInApp(info: ServerInfo){
        var serverInfos = Self.serverInfosForData(AppConstant.shared.serverList ?? Data()) ?? [ServerInfo]()

        guard (serverInfos.first { $0.isEqual(to: info) }) == nil else { return }

        serverInfos.append(info)
        AppConstant.shared.serverList = Self.dataForServerInfos(serverInfos)
    }

    func updateServer(info: ItemInfo, infoToReplace: ItemInfo) async {
        await checkAvailability(of: ServerInfo(
            name: info.name, address: info.ipAddress, port: info.port
        )) { [weak self] availability, infoPassed in
            guard let self else { return }

            var itemsToLoad = items
            var infoToUpdate = info
            guard let index = itemsToLoad.firstIndex(of: infoToReplace) else { return }

            infoToUpdate.status = availability

            itemsToLoad.remove(at: index)
            itemsToLoad.insert(infoToUpdate, at: index)

            sort(list: itemsToLoad)

            updateServerInApp(info:
                                ServerInfo(
                                    name: info.name,
                                    address: info.ipAddress,
                                    port: info.port
                                ),
                              infoToReplace:
                                ServerInfo(
                                    name: infoToReplace.name,
                                    address: infoToReplace.ipAddress,
                                    port: infoToReplace.port
                                ))
        }

    }

    private func hostString(_ address: String, _ port: String) -> String {
        return "\(address):\(port)"
    }

    private func updateServerInApp(info: ServerInfo, infoToReplace: ServerInfo) {
        var serverInfos = Self.serverInfosForData(AppConstant.shared.serverList ?? Data()) ?? [ServerInfo]()

        guard let index = serverInfos.firstIndex(where: { serverInfo in
            serverInfo.isEqual(to: info)
        }) else { return }

        serverInfos.remove(at: index)
        serverInfos.insert(info, at: index)

        AppConstant.shared.serverList = Self.dataForServerInfos(serverInfos)
    }

    func deleteServer(index: IndexPath) {
        var serverInfos = Self.serverInfosForData(AppConstant.shared.serverList ?? Data()) ?? [ServerInfo]()
        serverInfos.removeAll { $0.address == items[index.row].ipAddress }
        AppConstant.shared.serverList = Self.dataForServerInfos(serverInfos)

        items.remove(at: index.row)
    }

    static func dataForServerInfos(_ serverInfo: [ServerInfo]) -> Data? {
        do {
            return try JSONEncoder().encode(serverInfo)
        } catch {
            print("Error in encoding: \(error)")
            return nil
        }
    }

    static func serverInfosForData(_ data: Data) -> [ServerInfo]? {
        do {
            return try JSONDecoder().decode([ServerInfo].self, from: data)
        } catch {
            print("Error in decoding: \(error)")
            return nil
        }
    }

    private func checkAvailability(of info: ServerInfo, completion: @escaping (ConnectionStatus, ServerInfo) async -> Void ) async {
        let checkTask = Task {
            do {
                guard let address = info.address, let port = info.port,
                      try await AppVersionEntity(hostValue: hostString(address, port)).run().success == 1
                else { return await completion(ConnectionStatus.unavailable, info) }

                await completion(ConnectionStatus.available, info)
            } catch {
                await completion(ConnectionStatus.unavailable, info)
            }
        }

        let timeoutTask = Task {
            do {
                try await Task.sleep(nanoseconds: 1_000_000_000)
                checkTask.cancel()
            } catch {
                await completion(ConnectionStatus.unavailable, info)
            }
        }
    }

    func connectToServer(_ info: ItemInfo) async {
        await checkAvailability(of: ServerInfo(
            name: info.name, address: info.ipAddress, port: info.port
        )) { [weak self] availability, infoPassed in
            if availability == .available {
                guard let address = infoPassed.address, let port = infoPassed.port else { return }
                AppConstant.shared.hostAddress = address
                AppConstant.shared.port = port
                try? await self?.load()
            }
        }
    }
}
