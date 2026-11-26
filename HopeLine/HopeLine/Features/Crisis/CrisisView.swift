//
//  CrisisView.swift
//  HopeLine
//
//  Created by StalkyTwig1987 on 11/25/26.
//

import SwiftUI

// The crisis support screen behind the I Need Help button.
// Offers dial-ready national hotlines, a shortcut to the
// meeting finder, and grounding content for hard moments.
struct CrisisView: View {

    // Opens phone and message links.
    @Environment(\.openURL) private var openURL

    // MARK: - Body

    var body: some View {

        ScrollView {

            VStack(alignment: .leading, spacing: 20) {

                // MARK: Header

                VStack(alignment: .leading, spacing: 8) {

                    Text("You Are Not Alone")
                        .font(.title)
                        .fontWeight(.bold)

                    Text(
                        "If you are in crisis right now, reach out. Help is available at any hour, and reaching out is a sign of strength."
                    )
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                }

                // MARK: Immediate Help

                VStack(alignment: .leading, spacing: 16) {

                    Label(
                        "Immediate Help",
                        systemImage:
                            "phone.fill"
                    )
                    .font(.headline)

                    hotlineRow(
                        name: "988 Suicide & Crisis Lifeline",
                        detail: "Call or text 988 — free, 24/7",
                        icon: "heart.fill",
                        iconColor: .red,
                        url: URL(
                            string: "tel:988"
                        )!
                    )

                    hotlineRow(
                        name: "Crisis Text Line",
                        detail: "Text HOME to 741741",
                        icon: "message.fill",
                        iconColor: .blue,
                        url: URL(
                            string: "sms:741741&body=HOME"
                        )!
                    )

                    hotlineRow(
                        name: "SAMHSA National Helpline",
                        detail: "1-800-662-4357 — treatment referral, 24/7",
                        icon: "cross.case.fill",
                        iconColor: .green,
                        url: URL(
                            string: "tel:18006624357"
                        )!
                    )
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

                // MARK: Find a Meeting

                VStack(alignment: .leading, spacing: 12) {

                    Label(
                        "Find a Meeting Now",
                        systemImage:
                            "person.3.fill"
                    )
                    .font(.headline)

                    Text(
                        "Being around people who understand can make a difference. Search recovery meetings near you."
                    )
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                    NavigationLink {

                        MeetingsView()

                    } label: {

                        Label(
                            "Open the Meeting Finder",
                            systemImage:
                                "magnifyingglass"
                        )
                        .frame(
                            maxWidth: .infinity
                        )
                    }
                    .buttonStyle(
                        .borderedProminent
                    )
                    .controlSize(.large)
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

                // MARK: Grounding

                VStack(alignment: .leading, spacing: 12) {

                    Label(
                        "Ground Yourself",
                        systemImage:
                            "leaf.fill"
                    )
                    .font(.headline)

                    Text(
                        "When everything feels like too much, grounding can bring you back to this moment. Look around and name:"
                    )
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                    VStack(alignment: .leading, spacing: 8) {

                        groundingStep(
                            number: "5",
                            text: "things you can see"
                        )

                        groundingStep(
                            number: "4",
                            text: "things you can touch"
                        )

                        groundingStep(
                            number: "3",
                            text: "things you can hear"
                        )

                        groundingStep(
                            number: "2",
                            text: "things you can smell"
                        )

                        groundingStep(
                            number: "1",
                            text: "thing you can taste"
                        )
                    }
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

                // MARK: Encouragement

                VStack(alignment: .leading, spacing: 12) {

                    Label(
                        "One Moment at a Time",
                        systemImage:
                            "tortoise.fill"
                    )
                    .font(.headline)

                    Text(
                        "You don't have to get through everything right now. You only have to get through this moment. Breathe. You have done hard things before, and you don't have to do them alone."
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
            }
            .padding()
        }
        .navigationTitle(
            "I Need Help"
        )
        .navigationBarTitleDisplayMode(
            .inline
        )
    }

    // MARK: - Hotline Row

    // One tappable hotline row. Tapping opens the
    // phone or messages app ready to connect.
    private func hotlineRow(
        name: String,
        detail: String,
        icon: String,
        iconColor: Color,
        url: URL
    ) -> some View {

        Button {

            openURL(url)

        } label: {

            HStack(spacing: 14) {

                Image(
                    systemName: icon
                )
                .foregroundStyle(iconColor)
                .frame(width: 28)

                VStack(
                    alignment: .leading,
                    spacing: 2
                ) {

                    Text(name)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)

                    Text(detail)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(
                    systemName:
                        "arrow.up.right"
                )
                .font(.caption)
                .foregroundStyle(.tertiary)
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Grounding Step

    // One numbered line of the 5-4-3-2-1 technique.
    private func groundingStep(
        number: String,
        text: String
    ) -> some View {

        HStack(spacing: 10) {

            Text(number)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundStyle(.blue)
                .frame(width: 22)

            Text(text)
                .font(.subheadline)
        }
    }
}
