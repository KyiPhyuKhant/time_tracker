import SwiftUI

typealias Minutes = Int

// Data models: editable entries
struct TaskEntry: Identifiable, Equatable {
    let id: UUID
    var project: String
    var description: String
    var durationMinutes: Minutes
}

struct DailyLog: Identifiable, Equatable {
    let id: UUID
    let date: Date
    var entries: [TaskEntry]
}

// View model
class LogStore: ObservableObject {
    @Published var logs: [DailyLog] = []

    func addEntry(on date: Date, project: String, description: String, durationMinutes: Minutes) {
        let dayStart = Calendar.current.startOfDay(for: date)
        let entry = TaskEntry(id: UUID(), project: project, description: description, durationMinutes: durationMinutes)
        if let idx = logs.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: dayStart) }) {
            logs[idx].entries.append(entry)
        } else {
            logs.append(DailyLog(id: UUID(), date: dayStart, entries: [entry]))
            logs.sort { $0.date > $1.date }
        }
    }

    func updateEntry(_ entry: TaskEntry) {
        for i in logs.indices {
            if let j = logs[i].entries.firstIndex(where: { $0.id == entry.id }) {
                logs[i].entries[j] = entry
                return
            }
        }
    }

    func deleteEntry(_ entry: TaskEntry) {
        for i in logs.indices {
            if let j = logs[i].entries.firstIndex(of: entry) {
                logs[i].entries.remove(at: j)
                if logs[i].entries.isEmpty {
                    logs.remove(at: i)
                }
                return
            }
        }
    }

    func totalMinutes(for log: DailyLog) -> Minutes {
        log.entries.reduce(0) { $0 + $1.durationMinutes }
    }
}

// Main view
struct ContentView: View {
    @ObservedObject var store = LogStore()

    // form state
    @State private var selectedDate = Date()
    @State private var entryProject = ""
    @State private var entryDescription = ""
    @State private var entryDuration = ""

    // editing sheet
    @State private var editingEntry: TaskEntry?

    var isFormValid: Bool {
        !entryProject.isEmpty && !entryDescription.isEmpty && Int(entryDuration) != nil
    }

    var body: some View {
        NavigationView {
            // Sidebar: grouped by day then list entries with edit/delete buttons
            List {
                ForEach(store.logs) { daily in
                    Section(header: headerView(for: daily)) {
                        ForEach(daily.entries) { entry in
                            HStack(spacing: 12) {
                                VStack(alignment: .leading) {
                                    Text(entry.project).font(.headline)
                                    Text(entry.description)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Text(durationString(minutes: entry.durationMinutes))
                                    .font(.callout)
                                    .frame(minWidth: 50, alignment: .trailing)
                                Button(action: { editingEntry = entry }) {
                                    Image(systemName: "pencil")
                                }
                                .buttonStyle(BorderlessButtonStyle())
                                Button(role: .destructive, action: { store.deleteEntry(entry) }) {
                                    Image(systemName: "trash")
                                }
                                .buttonStyle(BorderlessButtonStyle())
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            .listStyle(SidebarListStyle())
            .navigationTitle("Time Tracker")

            // Detail form
            Form {
                Section(header: Text("New Entry").font(.title2)) {
                    DatePicker("Date", selection: $selectedDate, displayedComponents: .date)
                    TextField("Project Code", text: $entryProject)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    TextField("Subtask Description", text: $entryDescription)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    TextField("Duration (min)", text: $entryDuration)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 200)
                    Button("Add Entry") {
                        guard isFormValid, let mins = Int(entryDuration) else { return }
                        store.addEntry(on: selectedDate,
                                       project: entryProject,
                                       description: entryDescription,
                                       durationMinutes: mins)
                        entryProject = ""; entryDescription = ""; entryDuration = ""
                    }
                    .disabled(!isFormValid)
                }
            }
            .padding()
        }
        .frame(minWidth: 800, minHeight: 500)
        .sheet(item: $editingEntry) { entry in
            EditEntryView(entry: entry) { updated in
                store.updateEntry(updated)
            }
        }
    }

    private func headerView(for daily: DailyLog) -> some View {
        let total = store.totalMinutes(for: daily)
        let dateStr = DateFormatter.localizedString(
            from: daily.date,
            dateStyle: .medium,
            timeStyle: .none)
        return HStack {
            Text("\(dateStr) — \(durationString(minutes: total))")
                .font(.headline)
            Spacer()
        }
        .padding(.vertical, 4)
    }

    private func durationString(minutes: Minutes) -> String {
        if minutes < 60 {
            return "\(minutes)m"
        } else {
            let h = minutes / 60; let m = minutes % 60
            return m > 0 ? "\(h)h \(m)m" : "\(h)h"
        }
    }
}

// Edit sheet
struct EditEntryView: View {
    @Environment(\.presentationMode) private var presentationMode
    @State var entry: TaskEntry
    var onSave: (TaskEntry) -> Void

    var isValid: Bool {
        !entry.project.isEmpty && !entry.description.isEmpty
    }

    var body: some View {
        Form {
            TextField("Project Code", text: $entry.project)
            TextField("Subtask", text: $entry.description)
            TextField("Duration", value: $entry.durationMinutes, formatter: NumberFormatter())
                .frame(width: 80)
            HStack {
                Spacer()
                Button("Save") {
                    onSave(entry)
                    presentationMode.wrappedValue.dismiss()
                }
                .disabled(!isValid)
                Spacer()
            }
        }
        .padding()
        .frame(width: 300)
    }
}
