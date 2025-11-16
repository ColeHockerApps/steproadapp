import SwiftUI
import Combine

struct RoadsScreen: View {
    @EnvironmentObject private var tint: EmberTint
    @EnvironmentObject private var vault: TrailVault
    @EnvironmentObject private var vm: RoadsViewModel
    @EnvironmentObject private var config: FireConfigStore

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if vault.roads.isEmpty {
                    emptyState
                } else {
                    List {
                        if let active = vault.activeRoad() {
                            Section("Active Road") {
                                roadCard(active, isActive: true)
                            }
                        }

                        let others = vault.roads.filter { !$0.isActive }
                        if !others.isEmpty {
                            Section("Other Roads") {
                                ForEach(others) { road in
                                    roadCard(road, isActive: false)
                                }
                                .onDelete { indexSet in
                                    for index in indexSet {
                                        let list = others
                                        if index < list.count {
                                            vm.delete(list[index], in: vault)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .background(tint.background)
                }
            }
            .navigationTitle("Roads")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        vm.prepareNewRoad()
                    } label: {
                        Image(systemName: TrailGlyphs.add)
                            .font(.title2)
                            .foregroundColor(tint.primary)
                    }
                }
            }
            .sheet(isPresented: $vm.isPresentingEditor) {
                editorSheet
            }
        }
    }

    // MARK: - Cards

    @ViewBuilder
    private func roadCard(_ road: Road, isActive: Bool) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(road.title)
                    .font(.headline)
                    .foregroundColor(isActive ? tint.primary : .primary)

                Spacer()

                if isActive {
                    Image(systemName: TrailGlyphs.fireMedium)
                        .foregroundColor(BlazeTokens.fireHigh)
                }
            }

            ProgressView(
                value: road.progress,
                label: { EmptyView() }
            )
            .tint(tint.primary)

            HStack {
                Text(vm.progressText(for: road))
                    .font(.caption)

                Spacer()

                if let streak = vm.fireLevel(for: road, in: vault) {
                    Text("🔥 \(streak.current)")
                        .font(.caption)
                        .foregroundColor(BlazeTokens.fireMedium)
                }
            }
        }
        .padding(.vertical, 6)
        .contentShape(Rectangle())
        .onTapGesture {
            vm.setActive(road, in: vault)
        }
        .swipeActions {
            Button(role: .destructive) {
                vm.delete(road, in: vault)
            } label: {
                Image(systemName: TrailGlyphs.delete)
            }

            Button {
                vm.beginEditing(road)
            } label: {
                Image(systemName: TrailGlyphs.edit)
            }
            .tint(.blue)
        }
    }

    // MARK: - Empty state

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: TrailGlyphs.roads)
                .font(.system(size: 48))
                .foregroundColor(tint.primary.opacity(0.6))

            Text("No Roads Yet")
                .font(.headline)

            Text("Create your first Road to begin your journey.")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Button {
                vm.prepareNewRoad()
            } label: {
                Text("Create Road")
                    .font(.headline)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(tint.primary.opacity(0.15))
                    .cornerRadius(12)
            }
        }
        .padding(.top, 60)
    }

    // MARK: - Editor Sheet

    private var editorSheet: some View {
        NavigationStack {
            Form {
                Section("Title") {
                    TextField("Road name", text: $vm.newRoadTitle)
                }

                Section("Total Steps") {
                    Stepper(value: $vm.newRoadTargetSteps, in: 25...1000000, step: 25) {
                        Text("\(vm.newRoadTargetSteps) steps")
                    }
                }
            }
            .navigationTitle(vm.editingRoad == nil ? "New Road" : "Edit Road")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        vm.cancelEdit()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if vm.editingRoad == nil {
                            vm.createRoad(in: vault)
                        } else {
                            vm.applyEdit(in: vault)
                        }
                    }
                }
            }
        }
    }
}
