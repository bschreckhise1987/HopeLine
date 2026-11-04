//
//  PrayerView.swift
//  HopeLine
//
//  Created by StalkyTwig1987 on 11/3/26.
//

import SwiftUI

struct PrayerView: View {

    @State private var selectedTab: PrayerTab = .community
    @State private var showingNewPrayer = false

    @State private var communityPrayers: [CommunityPrayer] = []
    @State private var myPrayers: [CommunityPrayer] = []

    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {

                // MARK: - Header

                VStack(alignment: .leading, spacing: 8) {

                    Text("🙏 Prayer Requests")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text(
                        "We're stronger together. Lift each other up in prayer."
                    )
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                }


                // MARK: - New Prayer Request

                Button {
                    showingNewPrayer = true
                } label: {

                    HStack(spacing: 12) {

                        Image(systemName: "plus.circle.fill")
                            .font(.title3)

                        Text("New Prayer Request")
                            .fontWeight(.semibold)

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.caption)
                    }
                    .foregroundStyle(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.accentColor)
                    .clipShape(
                        RoundedRectangle(cornerRadius: 16)
                    )
                }
                .buttonStyle(.plain)


                // MARK: - Tabs

                Picker(
                    "Prayer View",
                    selection: $selectedTab
                ) {

                    ForEach(PrayerTab.allCases) { tab in
                        Text(tab.title)
                            .tag(tab)
                    }
                }
                .pickerStyle(.segmented)


                // MARK: - Encouragement

                VStack(alignment: .leading, spacing: 8) {

                    Label(
                        "Come Together in Prayer",
                        systemImage: "heart.fill"
                    )
                    .font(.headline)

                    Text(
                        "Encourage one another, pray for one another, and remember that no one has to walk alone."
                    )
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                }
                .padding()
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
                .background(
                    Color(.secondarySystemBackground)
                )
                .clipShape(
                    RoundedRectangle(cornerRadius: 16)
                )


                // MARK: - Content

                if isLoading {

                    loadingView

                } else if let errorMessage {

                    errorView(message: errorMessage)

                } else {

                    switch selectedTab {

                    case .community:
                        communityPrayerSection

                    case .myRequests:
                        myPrayerSection
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Prayer")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadPrayers()
        }
        .refreshable {
            await loadPrayers()
        }
        .sheet(
            isPresented: $showingNewPrayer
        ) {

            NewPrayerRequestView {

                Task {
                    await loadPrayers()
                }
            }
        }
    }


    // MARK: - Community Prayers

    private var communityPrayerSection: some View {

        VStack(alignment: .leading, spacing: 16) {

            VStack(alignment: .leading, spacing: 4) {

                Text("Community Prayers")
                    .font(.title2)
                    .fontWeight(.semibold)

                Text(
                    "Lift up others in the HopeLine community."
                )
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }


            if communityPrayers.isEmpty {

                emptyCommunityView

            } else {

                ForEach(communityPrayers) { prayer in

                    PrayerRequestCard(
                        prayer: prayer,
                        isMyRequest: false,
                        onPrayed: {
                            await prayFor(prayer)
                        },
                        onAnswered: nil
                    )
                }
            }
        }
    }


    // MARK: - My Requests

    private var myPrayerSection: some View {

        VStack(alignment: .leading, spacing: 16) {

            VStack(alignment: .leading, spacing: 4) {

                Text("My Prayer Requests")
                    .font(.title2)
                    .fontWeight(.semibold)

                Text(
                    "See your requests and the people praying alongside you."
                )
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }


            if myPrayers.isEmpty {

                emptyMyPrayersView

            } else {

                ForEach(myPrayers) { prayer in

                    PrayerRequestCard(
                        prayer: prayer,
                        isMyRequest: true,
                        onPrayed: nil,
                        onAnswered: { note in

                            await markPrayerAsAnswered(
                                prayer,
                                note: note
                            )
                        }
                    )
                }
            }
        }
    }


    // MARK: - Load Prayers

    @MainActor
    private func loadPrayers() async {

        isLoading = true
        errorMessage = nil

        do {

            async let community =
                PrayerService.shared
                    .fetchCommunityPrayers()

            async let mine =
                PrayerService.shared
                    .fetchMyPrayers()

            communityPrayers =
                try await community

            myPrayers =
                try await mine

        } catch {

            errorMessage =
                error.localizedDescription
        }

        isLoading = false
    }


    // MARK: - Pray For Request

    @MainActor
    private func prayFor(
        _ prayer: CommunityPrayer
    ) async {

        guard !prayer.hasPrayed else {
            return
        }

        do {

            try await PrayerService.shared
                .prayForRequest(
                    prayerRequestId:
                        prayer.prayer.id
                )

            await loadPrayers()

        } catch {

            errorMessage =
                error.localizedDescription
        }
    }


    // MARK: - Mark Prayer As Answered

    @MainActor
    private func markPrayerAsAnswered(
        _ prayer: CommunityPrayer,
        note: String?
    ) async {

        do {

            try await PrayerService.shared
                .markAsAnswered(
                    prayerRequestId:
                        prayer.prayer.id,
                    answeredNote: note
                )

            await loadPrayers()

        } catch {

            errorMessage =
                error.localizedDescription
        }
    }


    // MARK: - Loading View

    private var loadingView: some View {

        HStack(spacing: 12) {

            ProgressView()

            Text("Loading prayers...")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 36)
    }


    // MARK: - Error View

    private func errorView(
        message: String
    ) -> some View {

        VStack(spacing: 14) {

            Image(
                systemName:
                    "exclamationmark.triangle.fill"
            )
            .font(.title2)
            .foregroundStyle(.orange)

            Text("Unable to Load Prayers")
                .font(.headline)

            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button("Try Again") {

                Task {
                    await loadPrayers()
                }
            }
            .buttonStyle(.bordered)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            Color(.secondarySystemBackground)
        )
        .clipShape(
            RoundedRectangle(cornerRadius: 16)
        )
    }


    // MARK: - Empty Community

    private var emptyCommunityView: some View {

        VStack(spacing: 14) {

            Text("🙏")
                .font(.system(size: 44))

            Text("No community prayers yet")
                .font(.headline)

            Text(
                "Be the first to share a prayer request with the HopeLine community."
            )
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 36)
        .padding(.horizontal)
        .background(
            Color(.secondarySystemBackground)
        )
        .clipShape(
            RoundedRectangle(cornerRadius: 16)
        )
    }


    // MARK: - Empty My Prayers

    private var emptyMyPrayersView: some View {

        VStack(spacing: 14) {

            Text("🙏")
                .font(.system(size: 44))

            Text("No prayer requests yet")
                .font(.headline)

            Text(
                "When you share a prayer request, you can return here and see how many people have prayed with you."
            )
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 36)
        .padding(.horizontal)
        .background(
            Color(.secondarySystemBackground)
        )
        .clipShape(
            RoundedRectangle(cornerRadius: 16)
        )
    }
}


// MARK: - Prayer Tab

private enum PrayerTab:
    String,
    CaseIterable,
    Identifiable {

    case community
    case myRequests

    var id: String {
        rawValue
    }

    var title: String {

        switch self {

        case .community:
            return "Community"

        case .myRequests:
            return "My Requests"
        }
    }
}


// MARK: - Prayer Request Card

private struct PrayerRequestCard: View {

    let prayer: CommunityPrayer
    let isMyRequest: Bool

    let onPrayed: (() async -> Void)?
    let onAnswered: ((String?) async -> Void)?

    @State private var isSubmittingPrayer = false
    @State private var showingAnsweredSheet = false

    var body: some View {

        VStack(
            alignment: .leading,
            spacing: 16
        ) {

            // MARK: - Header

            HStack {

                Image(
                    systemName:
                        "person.crop.circle.fill"
                )
                .font(.title2)
                .foregroundStyle(.blue)

                VStack(
                    alignment: .leading,
                    spacing: 2
                ) {

                    if isMyRequest {

                        Text("My Prayer Request")
                            .font(.subheadline)
                            .fontWeight(.semibold)

                    } else {

                        Text(
                            "HopeLine Community Member"
                        )
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    }

                    Text(
                        prayer.prayer.createdAt.formatted(
                            date: .abbreviated,
                            time: .shortened
                        )
                    )
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }

                Spacer()


                if prayer.prayer.isAnswered {

                    Label(
                        "Answered",
                        systemImage: "sparkles"
                    )
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.green)
                }
            }


            // MARK: - Prayer Request

            Text(
                prayer.prayer.requestText
            )
            .font(.body)
            .frame(
                maxWidth: .infinity,
                alignment: .leading
            )


            // MARK: - Answered Prayer Note

            if prayer.prayer.isAnswered {

                VStack(
                    alignment: .leading,
                    spacing: 8
                ) {

                    Label(
                        "Answered Prayer",
                        systemImage: "sparkles"
                    )
                    .font(.headline)
                    .foregroundStyle(.green)

                    if let note =
                        prayer.prayer.answeredNote,
                       !note.isEmpty {

                        Text(note)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                    } else {

                        Text(
                            "This prayer has been marked as answered."
                        )
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    }
                }
                .padding()
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
                .background(
                    Color.green.opacity(0.08)
                )
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: 12
                    )
                )
            }


            Divider()


            // MARK: - Prayer Response

            HStack {

                Label(
                    prayer.prayerCount == 1
                    ? "1 prayed"
                    : "\(prayer.prayerCount) prayed",
                    systemImage:
                        "hands.sparkles.fill"
                )
                .font(.caption)
                .foregroundStyle(.secondary)

                Spacer()


                if isMyRequest {

                    if prayer.prayer.isAnswered {

                        Label(
                            "Answered",
                            systemImage: "checkmark.circle.fill"
                        )
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.green)

                    } else {

                        Button {

                            showingAnsweredSheet = true

                        } label: {

                            Label(
                                "Mark as Answered",
                                systemImage: "sparkles"
                            )
                        }
                        .font(.caption)
                        .fontWeight(.semibold)
                        .buttonStyle(.bordered)
                    }


                } else if prayer.hasPrayed {

                    Button {
                        // Already prayed
                    } label: {

                        Label(
                            "You Prayed",
                            systemImage: "checkmark"
                        )
                    }
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .buttonStyle(.bordered)
                    .disabled(true)


                } else {

                    Button {

                        guard !isSubmittingPrayer else {
                            return
                        }

                        isSubmittingPrayer = true

                        Task {

                            await onPrayed?()

                            await MainActor.run {
                                isSubmittingPrayer = false
                            }
                        }

                    } label: {

                        if isSubmittingPrayer {

                            ProgressView()

                        } else {

                            Text("🙏 I Prayed")
                        }
                    }
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .buttonStyle(.borderedProminent)
                    .disabled(isSubmittingPrayer)
                }
            }


            // MARK: - Owner Prayer Message

            if isMyRequest &&
                prayer.prayerCount > 0 {

                Text(
                    prayer.prayerCount == 1
                    ? "🙏 Someone prayed for you."
                    : "🙏 \(prayer.prayerCount) people prayed for you."
                )
                .font(.caption)
                .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(
            Color(.secondarySystemBackground)
        )
        .clipShape(
            RoundedRectangle(
                cornerRadius: 16
            )
        )
        .sheet(
            isPresented:
                $showingAnsweredSheet
        ) {

            AnsweredPrayerView(
                prayerText:
                    prayer.prayer.requestText
            ) { note in

                await onAnswered?(note)

                await MainActor.run {
                    showingAnsweredSheet = false
                }
            }
        }
    }
}


// MARK: - Answered Prayer View

private struct AnsweredPrayerView: View {

    @Environment(\.dismiss)
    private var dismiss

    let prayerText: String
    let onSave: (String?) async -> Void

    @State private var answeredNote = ""
    @State private var isSaving = false
    @State private var errorMessage: String?
    @State private var showingError = false

    private let characterLimit = 500


    var body: some View {

        NavigationStack {

            ScrollView {

                VStack(
                    alignment: .leading,
                    spacing: 24
                ) {

                    // MARK: - Header

                    VStack(
                        alignment: .leading,
                        spacing: 8
                    ) {

                        Text("✨")
                            .font(.largeTitle)

                        Text("Answered Prayer")
                            .font(.title2)
                            .fontWeight(.bold)

                        Text(
                            "Celebrate what God has done and share the encouragement with the HopeLine community."
                        )
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    }


                    // MARK: - Original Prayer

                    VStack(
                        alignment: .leading,
                        spacing: 8
                    ) {

                        Text("Original Prayer")
                            .font(.headline)

                        Text(prayerText)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .frame(
                        maxWidth: .infinity,
                        alignment: .leading
                    )
                    .background(
                        Color(.secondarySystemBackground)
                    )
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: 16
                        )
                    )


                    // MARK: - Answer Note

                    VStack(
                        alignment: .leading,
                        spacing: 8
                    ) {

                        Text("What did God do?")
                            .font(.headline)

                        Text(
                            "This part is optional. You can simply mark the prayer answered or share what happened."
                        )
                        .font(.caption)
                        .foregroundStyle(.secondary)

                        TextEditor(
                            text: $answeredNote
                        )
                        .padding(10)
                        .frame(minHeight: 180)
                        .background(
                            Color(
                                .secondarySystemBackground
                            )
                        )
                        .clipShape(
                            RoundedRectangle(
                                cornerRadius: 16
                            )
                        )
                        .disabled(isSaving)
                        .onChange(
                            of: answeredNote
                        ) { _, newValue in

                            if newValue.count >
                                characterLimit {

                                answeredNote =
                                    String(
                                        newValue.prefix(
                                            characterLimit
                                        )
                                    )
                            }
                        }

                        HStack {

                            Text("Optional")
                                .font(.caption)
                                .foregroundStyle(.secondary)

                            Spacer()

                            Text(
                                "\(answeredNote.count)/\(characterLimit)"
                            )
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        }
                    }


                    // MARK: - Save

                    Button {

                        markAnswered()

                    } label: {

                        if isSaving {

                            HStack {

                                ProgressView()
                                    .tint(.white)

                                Text(
                                    "Marking as Answered..."
                                )
                            }
                            .frame(maxWidth: .infinity)

                        } else {

                            Label(
                                "Mark Prayer as Answered",
                                systemImage:
                                    "sparkles"
                            )
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .tint(.green)
                    .disabled(isSaving)
                }
                .padding()
            }
            .navigationTitle(
                "Answered Prayer"
            )
            .navigationBarTitleDisplayMode(
                .inline
            )
            .interactiveDismissDisabled(
                isSaving
            )
            .toolbar {

                ToolbarItem(
                    placement:
                        .cancellationAction
                ) {

                    Button("Cancel") {
                        dismiss()
                    }
                    .disabled(isSaving)
                }
            }
            .alert(
                "Unable to Update Prayer",
                isPresented: $showingError
            ) {

                Button(
                    "OK",
                    role: .cancel
                ) {}

            } message: {

                Text(
                    errorMessage ??
                    "Something went wrong while updating your prayer."
                )
            }
        }
    }


    // MARK: - Mark Answered

    private func markAnswered() {

        guard !isSaving else {
            return
        }

        isSaving = true

        let trimmedNote =
            answeredNote.trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        let note: String? =
            trimmedNote.isEmpty
            ? nil
            : trimmedNote

        Task {

            await onSave(note)

            await MainActor.run {
                isSaving = false
                dismiss()
            }
        }
    }
}


// MARK: - New Prayer Request

private struct NewPrayerRequestView: View {

    @Environment(\.dismiss)
    private var dismiss

    @State private var prayerText = ""
    @State private var isSharing = false
    @State private var errorMessage: String?
    @State private var showingError = false

    let onShared: () -> Void

    private let characterLimit = 500


    var body: some View {

        NavigationStack {

            ScrollView {

                VStack(
                    alignment: .leading,
                    spacing: 24
                ) {

                    // MARK: - Header

                    VStack(
                        alignment: .leading,
                        spacing: 8
                    ) {

                        Text("🙏")
                            .font(.largeTitle)

                        Text(
                            "What can we pray about?"
                        )
                        .font(.title2)
                        .fontWeight(.bold)

                        Text(
                            "Share what's on your heart. You're not alone."
                        )
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    }


                    // MARK: - Prayer Editor

                    VStack(
                        alignment: .trailing,
                        spacing: 8
                    ) {

                        TextEditor(
                            text: $prayerText
                        )
                        .padding(10)
                        .frame(minHeight: 220)
                        .background(
                            Color(
                                .secondarySystemBackground
                            )
                        )
                        .clipShape(
                            RoundedRectangle(
                                cornerRadius: 16
                            )
                        )
                        .disabled(isSharing)
                        .onChange(
                            of: prayerText
                        ) { _, newValue in

                            if newValue.count >
                                characterLimit {

                                prayerText =
                                    String(
                                        newValue.prefix(
                                            characterLimit
                                        )
                                    )
                            }
                        }

                        Text(
                            "\(prayerText.count)/\(characterLimit)"
                        )
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }


                    // MARK: - Community Notice

                    VStack(
                        alignment: .leading,
                        spacing: 10
                    ) {

                        Label(
                            "Shared With HopeLine",
                            systemImage:
                                "person.3.fill"
                        )
                        .font(.headline)

                        Text(
                            "Your prayer request will be shared with the HopeLine community so others can come alongside you in prayer."
                        )
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    }
                    .padding()
                    .frame(
                        maxWidth: .infinity,
                        alignment: .leading
                    )
                    .background(
                        Color(
                            .secondarySystemBackground
                        )
                    )
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: 16
                        )
                    )


                    // MARK: - Share Button

                    Button {

                        sharePrayer()

                    } label: {

                        if isSharing {

                            HStack {

                                ProgressView()
                                    .tint(.white)

                                Text(
                                    "Sharing Prayer..."
                                )
                            }
                            .frame(
                                maxWidth: .infinity
                            )

                        } else {

                            Label(
                                "Share Prayer Request",
                                systemImage:
                                    "hands.sparkles.fill"
                            )
                            .fontWeight(.semibold)
                            .frame(
                                maxWidth: .infinity
                            )
                        }
                    }
                    .buttonStyle(
                        .borderedProminent
                    )
                    .controlSize(.large)
                    .disabled(
                        isSharing ||
                        prayerText
                            .trimmingCharacters(
                                in:
                                    .whitespacesAndNewlines
                            )
                            .isEmpty
                    )
                }
                .padding()
            }
            .navigationTitle(
                "New Prayer Request"
            )
            .navigationBarTitleDisplayMode(
                .inline
            )
            .interactiveDismissDisabled(
                isSharing
            )
            .toolbar {

                ToolbarItem(
                    placement:
                        .cancellationAction
                ) {

                    Button("Cancel") {
                        dismiss()
                    }
                    .disabled(isSharing)
                }
            }
            .alert(
                "Unable to Share Prayer",
                isPresented: $showingError
            ) {

                Button(
                    "OK",
                    role: .cancel
                ) {}

            } message: {

                Text(
                    errorMessage ??
                    "Something went wrong while sharing your prayer request."
                )
            }
        }
    }


    // MARK: - Share Prayer

    private func sharePrayer() {

        guard !isSharing else {
            return
        }

        isSharing = true
        errorMessage = nil

        Task {

            do {

                try await PrayerService.shared
                    .sharePrayer(
                        requestText: prayerText
                    )

                await MainActor.run {

                    isSharing = false
                    onShared()
                    dismiss()
                }

            } catch {

                await MainActor.run {

                    isSharing = false

                    errorMessage =
                        error.localizedDescription

                    showingError = true
                }
            }
        }
    }
}


// MARK: - Preview

#Preview {

    NavigationStack {
        PrayerView()
    }
}
