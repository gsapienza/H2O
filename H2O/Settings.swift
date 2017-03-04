//
//  SettingCollection.swift
//  H2O
//
//  Created by Gregory Sapienza on 2/26/17.
//  Copyright © 2017 Skyscrapers.IO. All rights reserved.
//

import Foundation

/// Each item in settings must conform to this protocol.
protocol SettingsProtocol {
    
    /// Id representing setting.
    var id: String? { get set }
}

/// Collection containing sections that contain groups representing settings.
struct Settings<t: SettingsProtocol> {
    
    /// Section of settings.
    typealias Section = [t]
    
    /// The number of sections that contain settings.
    var sectionCount: Int {
        get {
            return sections.count
        }
    }
    
    /// Array containing sections.
    private var sections: [Section] = []
    
    /// Appends a new section to existing sections.
    ///
    /// - Parameter section: Section that contain settings.
    mutating func appendSection(_ section: Section) {
        sections.append(section)
    }
    
    /// Appends multiple sections to existing sections.
    ///
    /// - Parameter sections: Array of sections that contain settings.
    mutating func appendSections(_ sections: [Section]) {
        for section in sections {
            appendSection(section)
        }
    }
    
    /// Appends a setting to the last section. If no section exists, one will be created.
    ///
    /// - Parameter setting: Setting to add to section.
    mutating func appendSetting(_ setting: t) {
        if sections.isEmpty {
            appendSection([setting])
        } else {
            var lastSection = sections.last
            lastSection?.append(setting)
        }
    }
    
    
    /// Removes a section from the collection of sections.
    ///
    /// - Parameter index: Index of section to remove.
    mutating func removeSection(at index: Int) {
        sections.remove(at: index)
    }
    
    /// Removes a setting from a specified section.
    ///
    /// - Parameters:
    ///   - sectionIndex: Index of section that contains the setting to remove.
    ///   - index: Index of the setting within the specified section.
    mutating func removeSetting(for sectionIndex: Int, at index: Int) {
        sections[sectionIndex].remove(at: index)
    }
    
    /// Returns a section at an index.
    ///
    /// - Parameter index: Index of section to return.
    /// - Returns: Section for specified index.
    func section(for index: Int) -> Section {
        return sections[index]
    }
    
    /// Returns a setting within a particular section.
    ///
    /// - Parameters:
    ///   - section: Section that contains the setting.
    ///   - index: Index of the setting to return.
    /// - Returns: Setting for specified section and setting index.
    func setting(for section: Section, index: Int) -> t {
        return section[index]
    }
    
    /// Returns a setting within a particular section.
    ///
    /// - Parameters:
    ///   - sectionIndex: Index of section that contains the setting.
    ///   - settingIndex: Index of the setting to return.
    /// - Returns: Setting for specified section and setting index.
    func setting(sectionIndex: Int, settingIndex: Int) -> t {
        return sections[sectionIndex][settingIndex]
    }
    
    /// Returns a setting from any section based on its Id. Returns nil if setting was not found.
    ///
    /// - Parameter id: Id of setting to return.
    /// - Returns: Setting for specified id.
    func settingForId(id: String) -> t? {
        for section in sections {
            for setting in section {
                if setting.id == id {
                    return setting
                }
            }
        }
        
        return nil
    }
}



//Not using atm.
private struct SettingsGenerator<t: SettingsProtocol>: IteratorProtocol {
    typealias Element = [t]
    
    private var sections: [Element]
    private var idx = 0
    
    init(sections: [Element]) {
        self.sections = sections
    }
    
    fileprivate mutating func next() -> [t]? {
        if idx == sections.endIndex {
            return nil
        } else {
            let obj = sections[idx];
            idx += 1
            return obj
        }
    }
}
