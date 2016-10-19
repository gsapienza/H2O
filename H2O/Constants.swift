//
//  Constants.swift
//  H2O
//
//  Created by Gregory Sapienza on 5/18/16.
//  Copyright © 2016 The Oven. All rights reserved.
//

import Foundation
import SpriteKit
import WatchKit
import UIKit

enum ShortcutItemValue :String {
    case smallEntry = "com.theoven.H2O.smallPresetEntry"
    case mediumEntry = "com.theoven.H2O.mediumPresetEntry"
    case largeEntry = "com.theoven.H2O.largePresetEntry"
    case customEntry = "com.theoven.H2O.customEntry"
}

//MARK: - Units

enum Unit :String {
    case oz
    case ml
}

/// Standard unit of measurement
let standardUnit :Unit = .oz

//MARK: - Notification Constants

let DarkModeToggledNotification = Notification.Name("DARK_MODE_TOGGLED")
let WatchAppSwitchedToBackgroundNotification = Notification.Name("WATCH_APP_SWITCHED_TO_BACKGROUND")
let WatchAppSwitchedToForegroundNotification = Notification.Name("WATCH_APP_SWITCHED_TO_FOREGROUND")
let PresetsUpdatedNotification = Notification.Name("PRESETS_UPDATED")
let GoalUpdatedNotification = Notification.Name("GOAL_UPDATED")
let SyncCompletedNotification = Notification.Name("SYNC_COMPLETE")

//MARK: - Notification Dict Constants

let PresetValuesNotificationInfo = "PRESET_VALUES"
let GoalValueNotificationInfo = "GOAL_VALUE"

//MARK: - User Defaults Constants

let AppOpenedForFirstTimeDefault = "APP_OPENED_FOR_FIRST_TIME"
let InformationViewControllerOpenedBefore = "INFORMATION_VIEW_CONTROLLER_OPENED_BEFORE"
let PresetWaterValuesDefault = "PRESET_WATER_VALUES"
let DailyGoalValueDefault = "GOAL_VALUE"
let AutomaticThemeChangeDefault = "AUTOMATIC_THEME_CHANGE"
let DarkModeDefault = "DARK_MODE"
let HealthKitPermissionsDisplayedDefault = "HEALTHKIT_PERMISSIONS_WERE_DISPLAYED"

//MARK: - Watch Message Keys

let PresetsUpdatedWatchMessage = "PRESETS_UPDATED"
let GoalUpdatedWatchMessage = "GOAL_UPDATED"
let GetDefaultsWatchMessage = "GET_DEFAULTS"
let RequestSyncWatchMessage = "REQUEST_SYNC"
let StartSyncWatchMessage = "START_SYNC"

//MARK: - Watch Message Reply Handler Dict Constants

let PresetValuesFromWatchMessage = "WATCH_PRESET_VALUES"
let GoalValueFromWatchMessage = "WATCH_GOAL_VALUE"
let EntriesToInsertFromWatchMessage = "WATCH_ENTRIES_TO_INSERT"
let EntriesToModifyFromWatchMessage = "WATCH_ENTRIES_TO_MODIFY"
let SyncDataWatchMessage = "WATCH_SYNC_DATA"

//MARK: - Watch Sync Engine Data Keys

let WatchDataSyncBeganDate = "WATCH_DATA_SYNC_BEGAN_DATE"
let WatchDataLastWatchSyncDate = "WATCH_DATA_LAST_WATCH_SYNC_DATE"
let WatchDateInsertedItems = "WATCH_DATA_INSERTED_ITEMS"
let WatchDateModifiedItems = "WATCH_DATA_MODIFIED_ITEMS"

//MARK: - Watch Message Contents Constants

let UserRevisionWatchMessageContent = "USER_REVISION_FROM_WATCH_MESSAGE_CONTENTS"
let LastRevisionSyncToWatchMessageContent = "LAST_REVISION_SYNC_TO_WATCH_MESSAGE_CONTENTS"

//MARK: - Defaults

let defaultPresets :[Float] = [8.0, 17.0, 23.0]
let defaultDailyGoal :Float = 64

//MARK: - Localized String

let congratulations_toast_notification_localized_string = "congratulations_toast_notification".localized
let water_added_toast_notification_localized_string = "water_added_toast_notification".localized
let custom_amount_cannot_be_empty_toast_notification_localized_string = "custom_amount_cannot_be_empty_toast_notification".localized
let done_navigation_item_localized_string = "done_navigation_item".localized
let cancel_navigation_item_localized_string = "cancel_navigation_item".localized
let delete_navigation_item_localized_string = "delete_navigation_item".localized
let information_navigation_title_localized_string = "information_navigation_title".localized
let no_water_date_logged_localized_string = "no_water_data_logged".localized
let delete_water_entry_alert_title_localized_string = "delete_water_entry_alert_title".localized
let delete_alert_button_localized_string = "delete_alert_button".localized
let are_you_sure_you_want_to_delete_entry_alert_description_localized_string = "are_you_sure_you_want_to_delete_entry_alert_description".localized
let settings_navigation_title_localized_string = "settings_navigation_title".localized
let close_navigation_item_localized_string = "close_navigation_item".localized
let daily_goal_setting_localized_string = "daily_goal_setting".localized
let small_preset_setting_localized_string = "small_preset_setting".localized
let medium_preset_setting_localized_string = "medium_preset_setting".localized
let large_preset_setting_localized_string = "large_preset_setting".localized
let dark_mode_setting_localized_string = "dark_mode_setting".localized
let auto_switch_themes_setting_localized_string = "auto_switch_themes_setting".localized
let enable_healthkit_setting_localized_string = "enable_healthkit_setting".localized
let manage_healthkit_setting_localized_string = "manage_healthkit_setting".localized

//MARK: - Audio Files

let SplashSound = "Splash.mp3"
let QuickAddSound = "QuickAdd.mp3"
let WaterSound = "Water.wav"
let WellDoneSound = "Well done.wav"
let ErrorSound = "Alert Error.wav"
let ClickSound = "Click.wav"
let PopSound = "Pop.wav"
let BubbleSound = "b4.wav"

// MARK: - UIImage Extenstion
extension UIImage {
    enum AssetIdentifier :String {
        case calendarBackground, check, darkModeBackground, graphBackground, lightModeBackground, automaticThemeChangeCellImage, darkLargePresetImage, darkMediumPresetImage, darkSmallPresetImage, darkModeCellImage, goalCellImage, healthKitCellImage, lightLargePresetImage, lightMediumPresetImage, lightSmallPresetImage, settingsBarButtonItem
    }
    
    convenience init!(assetIdentifier: AssetIdentifier) {
        self.init(named: assetIdentifier.rawValue)
    }
}

// MARK: - SKTexture Extension
extension SKTexture {
    enum AssetIdentifier :String {
        case entryButton, highlightedEntryButton
    }
    
    convenience init!(assetIdentifier :AssetIdentifier) {
        self.init(imageNamed: assetIdentifier.rawValue)
    }
}

extension String {
    var localized: String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "")
    }
}
