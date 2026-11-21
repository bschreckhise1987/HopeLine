//
//  SettingsView.swift
//  HopeLine
//
//  Created by StalkyTwig1987 on 11/8/26.
//

import SwiftUI


struct SettingsView: View {

    // MARK: - State

    @EnvironmentObject private var authManager: AuthManager

    @State private var showingSignOutConfirmation = false

    @AppStorage("appearancePreference")
    private var appearancePreference =
        AppearanceOption.system.rawValue

    @State private var notificationsEnabled = true

    @State private var personalizedScriptureEnabled = true

    @State private var checkInScriptureEnabled = true

    @State private var meetingLocationEnabled = true


    // MARK: - Appearance Binding

    // Bridges @AppStorage (a String) and the Picker (which wants an
    // AppearanceOption). Reading converts the saved String back into an
    // option; writing stores the user's new choice to @AppStorage.
    private var selectedAppearance:
        Binding<AppearanceOption> {

        Binding(
            get: {
                AppearanceOption(
                    rawValue: appearancePreference
                ) ?? .system
            },
            set: { newValue in

                appearancePreference =
                    newValue.rawValue
            }
        )
    }


    // MARK: - Body

    var body: some View {

        ScrollView {

            VStack(
                alignment: .leading,
                spacing: 28
            ) {

                // MARK: - Header

                VStack(
                    alignment: .leading,
                    spacing: 8
                ) {

                    Text("⚙️ Settings")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text(
                        "Personalize HopeLine and manage your account."
                    )
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                }


                // MARK: - Account

                SettingsSection(
                    title: "YOUR ACCOUNT"
                ) {

                    NavigationLink {

                        AccountPlaceholderView()

                    } label: {

                        SettingsRow(
                            icon: "person.crop.circle.fill",
                            iconColor: .blue,
                            title: "Account",
                            subtitle:
                                "Manage your HopeLine account"
                        )
                    }
                    .buttonStyle(.plain)
                }


                // MARK: - Personalize HopeLine

                SettingsSection(
                    title: "PERSONALIZE HOPELINE"
                ) {

                    // MARK: Appearance

                    VStack(
                        alignment: .leading,
                        spacing: 14
                    ) {

                        SettingsRow(
                            icon:
                                "circle.lefthalf.filled",
                            iconColor: .purple,
                            title: "Appearance",
                            subtitle:
                                "Choose how HopeLine looks",
                            showsChevron: false
                        )


                        Picker(
                            "Appearance",
                            selection:
                                selectedAppearance
                        ) {

                            ForEach(
                                AppearanceOption.allCases
                            ) { option in

                                Text(option.title)
                                    .tag(option)
                            }
                        }
                        .pickerStyle(.segmented)
                    }


                    SettingsDivider()


                    // MARK: Accessibility

                    NavigationLink {

                        AccessibilitySettingsView()

                    } label: {

                        SettingsRow(
                            icon:
                                "accessibility.fill",
                            iconColor: .green,
                            title: "Accessibility",
                            subtitle:
                                "Text, contrast, motion, and readability"
                        )
                    }
                    .buttonStyle(.plain)


                    SettingsDivider()


                    // MARK: Scripture

                    NavigationLink {

                        ScriptureSettingsView(
                            personalizedScriptureEnabled:
                                $personalizedScriptureEnabled,
                            checkInScriptureEnabled:
                                $checkInScriptureEnabled
                        )

                    } label: {

                        SettingsRow(
                            icon: "book.closed.fill",
                            iconColor: .blue,
                            title: "Scripture",
                            subtitle:
                                "Scripture and personalization preferences"
                        )
                    }
                    .buttonStyle(.plain)


                    SettingsDivider()


                    // MARK: Notifications

                    HStack(spacing: 14) {

                        SettingsIcon(
                            systemName:
                                "bell.fill",
                            color: .orange
                        )


                        VStack(
                            alignment: .leading,
                            spacing: 3
                        ) {

                            Text("Notifications")
                                .font(.headline)

                            Text(
                                "Encouragement and reminders"
                            )
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        }


                        Spacer()


                        Toggle(
                            "",
                            isOn:
                                $notificationsEnabled
                        )
                        .labelsHidden()
                        .accessibilityLabel(
                            "Notifications"
                        )
                    }
                }


                // MARK: - Recovery & Support

                SettingsSection(
                    title: "RECOVERY & SUPPORT"
                ) {

                    NavigationLink {

                        RecoveryPreferencesView()

                    } label: {

                        SettingsRow(
                            icon: "heart.fill",
                            iconColor: .pink,
                            title:
                                "Recovery Preferences",
                            subtitle:
                                "Personalize your recovery experience"
                        )
                    }
                    .buttonStyle(.plain)


                    SettingsDivider()


                    // MARK: Meeting Location

                    HStack(spacing: 14) {

                        SettingsIcon(
                            systemName:
                                "location.fill",
                            color: .blue
                        )


                        VStack(
                            alignment: .leading,
                            spacing: 3
                        ) {

                            Text("Meeting Location")
                                .font(.headline)

                            Text(
                                "Use your location to find nearby meetings"
                            )
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        }


                        Spacer()


                        Toggle(
                            "",
                            isOn:
                                $meetingLocationEnabled
                        )
                        .labelsHidden()
                        .accessibilityLabel(
                            "Meeting Location"
                        )
                    }
                }


                // MARK: - Privacy & Data

                SettingsSection(
                    title: "PRIVACY & DATA"
                ) {

                    NavigationLink {

                        PrivacySettingsView()

                    } label: {

                        SettingsRow(
                            icon:
                                "lock.shield.fill",
                            iconColor: .green,
                            title: "Privacy",
                            subtitle:
                                "Review HopeLine privacy options"
                        )
                    }
                    .buttonStyle(.plain)


                    SettingsDivider()


                    NavigationLink {

                        MyDataView()

                    } label: {

                        SettingsRow(
                            icon:
                                "externaldrive.fill",
                            iconColor: .indigo,
                            title: "My Data",
                            subtitle:
                                "Journal, Scriptures, check-ins, and activity"
                        )
                    }
                    .buttonStyle(.plain)
                }


                // MARK: - About

                SettingsSection(
                    title: "ABOUT"
                ) {

                    NavigationLink {

                        AboutHopeLineView()

                    } label: {

                        SettingsRow(
                            icon:
                                "info.circle.fill",
                            iconColor: .blue,
                            title:
                                "About HopeLine",
                            subtitle:
                                "Purpose, acknowledgments, and app information"
                        )
                    }
                    .buttonStyle(.plain)


                    SettingsDivider()


                    NavigationLink {

                        PrivacyPolicyView()

                    } label: {

                        SettingsRow(
                            icon:
                                "hand.raised.fill",
                            iconColor: .gray,
                            title:
                                "Privacy Policy",
                            subtitle:
                                "Learn how HopeLine protects your information"
                        )
                    }
                    .buttonStyle(.plain)


                    SettingsDivider()


                    NavigationLink {

                        TermsResourcesView()

                    } label: {

                        SettingsRow(
                            icon:
                                "doc.text.fill",
                            iconColor: .gray,
                            title:
                                "Terms & Resources",
                            subtitle:
                                "Important information and resources"
                        )
                    }
                    .buttonStyle(.plain)
                }


                // MARK: - Sign Out

                Button(
                    role: .destructive
                ) {

                    showingSignOutConfirmation =
                        true

                } label: {

                    HStack(spacing: 12) {

                        Image(
                            systemName:
                                "rectangle.portrait.and.arrow.right"
                        )
                        .font(.headline)


                        Text("Sign Out")
                            .fontWeight(.semibold)


                        Spacer()
                    }
                    .padding()
                    .frame(
                        maxWidth: .infinity
                    )
                }
                .buttonStyle(.bordered)
                .tint(.red)


                // MARK: - Footer

                VStack(spacing: 6) {

                    Text(
                        "Support When It Matters Most"
                    )
                    .font(.caption)
                    .fontWeight(.semibold)


                    Text("HopeLine")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                .frame(
                    maxWidth: .infinity
                )
                .padding(.top, 4)
            }
            .padding()
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog(
            "Sign Out of HopeLine?",
            isPresented:
                $showingSignOutConfirmation,
            titleVisibility: .visible
        ) {

            Button(
                "Sign Out",
                role: .destructive
            ) {

                Task {
                    await signOut()
                }
            }


            Button(
                "Cancel",
                role: .cancel
            ) { }

        } message: {

            Text(
                "You can sign back in anytime."
            )
        }
    }


    // MARK: - Sign Out

    private func signOut() async {

        do {

            try await authManager.signOut()

        } catch {

            // AuthManager already manages
            // authentication state/errors.
        }
    }
}


// MARK: - Settings Section

// A titled card that groups related settings rows, styled like Apple's
// inset grouped Settings sections.
private struct SettingsSection<
    Content: View
>: View {

    let title: String

    @ViewBuilder
    let content: Content


    var body: some View {

        VStack(
            alignment: .leading,
            spacing: 10
        ) {

            Text(title)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
                .padding(.leading, 4)


            VStack(
                alignment: .leading,
                spacing: 16
            ) {

                content
            }
            .padding()
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
        }
    }
}


// MARK: - Settings Row

// A single settings row: colored icon, title, subtitle, and an optional
// navigation chevron. Reused by every row on the Settings screen.
private struct SettingsRow: View {

    let icon: String

    let iconColor: Color

    let title: String

    let subtitle: String

    var showsChevron: Bool = true


    var body: some View {

        HStack(spacing: 14) {

            SettingsIcon(
                systemName: icon,
                color: iconColor
            )


            VStack(
                alignment: .leading,
                spacing: 3
            ) {

                Text(title)
                    .font(.headline)
                    .foregroundStyle(.primary)


                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(
                        .leading
                    )
                    .fixedSize(
                        horizontal: false,
                        vertical: true
                    )
            }


            Spacer()


            if showsChevron {

                Image(
                    systemName:
                        "chevron.right"
                )
                .font(.caption)
                .foregroundStyle(
                    .tertiary
                )
            }
        }
        .contentShape(Rectangle())
    }
}


// MARK: - Settings Icon

// The rounded colored tile shown at the start of each settings row.
// Hidden from VoiceOver because the row's title already describes it.
private struct SettingsIcon: View {

    let systemName: String

    let color: Color


    var body: some View {

        Image(
            systemName: systemName
        )
        .font(.headline)
        .foregroundStyle(color)
        .frame(
            width: 36,
            height: 36
        )
        .background(
            color.opacity(0.12)
        )
        .clipShape(
            RoundedRectangle(
                cornerRadius: 10
            )
        )
        .accessibilityHidden(true)
    }
}


// MARK: - Divider

// A divider indented so it lines up with the row text instead of the icon.
private struct SettingsDivider: View {

    var body: some View {

        Divider()
            .padding(.leading, 50)
    }
}


// MARK: - Accessibility Settings

// The Accessibility screen. Split into two halves: HopeLine's own
// accessibility toggles (which change the app immediately) and read-only
// status rows reflecting the device's accessibility settings.
private struct AccessibilitySettingsView:
    View {

    // MARK: HopeLine Accessibility

    @AppStorage(
        "enhancedReadability"
    )
    private var enhancedReadability =
        false


    @AppStorage(
        "reduceVisualEffects"
    )
    private var reduceVisualEffects =
        false


    @AppStorage(
        "alwaysShowLabels"
    )
    private var alwaysShowLabels =
        false


    // MARK: iPhone Accessibility

    @Environment(
        \.accessibilityReduceMotion
    )
    private var systemReduceMotion


    @Environment(
        \.accessibilityReduceTransparency
    )
    private var systemReduceTransparency


    @Environment(
        \.accessibilityDifferentiateWithoutColor
    )
    private var systemDifferentiateWithoutColor


    var body: some View {

        Form {

            // MARK: HopeLine Accessibility

            Section {

                AccessibilityPreferenceToggle(
                    title:
                        "Enhanced Readability",
                    description:
                        "Uses larger text throughout HopeLine.",
                    systemImage:
                        "textformat.size.larger",
                    isOn:
                        $enhancedReadability
                )


                AccessibilityPreferenceToggle(
                    title:
                        "Reduce Visual Effects",
                    description:
                        "Reduces HopeLine animations and transitions.",
                    systemImage:
                        "sparkles",
                    isOn:
                        $reduceVisualEffects
                )


                AccessibilityPreferenceToggle(
                    title:
                        "Always Show Text Labels",
                    description:
                        "Shows text with supported HopeLine icons.",
                    systemImage:
                        "character.bubble.fill",
                    isOn:
                        $alwaysShowLabels
                )

            } header: {

                Text(
                    "HopeLine Accessibility"
                )

            } footer: {

                Text(
                    """
                    These preferences apply throughout HopeLine and do not change your iPhone's accessibility settings.
                    """
                )
            }


            // MARK: iPhone Accessibility

            Section {

                AccessibilityStatusRow(
                    title:
                        "Reduce Motion",
                    systemImage:
                        "figure.walk.motion",
                    enabled:
                        systemReduceMotion
                )


                AccessibilityStatusRow(
                    title:
                        "Reduce Transparency",
                    systemImage:
                        "circle.lefthalf.filled",
                    enabled:
                        systemReduceTransparency
                )


                AccessibilityStatusRow(
                    title:
                        "Differentiate Without Color",
                    systemImage:
                        "paintpalette.fill",
                    enabled:
                        systemDifferentiateWithoutColor
                )

            } header: {

                Text(
                    "iPhone Accessibility"
                )

            } footer: {

                Text(
                    """
                    HopeLine respects supported accessibility preferences configured on your device.
                    """
                )
            }


            // MARK: Text & Readability

            Section {

                VStack(
                    alignment: .leading,
                    spacing: 10
                ) {

                    Label(
                        "Dynamic Type",
                        systemImage:
                            "textformat.size"
                    )
                    .font(.headline)


                    Text(
                        """
                        HopeLine uses dynamic text styles so supported text can respond to the text size selected on your device.
                        """
                    )
                    .font(.subheadline)
                    .foregroundStyle(
                        .secondary
                    )
                }
                .padding(
                    .vertical,
                    4
                )

            } header: {

                Text(
                    "Text & Readability"
                )

            } footer: {

                Text(
                    """
                    Larger Text and Bold Text can be adjusted from your iPhone Accessibility settings.
                    """
                )
            }


            // MARK: Designed for Support

            Section {

                VStack(
                    alignment: .leading,
                    spacing: 10
                ) {

                    Label(
                        "Designed for Support",
                        systemImage:
                            "heart.fill"
                    )
                    .font(.headline)
                    .foregroundStyle(
                        .blue
                    )


                    Text(
                        """
                        HopeLine is designed so important recovery tools, Scripture, prayer, journaling, meetings, and support remain understandable without relying only on color or visual effects.
                        """
                    )
                    .font(.subheadline)
                    .foregroundStyle(
                        .secondary
                    )
                }
                .padding(
                    .vertical,
                    4
                )
            }
        }
        .navigationTitle(
            "Accessibility"
        )
        .navigationBarTitleDisplayMode(
            .inline
        )
    }
}


// MARK: - Accessibility Preference Toggle

// One of HopeLine's own accessibility rows: icon, title, description,
// and a toggle. Includes VoiceOver label and hint for each switch.
private struct AccessibilityPreferenceToggle:
    View {

    let title: String

    let description: String

    let systemImage: String

    @Binding
    var isOn: Bool


    var body: some View {

        HStack(
            alignment: .center,
            spacing: 12
        ) {

            Image(
                systemName:
                    systemImage
            )
            .font(.headline)
            .foregroundStyle(.blue)
            .frame(width: 26)
            .accessibilityHidden(true)


            VStack(
                alignment: .leading,
                spacing: 4
            ) {

                Text(title)
                    .font(.headline)


                Text(description)
                    .font(.caption)
                    .foregroundStyle(
                        .secondary
                    )
                    .fixedSize(
                        horizontal: false,
                        vertical: true
                    )
            }


            Spacer()


            Toggle(
                "",
                isOn: $isOn
            )
            .labelsHidden()
            .accessibilityLabel(title)
            .accessibilityHint(
                description
            )
        }
        .padding(.vertical, 4)
    }
}


// MARK: - Accessibility Status Row

// A read-only row showing whether a device-level accessibility setting
// (Reduce Motion, etc.) is currently on. Users adjust these in the
// iPhone's own Settings app; HopeLine just displays their status.
private struct AccessibilityStatusRow:
    View {

    let title: String

    let systemImage: String

    let enabled: Bool


    var body: some View {

        HStack(spacing: 12) {

            Image(
                systemName:
                    systemImage
            )
            .foregroundStyle(.blue)
            .frame(width: 24)
            .accessibilityHidden(true)


            Text(title)


            Spacer()


            Label(
                enabled
                    ? "On"
                    : "Off",
                systemImage:
                    enabled
                    ? "checkmark.circle.fill"
                    : "circle"
            )
            .font(.caption)
            .foregroundStyle(
                enabled
                    ? .green
                    : .secondary
            )
        }
        .accessibilityElement(
            children: .combine
        )
        .accessibilityLabel(
            "\(title), \(enabled ? "On" : "Off")"
        )
    }
}


// MARK: - Scripture Settings

// Scripture preferences: the personalization toggles that will control
// how Daily Scripture connects with the user's journey once those
// features ship, plus a link to saved Scriptures.
private struct ScriptureSettingsView:
    View {

    @Binding
    var personalizedScriptureEnabled:
        Bool

    @Binding
    var checkInScriptureEnabled:
        Bool


    var body: some View {

        Form {

            Section {

                Toggle(
                    "Personalized Scripture",
                    isOn:
                        $personalizedScriptureEnabled
                )


                Toggle(
                    "Use Daily Check-In",
                    isOn:
                        $checkInScriptureEnabled
                )

            } header: {

                Text(
                    "Personalization"
                )

            } footer: {

                Text(
                    """
                    These preferences will control how Daily Scripture connects with your recovery journey as personalization features are added.
                    """
                )
            }


            Section(
                "Saved Scriptures"
            ) {

                NavigationLink {

                    SavedScripturesListView()

                } label: {

                    Label(
                        "View Saved Scriptures",
                        systemImage:
                            "bookmark.fill"
                    )
                }
            }
        }
        .navigationTitle(
            "Scripture Settings"
        )
        .navigationBarTitleDisplayMode(
            .inline
        )
    }
}


// MARK: - Account Placeholder

// Temporary screen for Account management until that feature is built.
private struct AccountPlaceholderView:
    View {

    var body: some View {

        ContentUnavailableView(
            "Account Settings",
            systemImage:
                "person.crop.circle",
            description:
                Text(
                    "Account management options will be added here."
                )
        )
        .navigationTitle("Account")
    }
}


// MARK: - Recovery Preferences

// Temporary screen for recovery personalization until that feature is built.
private struct RecoveryPreferencesView:
    View {

    var body: some View {

        ContentUnavailableView(
            "Recovery Preferences",
            systemImage:
                "heart.fill",
            description:
                Text(
                    "Recovery personalization options will be added here."
                )
        )
        .navigationTitle(
            "Recovery Preferences"
        )
    }
}


// MARK: - Privacy

// Temporary screen for privacy options until that feature is built.
private struct PrivacySettingsView:
    View {

    var body: some View {

        ContentUnavailableView(
            "Privacy",
            systemImage:
                "lock.shield.fill",
            description:
                Text(
                    "HopeLine privacy settings and information will appear here."
                )
        )
        .navigationTitle("Privacy")
    }
}


// MARK: - My Data

// Shows live counts of the personal data HopeLine stores for the
// signed-in user, pulled from each feature's service.
private struct MyDataView: View {

    // MARK: - State

    // Live counts for each category. nil means the count is
    // still loading (or failed), and the row shows a dash.
    @State private var journalCount: Int?
    @State private var savedScriptureCount: Int?
    @State private var checkInCount: Int?
    @State private var prayerCount: Int?

    // MARK: - Services

    // Most services are singletons with private initializers.
    // MoodService is a plain service class, so it is created
    // directly, the same way the check-in screen does.
    private let journalService = JournalService.shared
    private let scriptureService = ScriptureService.shared
    private let prayerService = PrayerService.shared
    private let moodService = MoodService()

    var body: some View {

        List {

            MyDataRow(
                icon: "book.closed.fill",
                iconColor: .blue,
                title: "Journal Entries",
                count: journalCount
            )

            MyDataRow(
                icon: "bookmark.fill",
                iconColor: .orange,
                title: "Saved Scriptures",
                count: savedScriptureCount
            )

            MyDataRow(
                icon: "heart.text.square.fill",
                iconColor: .pink,
                title: "Daily Check-Ins",
                count: checkInCount
            )

            MyDataRow(
                icon: "hands.sparkles.fill",
                iconColor: .green,
                title: "Prayers Shared",
                count: prayerCount
            )
        }
        .navigationTitle(
            "My Data"
        )
        .task {
            await loadCounts()
        }
    }

    // MARK: - Load Counts

    // Loads each category independently so one failure never
    // hides the others. A count that fails to load simply
    // keeps its dash.

    private func loadCounts() async {

        journalCount =
            try? await journalService
                .fetchEntries()
                .count

        savedScriptureCount =
            try? await scriptureService
                .fetchSavedScriptures()
                .count

        checkInCount =
            try? await moodService
                .fetchCheckInCount()

        prayerCount =
            try? await prayerService
                .fetchMyPrayers()
                .count
    }
}


// MARK: - My Data Row

// One count row in the My Data list: icon, title, and the
// live count (or a dash while loading).
private struct MyDataRow: View {

    let icon: String
    let iconColor: Color
    let title: String
    let count: Int?

    var body: some View {

        HStack {

            Image(
                systemName: icon
            )
            .foregroundStyle(iconColor)
            .frame(width: 28)

            Text(title)

            Spacer()

            Text(
                count.map(String.init) ?? "—"
            )
            .foregroundStyle(.secondary)
            .monospacedDigit()
        }
    }
}


// MARK: - Privacy Policy

// A plain-language summary of what HopeLine collects and how it
// is protected. Will grow into a full policy before release.
private struct PrivacyPolicyView: View {

    var body: some View {

        ScrollView {

            VStack(alignment: .leading, spacing: 16) {

                policySection(
                    icon: "person.crop.circle.fill",
                    title: "What HopeLine Collects",
                    text: "HopeLine stores your account email, journal entries, daily check-ins, prayer requests, and saved Scriptures. Everything is tied to your account and stays private to you."
                )

                policySection(
                    icon: "location.fill",
                    title: "About Your Location",
                    text: "Your location is used only to find recovery meetings near you. It is never stored on HopeLine's servers."
                )

                policySection(
                    icon: "lock.shield.fill",
                    title: "How Your Data Is Protected",
                    text: "Your data lives in a secure database where each account can only read and write its own information. This rule is enforced by the database itself, not just the app, and data is encrypted in transit."
                )

                policySection(
                    icon: "hand.raised.fill",
                    title: "What HopeLine Never Does",
                    text: "HopeLine does not sell your data, share it with advertisers, or send your journal entries or personal information to outside companies."
                )
            }
            .padding()
        }
        .navigationTitle(
            "Privacy Policy"
        )
        .navigationBarTitleDisplayMode(
            .inline
        )
    }

    // MARK: - Policy Section

    // One titled card in the policy.
    private func policySection(
        icon: String,
        title: String,
        text: String
    ) -> some View {

        VStack(alignment: .leading, spacing: 10) {

            Label(
                title,
                systemImage: icon
            )
            .font(.headline)

            Text(text)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .padding()
        .background(
            Color(.secondarySystemBackground)
        )
        .clipShape(
            RoundedRectangle(cornerRadius: 16)
        )
    }
}


// MARK: - Terms & Resources

// Basic terms of use plus quick recovery resources.
private struct TermsResourcesView: View {

    var body: some View {

        ScrollView {

            VStack(alignment: .leading, spacing: 16) {

                termsSection(
                    icon: "doc.text.fill",
                    title: "Using HopeLine",
                    text: "HopeLine is a recovery support tool offered as-is for personal use. It does not provide medical, clinical, or professional advice."
                )

                termsSection(
                    icon: "exclamationmark.triangle.fill",
                    title: "Meeting Information",
                    text: "Meeting details come from public meeting-guide data and can change. Please confirm times and locations with the local meeting before attending."
                )

                termsSection(
                    icon: "heart.fill",
                    title: "In a Crisis?",
                    text: "HopeLine is not a crisis service. If you or someone you know is in crisis, call or text 988 (Suicide & Crisis Lifeline) right away."
                )

                // MARK: Quick Resources

                VStack(alignment: .leading, spacing: 12) {

                    Label(
                        "Quick Resources",
                        systemImage:
                            "lifepreserver.fill"
                    )
                    .font(.headline)

                    Text(
                        "988 Suicide & Crisis Lifeline — call or text 988"
                    )
                    .font(.subheadline)

                    Text(
                        "SAMHSA National Helpline — 1-800-662-4357"
                    )
                    .font(.subheadline)

                    Link(
                        "Narcotics Anonymous — na.org",
                        destination: URL(
                            string: "https://www.na.org"
                        )!
                    )
                    .font(.subheadline)
                }
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
                .padding()
                .background(
                    Color(.secondarySystemBackground)
                )
                .clipShape(
                    RoundedRectangle(cornerRadius: 16)
                )
            }
            .padding()
        }
        .navigationTitle(
            "Terms & Resources"
        )
        .navigationBarTitleDisplayMode(
            .inline
        )
    }

    // MARK: - Terms Section

    // One titled card in the terms.
    private func termsSection(
        icon: String,
        title: String,
        text: String
    ) -> some View {

        VStack(alignment: .leading, spacing: 10) {

            Label(
                title,
                systemImage: icon
            )
            .font(.headline)

            Text(text)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .padding()
        .background(
            Color(.secondarySystemBackground)
        )
        .clipShape(
            RoundedRectangle(cornerRadius: 16)
        )
    }
}


// MARK: - Saved Scriptures List

// The user's saved Scripture collection, loaded live from the
// saved_scriptures table. Each verse can be reflected on in the
// Journal or removed from the collection.
private struct SavedScripturesListView:
    View {

    // MARK: - State

    // The user's saved verses, newest first.
    @State private var scriptures: [SavedScripture] = []

    @State private var isLoading = true

    @State private var errorMessage: String?

    // The verse being reflected on, while the
    // Journal sheet is open.
    @State private var scriptureToReflect: SavedScripture?

    // Shown when removing a verse fails.
    @State private var showingRemoveError = false

    @State private var removeErrorMessage: String?

    // MARK: - Services

    // Uses the shared service instance — ScriptureService
    // has a private initializer (singleton pattern).
    private let scriptureService = ScriptureService.shared

    // MARK: - Body

    var body: some View {

        Group {

            if isLoading {

                loadingView

            } else if let errorMessage {

                errorView(message: errorMessage)

            } else if scriptures.isEmpty {

                emptyView

            } else {

                scripturesList
            }
        }
        .navigationTitle(
            "Saved Scriptures"
        )
        .navigationBarTitleDisplayMode(
            .inline
        )
        .task {
            await loadScriptures()
        }
        .refreshable {
            await loadScriptures()
        }
        .sheet(
            item: $scriptureToReflect
        ) { scripture in

            ScriptureReflectionView(
                verseReference:
                    scripture.verseReference,
                verseText:
                    scripture.verseText
            )
        }
        .alert(
            "Unable to Remove Scripture",
            isPresented: $showingRemoveError
        ) {

            Button(
                "OK",
                role: .cancel
            ) { }

        } message: {

            Text(
                removeErrorMessage ??
                    "Something went wrong while removing the Scripture."
            )
        }
    }

    // MARK: - Load Scriptures

    // Fetches the user's saved verses. RLS on the table
    // guarantees only the signed-in user's verses return.
    @MainActor
    private func loadScriptures() async {

        isLoading = true
        errorMessage = nil

        do {

            scriptures =
                try await scriptureService
                    .fetchSavedScriptures()

        } catch {

            errorMessage =
                error.localizedDescription
        }

        isLoading = false
    }

    // MARK: - Remove Scripture

    // Removes one verse from the collection, then updates
    // the list immediately.
    @MainActor
    private func removeScripture(
        _ scripture: SavedScripture
    ) async {

        do {

            try await scriptureService
                .removeSavedScripture(
                    reference:
                        scripture.verseReference
                )

            scriptures.removeAll {
                $0.id == scripture.id
            }

        } catch {

            removeErrorMessage =
                error.localizedDescription

            showingRemoveError = true
        }
    }

    // MARK: - List

    // The saved verses as cards, newest first, with
    // swipe-to-delete support.
    private var scripturesList: some View {

        List {

            ForEach(scriptures) { scripture in

                SavedScriptureCard(
                    scripture: scripture,
                    onReflect: {

                        scriptureToReflect = scripture

                    },
                    onRemove: {

                        Task {
                            await removeScripture(
                                scripture
                            )
                        }
                    }
                )
                .listRowInsets(
                    EdgeInsets(
                        top: 6,
                        leading: 16,
                        bottom: 6,
                        trailing: 16
                    )
                )
                .listRowSeparator(
                    .hidden
                )
                .listRowBackground(
                    Color.clear
                )
            }
            .onDelete { offsets in

                // Capture the verses before any removal
                // changes the array the offsets point into.
                let removed =
                    offsets.map {
                        scriptures[$0]
                    }

                Task {
                    for scripture in removed {
                        await removeScripture(
                            scripture
                        )
                    }
                }
            }
        }
        .listStyle(
            .plain
        )
        .scrollContentBackground(
            .hidden
        )
    }

    // MARK: - Loading View

    // Shown while the saved verses load.
    private var loadingView: some View {

        HStack(spacing: 12) {

            ProgressView()

            Text("Loading your saved Scriptures...")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 36)
    }

    // MARK: - Error View

    // Shown when the collection can't be loaded,
    // with a retry button.
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

            Text("Unable to Load Saved Scriptures")
                .font(.headline)

            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button("Try Again") {

                Task {
                    await loadScriptures()
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

    // MARK: - Empty View

    // Friendly empty state for users who haven't
    // saved any verses yet.
    private var emptyView: some View {

        VStack(spacing: 14) {

            Text("🔖")
                .font(.system(size: 44))

            Text("No Saved Scriptures Yet")
                .font(.headline)

            Text(
                "Save a Scripture from the Daily Scripture screen and it will appear here."
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


// MARK: - Saved Scripture Card

// One saved verse: the text, its reference, the date it was
// saved, and Reflect / Unsave actions.
private struct SavedScriptureCard: View {

    let scripture: SavedScripture

    let onReflect: () -> Void

    let onRemove: () -> Void

    var body: some View {

        VStack(alignment: .leading, spacing: 12) {

            // MARK: Verse

            Text(scripture.verseText)
                .font(.body)
                .foregroundStyle(.primary)
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )

            // MARK: Reference

            Text(scripture.verseReference)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.blue)

            // MARK: Date Saved

            if let savedDate =
                scripture.createdAt {

                Label(
                    savedDate.formatted(
                        date: .abbreviated,
                        time: .omitted
                    ),
                    systemImage: "bookmark.fill"
                )
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            Divider()

            // MARK: Actions

            HStack {

                Button {
                    onReflect()
                } label: {
                    Label(
                        "Reflect",
                        systemImage:
                            "square.and.pencil"
                    )
                }
                .buttonStyle(.bordered)

                Spacer()

                Button(
                    role: .destructive
                ) {
                    onRemove()
                } label: {
                    Label(
                        "Unsave",
                        systemImage:
                            "bookmark.slash"
                    )
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
        .background(
            Color(.secondarySystemBackground)
        )
        .clipShape(
            RoundedRectangle(cornerRadius: 16)
        )
    }
}



// MARK: - About HopeLine

// App information: purpose, project background, and acknowledgments.
private struct AboutHopeLineView:
    View {

    var body: some View {

        ScrollView {

            VStack(
                alignment: .leading,
                spacing: 20
            ) {

                VStack(
                    alignment: .leading,
                    spacing: 8
                ) {

                    Text("HopeLine")
                        .font(.largeTitle)
                        .fontWeight(.bold)


                    Text(
                        "Support When It Matters Most"
                    )
                    .font(.headline)
                    .foregroundStyle(.blue)
                }


                Text(
                    """
                    HopeLine is a recovery-support application designed to provide practical tools, reflection, encouragement, Scripture, prayer, and connection when support matters most.
                    """
                )
                .font(.body)
                .lineSpacing(4)


                Divider()


                VStack(
                    alignment: .leading,
                    spacing: 8
                ) {

                    Text(
                        "About the Project"
                    )
                    .font(.headline)


                    Text(
                        """
                        HopeLine was created as a Full Sail University software development capstone project.
                        """
                    )
                    .font(.subheadline)
                    .foregroundStyle(
                        .secondary
                    )
                }
            }
            .padding()
        }
        .navigationTitle(
            "About HopeLine"
        )
        .navigationBarTitleDisplayMode(
            .inline
        )
    }
}


// MARK: - Preview

#Preview {

    NavigationStack {

        SettingsView()
            .environmentObject(
                AuthManager()
            )
    }
}
