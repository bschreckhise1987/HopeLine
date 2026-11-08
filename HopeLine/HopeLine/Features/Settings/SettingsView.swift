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


                    Button {

                        // Privacy Policy
                        // connection comes later.

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


                    Button {

                        // Terms & Resources
                        // connection comes later.

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

private struct SettingsDivider: View {

    var body: some View {

        Divider()
            .padding(.leading, 50)
    }
}


// MARK: - Accessibility Settings

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

                    SavedScripturesPlaceholderView()

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

private struct MyDataView: View {

    var body: some View {

        List {

            Label(
                "Journal Entries",
                systemImage:
                    "book.closed.fill"
            )


            Label(
                "Saved Scriptures",
                systemImage:
                    "bookmark.fill"
            )


            Label(
                "Daily Check-Ins",
                systemImage:
                    "heart.text.square.fill"
            )


            Label(
                "Prayer Activity",
                systemImage:
                    "hands.sparkles.fill"
            )
        }
        .navigationTitle(
            "My Data"
        )
    }
}


// MARK: - Saved Scriptures Placeholder

private struct SavedScripturesPlaceholderView:
    View {

    var body: some View {

        ContentUnavailableView(
            "Saved Scriptures",
            systemImage:
                "bookmark.fill",
            description:
                Text(
                    "Your saved Scripture collection will appear here."
                )
        )
        .navigationTitle(
            "Saved Scriptures"
        )
    }
}


// MARK: - About HopeLine

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
