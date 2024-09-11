//
//  NotificationManager.swift
//  ChatApp
//
//  Created by Ramon Jr Bahio on 9/5/24.
//

import UIKit
import UserNotifications

final class NotificationManager: NSObject {

    enum NotificationCategory: String {
        case roomInvitation = "ROOM_INVITATION"
        case newMessage = "NEW_MESSAGE"
    }

    enum NotificationAction: String {
        case acceptInvitation = "ACCEPT_ACTION"
    }

    static var shared = NotificationManager()

    typealias AuthStatus = UNAuthorizationStatus

    var showInvitationsList: (() async -> Void)?
    var showRoomFromNotif: ((Int) async -> Void)?

    private var needsToAskNotifAuth: (AuthStatus) -> Bool = { authStatus in
        [AuthStatus.notDetermined, AuthStatus.denied].contains(authStatus)
    }

    func requestAuthorization() async {
        let center = UNUserNotificationCenter.current()

        // Obtain the notification settings.
        let settings = await center.notificationSettings()

        do {
            guard needsToAskNotifAuth(settings.authorizationStatus) else { return }
            try await center.requestAuthorization(options: [.alert, .sound, .badge])
            configureNotification()
        } catch {
            print("Error in notification authorization: \(error)")
        }

        // Enable or disable features based on the authorization.
    }

    func requestDeviceToken() {
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        center.getNotificationSettings { settings in
            guard settings.authorizationStatus == .authorized else { return }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        print(userInfo)
        let category = NotificationCategory(rawValue: response.notification.request.content.categoryIdentifier)
        guard let roomId = userInfo["roomId"] as? Int else { return }
        
        switch category {
        case .roomInvitation:
            if let showInvitationsList { Task { await showInvitationsList() } }

            guard NotificationAction(rawValue: response.actionIdentifier) == .acceptInvitation,
                  let invitationId = userInfo["invitationId"] as? Int
            else { return }

            Task{ await join(roomId: roomId, invitationId: invitationId) }
        case .newMessage:
            guard let showRoomFromNotif else { return }

            Task { await showRoomFromNotif(roomId) }
        default: print("Invalid notification Category!")
        }
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        let options: UNNotificationPresentationOptions = if #available(iOS 14.0, *) {
            [[.banner, .sound, .badge]]
        } else {
            [[.alert, .sound, .badge]]
        }
        completionHandler(options)
    }

    private func join(roomId: Int, invitationId: Int) async {
        guard let deviceId = AppConstant.shared.deviceId else { return }
        do {
            guard let _ = try await AcceptInvitationEntity(invitationId: invitationId ,
                                                                roomId: roomId).run().chatRoom
            else { return }
        } catch {
            print("[InvitationListViewModel] Error! \(error as! NetworkError)")
        }
    }

    private func configureNotification() {
        let acceptAction = UNNotificationAction(identifier: "ACCEPT_ACTION", title: "ACCEPT")
        let roomInviteCategory =
        UNNotificationCategory(identifier: "ROOM_INVITATION",
                               actions: [acceptAction],
                               intentIdentifiers: [],
                               hiddenPreviewsBodyPlaceholder: "",
                               options: [])
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.setNotificationCategories([roomInviteCategory])
    }
}

// MARK: - UNUserNotificationCenterDelegate
extension NotificationManager: UNUserNotificationCenterDelegate {
    
}

// MARK: - Push Notification

extension AppDelegate {
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        AppConstant.shared.deviceToken = deviceTokenString(from: deviceToken)
    }

    private func deviceTokenString(from deviceToken: Data) -> String {
        let tokenParts = deviceToken.map { data -> String in
            return String(format: "%02.2hhx", data)
        }

        return tokenParts.joined()
    }

    func application(_: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Not available in simulator :( \(error)")
    }
}
