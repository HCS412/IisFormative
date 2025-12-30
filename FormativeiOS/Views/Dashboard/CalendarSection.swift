//
//  CalendarSection.swift
//  FormativeiOS
//
//  Calendar Section with Week Strip and Upcoming Deadlines
//

import SwiftUI

struct CalendarSection: View {
    let deadlines: [CalendarDeadline]
    let calendlyUrl: String?
    let onDeadlineTap: (CalendarDeadline) -> Void

    @State private var selectedDate = Date()

    var body: some View {
        VStack(alignment: .leading, spacing: .spacingM) {
            // Header
            HStack {
                HStack(spacing: .spacingS) {
                    Image(systemName: "calendar")
                        .font(.subheadline)
                        .foregroundStyle(LinearGradient.brand)

                    Text("Your Schedule")
                        .font(.headline)
                        .foregroundColor(.adaptiveTextPrimary())
                }

                Spacer()

                // Month/Year label
                Text(selectedDate.formatted(.dateTime.month(.wide).year()))
                    .font(.subheadline)
                    .foregroundColor(.textSecondary)
            }
            .padding(.horizontal, .spacingL)

            // Week strip
            WeekStripView(
                selectedDate: $selectedDate,
                deadlineDates: Set(deadlines.map { Calendar.current.startOfDay(for: $0.date) })
            )
            .padding(.horizontal, .spacingL)

            // Upcoming deadlines
            if !deadlines.isEmpty {
                VStack(alignment: .leading, spacing: .spacingS) {
                    Text("Upcoming")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.textSecondary)
                        .padding(.horizontal, .spacingL)

                    VStack(spacing: .spacingS) {
                        ForEach(deadlines.prefix(3)) { deadline in
                            DeadlineRow(deadline: deadline)
                                .onTapGesture {
                                    Haptics.selection()
                                    onDeadlineTap(deadline)
                                }
                        }
                    }
                    .padding(.horizontal, .spacingL)
                }
            } else {
                // Empty state
                HStack {
                    Spacer()
                    VStack(spacing: .spacingS) {
                        Image(systemName: "calendar.badge.checkmark")
                            .font(.title2)
                            .foregroundColor(.textSecondary.opacity(0.5))
                        Text("No upcoming deadlines")
                            .font(.caption)
                            .foregroundColor(.textSecondary)
                    }
                    .padding(.spacingL)
                    Spacer()
                }
            }

            // Calendly button
            if let url = calendlyUrl, !url.isEmpty {
                CalendlyButton(url: url)
                    .padding(.horizontal, .spacingL)
                    .padding(.top, .spacingS)
            }
        }
    }
}

// MARK: - Week Strip View
struct WeekStripView: View {
    @Binding var selectedDate: Date
    let deadlineDates: Set<Date>

    private let calendar = Calendar.current
    private let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter
    }()

    private var weekDays: [Date] {
        let today = Date()
        let weekday = calendar.component(.weekday, from: today)
        let startOfWeek = calendar.date(byAdding: .day, value: -(weekday - 1), to: today)!

        return (0..<7).compactMap { offset in
            calendar.date(byAdding: .day, value: offset, to: startOfWeek)
        }
    }

    var body: some View {
        HStack(spacing: 0) {
            ForEach(weekDays, id: \.self) { date in
                DayCell(
                    date: date,
                    isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                    isToday: calendar.isDateInToday(date),
                    hasDeadline: deadlineDates.contains(calendar.startOfDay(for: date))
                )
                .onTapGesture {
                    withAnimation(.springSmooth) {
                        selectedDate = date
                    }
                    Haptics.selection()
                }

                if date != weekDays.last {
                    Spacer(minLength: 0)
                }
            }
        }
        .padding(.spacingM)
        .background(
            RoundedRectangle(cornerRadius: .radiusMedium)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: .radiusMedium)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - Day Cell
struct DayCell: View {
    let date: Date
    let isSelected: Bool
    let isToday: Bool
    let hasDeadline: Bool

    private let calendar = Calendar.current

    var body: some View {
        VStack(spacing: 4) {
            // Day name
            Text(dayName)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(isSelected ? .white : .textSecondary)

            // Day number
            ZStack {
                if isSelected {
                    Circle()
                        .fill(LinearGradient.brand)
                        .frame(width: 32, height: 32)
                } else if isToday {
                    Circle()
                        .stroke(Color.brandPrimary, lineWidth: 2)
                        .frame(width: 32, height: 32)
                }

                Text("\(calendar.component(.day, from: date))")
                    .font(.system(size: 14, weight: isToday || isSelected ? .bold : .medium))
                    .foregroundColor(isSelected ? .white : (isToday ? .brandPrimary : .adaptiveTextPrimary()))
            }

            // Deadline indicator
            Circle()
                .fill(hasDeadline ? Color.warning : Color.clear)
                .frame(width: 4, height: 4)
        }
        .frame(width: 40)
    }

    private var dayName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date).prefix(1).uppercased()
    }
}

// MARK: - Deadline Row
struct DeadlineRow: View {
    let deadline: CalendarDeadline

    var body: some View {
        HStack(spacing: .spacingM) {
            // Icon
            Image(systemName: deadline.type.icon)
                .font(.subheadline)
                .foregroundColor(deadline.type.color)
                .frame(width: 28, height: 28)
                .background(deadline.type.color.opacity(0.1))
                .cornerRadius(6)

            // Content
            VStack(alignment: .leading, spacing: 2) {
                Text(deadline.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.adaptiveTextPrimary())
                    .lineLimit(1)

                Text(formatDeadlineDate(deadline.date))
                    .font(.caption)
                    .foregroundColor(.textSecondary)
            }

            Spacer()

            // Days remaining
            Text(daysRemaining(deadline.date))
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(daysRemainingColor(deadline.date))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(daysRemainingColor(deadline.date).opacity(0.1))
                .cornerRadius(4)
        }
        .padding(.spacingM)
        .background(
            RoundedRectangle(cornerRadius: .radiusSmall)
                .fill(Color.adaptiveSurface())
        )
    }

    private func formatDeadlineDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: date)
    }

    private func daysRemaining(_ date: Date) -> String {
        let days = Calendar.current.dateComponents([.day], from: Date(), to: date).day ?? 0
        if days == 0 {
            return "Today"
        } else if days == 1 {
            return "1 day"
        } else {
            return "\(days) days"
        }
    }

    private func daysRemainingColor(_ date: Date) -> Color {
        let days = Calendar.current.dateComponents([.day], from: Date(), to: date).day ?? 0
        if days <= 2 {
            return .error
        } else if days <= 7 {
            return .warning
        } else {
            return .success
        }
    }
}

// MARK: - Calendly Button
struct CalendlyButton: View {
    let url: String

    var body: some View {
        Button(action: openCalendly) {
            HStack(spacing: .spacingS) {
                Image(systemName: "calendar.badge.plus")
                    .font(.subheadline)

                Text("Open Calendly")
                    .font(.subheadline)
                    .fontWeight(.medium)

                Spacer()

                Image(systemName: "arrow.up.right")
                    .font(.caption)
            }
            .foregroundColor(.brandPrimary)
            .padding(.spacingM)
            .background(
                RoundedRectangle(cornerRadius: .radiusSmall)
                    .fill(Color.brandPrimary.opacity(0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: .radiusSmall)
                    .stroke(Color.brandPrimary.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(ScaleButtonStyle(scale: 0.98))
    }

    private func openCalendly() {
        Haptics.impact(.light)
        guard let calendlyURL = URL(string: url) else { return }
        UIApplication.shared.open(calendlyURL)
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 24) {
            CalendarSection(
                deadlines: [
                    CalendarDeadline(
                        id: 1,
                        title: "Summer Campaign Application",
                        date: Calendar.current.date(byAdding: .day, value: 2, to: Date())!,
                        type: .opportunityDeadline,
                        opportunityId: 1
                    ),
                    CalendarDeadline(
                        id: 2,
                        title: "Brand Partnership Review",
                        date: Calendar.current.date(byAdding: .day, value: 5, to: Date())!,
                        type: .applicationDeadline,
                        opportunityId: 2
                    ),
                    CalendarDeadline(
                        id: 3,
                        title: "Content Delivery",
                        date: Calendar.current.date(byAdding: .day, value: 10, to: Date())!,
                        type: .campaignMilestone,
                        opportunityId: nil
                    )
                ],
                calendlyUrl: "https://calendly.com/username",
                onDeadlineTap: { _ in }
            )
        }
        .padding(.vertical)
    }
    .background(Color.adaptiveBackground())
}
