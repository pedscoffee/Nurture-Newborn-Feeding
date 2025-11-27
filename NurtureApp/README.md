# Nurture iOS App

This directory contains the source code for the Nurture iOS App, a native SwiftUI application for tracking newborn feeding and diapers.

## Project Setup

Since this code was generated outside of Xcode, you will need to create a new Xcode project and import these files.

### Prerequisites
- Xcode 15.0 or later
- iOS 17.0+ target

### Instructions

1.  **Create a New Project**:
    - Open Xcode and create a new **App** project.
    - Product Name: `Nurture`
    - Interface: **SwiftUI**
    - Language: **Swift**
    - Storage: **SwiftData** (Check the box)
    - Include Tests: Optional

2.  **Import Files**:
    - Delete the default `ContentView.swift`, `NurtureApp.swift`, and `Item.swift` (or whatever default model Xcode created).
    - Drag the following folders from this directory into your Xcode project navigator (make sure "Copy items if needed" is checked):
        - `App`
        - `Models`
        - `Services`
        - `Managers`
        - `Views`
        - `Design`

3.  **Add Capabilities**:
    - Go to your Project Target > **Signing & Capabilities**.
    - Add **Background Modes** -> Check **Remote notifications**.
    - Add **iCloud** -> Check **CloudKit** (if you plan to use Sync).
    - Add **Push Notifications**.

4.  **Add Live Activity Extension**:
    - File > New > Target...
    - Select **Widget Extension**.
    - Name it `NurtureWidget`.
    - Make sure "Include Live Activity" is checked.
    - Replace the generated files in the extension group with the files from the `NurtureWidgetExtension` folder provided here.

5.  **Assets**:
    - You will need to add your app icon and any custom images to `Assets.xcassets`.
    - For the audio service, add sound files named `chime1.mp3`, `chime2.mp3`, etc., to the main bundle resources.

6.  **Build and Run**:
    - Select your simulator or device and hit Run (Cmd+R).

## Architecture

- **MVVM**: The app uses `NurtureManager` as a central view model/coordinator.
- **SwiftData**: Local persistence for `Baby`, `FeedEvent`, etc.
- **Services**: Logic is separated into services (`TimerService`, `NotificationService`, etc.) to keep views clean.

## Features

- **Feeding Timer**: Countdown and Stopwatch modes.
- **Tracking**: Log feeds (breast/bottle/formula) and diapers (wet/dirty).
- **History**: View and edit past events.
- **Settings**: Customize themes, intervals, and baby profiles.
- **Live Activities**: Track timer status from the Lock Screen.
