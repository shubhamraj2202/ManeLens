import SwiftUI

struct AddTimelineEntryView: View {
    var profile: PersonProfile
    var onSave: (UIImage, Date, String, String?) -> Void
    var onCancel: () -> Void

    @State private var selectedPhoto: UIImage? = nil
    @State private var entryDate: Date = .now
    @State private var note: String = ""
    @State private var showPicker = false
    @State private var showDatePicker = false

    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .long
        return f
    }()

    var body: some View {
        VStack(spacing: 0) {
            // Handle
            RoundedRectangle(cornerRadius: 99)
                .fill(Color.hairBorder)
                .frame(width: 36, height: 4)
                .padding(.top, 10)
                .padding(.bottom, 14)

            HStack {
                Text("New Entry")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(Color.hairText)
                Spacer()
                Button("Cancel", action: onCancel)
                    .font(.system(size: 15))
                    .foregroundStyle(Color.hairPurple)
            }
            .padding(.horizontal, DS.paddingPage)
            .padding(.bottom, 14)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 12) {
                    // Photo zone
                    if let photo = selectedPhoto {
                        ZStack(alignment: .topTrailing) {
                            Image(uiImage: photo)
                                .resizable()
                                .scaledToFill()
                                .frame(maxWidth: .infinity)
                                .frame(height: 200)
                                .clipped()
                                .clipShape(RoundedRectangle(cornerRadius: DS.radiusCard))

                            Button { selectedPhoto = nil } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 24))
                                    .foregroundStyle(.white.opacity(0.9))
                                    .shadow(radius: 4)
                            }
                            .padding(10)
                        }
                        .onTapGesture { showPicker = true }
                    } else {
                        Button { showPicker = true } label: {
                            VStack(spacing: 12) {
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 28))
                                    .foregroundStyle(Color.hairPurple)
                                Text("Tap to add photo")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundStyle(Color.hairTextSec)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 160)
                            .background(Color.hairBg)
                            .clipShape(RoundedRectangle(cornerRadius: DS.radiusCard))
                            .overlay(
                                RoundedRectangle(cornerRadius: DS.radiusCard)
                                    .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [6]))
                                    .foregroundStyle(Color.hairPurple.opacity(0.3))
                            )
                        }
                    }

                    // Date + note card
                    VStack(spacing: 0) {
                        // Date row
                        Button {
                            showDatePicker.toggle()
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: "calendar")
                                    .font(.system(size: 16))
                                    .foregroundStyle(Color.hairPurple)
                                Text(dateFormatter.string(from: entryDate))
                                    .font(.system(size: 15))
                                    .foregroundStyle(Color.hairText)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundStyle(Color.hairTextSec)
                            }
                            .padding(.horizontal, DS.paddingPage)
                            .padding(.vertical, 13)
                        }

                        if showDatePicker {
                            DatePicker("", selection: $entryDate, displayedComponents: .date)
                                .datePickerStyle(.graphical)
                                .padding(.horizontal, 8)
                                .tint(Color.hairPurple)
                        }

                        Divider().padding(.horizontal, DS.paddingPage)

                        // Note field
                        ZStack(alignment: .topLeading) {
                            if note.isEmpty {
                                Text("What was done? e.g. trimmed 2 inches, balayage added")
                                    .font(.system(size: 14))
                                    .foregroundStyle(Color.hairTextSec)
                                    .padding(.horizontal, DS.paddingPage)
                                    .padding(.top, 13)
                            }
                            TextEditor(text: $note)
                                .font(.system(size: 14))
                                .foregroundStyle(Color.hairText)
                                .frame(minHeight: 80)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .scrollContentBackground(.hidden)
                        }
                    }
                    .background(Color.hairBg)
                    .clipShape(RoundedRectangle(cornerRadius: DS.radiusInput))
                    .overlay(RoundedRectangle(cornerRadius: DS.radiusInput).stroke(Color.hairBorder, lineWidth: 1))

                    PrimaryButton(
                        title: "Save Entry",
                        icon: "📅",
                        variant: .gradient,
                        disabled: selectedPhoto == nil
                    ) {
                        guard let photo = selectedPhoto else { return }
                        onSave(photo, entryDate, note.trimmingCharacters(in: .whitespaces), nil)
                    }
                }
                .padding(.horizontal, DS.paddingPage)
                .padding(.bottom, 40)
            }
        }
        .background(Color.hairBgOff)
        .sheet(isPresented: $showPicker) {
            PhotoPickerSheet(isPresented: $showPicker) { image in
                selectedPhoto = image
            }
        }
    }
}
