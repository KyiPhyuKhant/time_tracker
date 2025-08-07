# TimeTracker

A simple macOS SwiftUI app to track and log your daily work time, organized by date and project. You can add entries with a project code, subtask description, and duration, then view, edit, or delete them in a grouped sidebar.

## Features

* **Date-based grouping**: Sections for each day showing total time.
* **Project grouping**: Within each day, tasks are grouped by project code.
* **Entry management**: Add, edit, and delete individual entries.
* **Duration formatting**: Displays minutes or hours + minutes.

## Prerequisites

* macOS 11.0+ (Big Sur or later)
* Xcode 13.0+ with SwiftUI support
* Swift 5.5 or later

## Installation

1. **Clone the repository**:

   ```bash
   git clone https://github.com/your-username/time-tracker.git
   cd time-tracker
   ```
2. **Open in Xcode**:

   ```bash
   open TimeTracker.xcodeproj
   ```
3. **Build & Run**:

   * Select **My Mac** as the target device.
   * Press **⌘R** to compile and launch the app.

## Usage

1. **Add an entry**:

   * Choose a date from the date picker.
   * Enter a project code (e.g., `KIP-1375`).
   * Enter a subtask description.
   * Enter duration in minutes (e.g., `45`).
   * Click **Add Entry**.
2. **View entries** in the sidebar, grouped by day and project.
3. **Edit** or **delete** entries using the pencil and trash icons on each row.

## Development

* Models are in `ContentView.swift` and include `TaskEntry`, `DailyLog`, and `LogStore`.
* Main UI is in `ContentView.swift`, with a SwiftUI `NavigationView` layout.
* Editing is handled by `EditEntryView` in a sheet.

## Contributing

1. Fork the repo and create a feature branch:

   ```bash
   git checkout -b feature/my-new-feature
   ```
2. Commit your changes:

   ```bash
   git commit -am "Add new feature"
   ```
3. Push to the branch and open a PR.

## License

This project is released under the MIT License.
