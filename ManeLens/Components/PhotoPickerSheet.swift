import SwiftUI
import PhotosUI

struct PhotoPickerSheet: View {
    @Binding var isPresented: Bool
    let onSelect: (UIImage) -> Void

    @State private var selectedItem: PhotosPickerItem?
    @State private var showCamera = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 8) {
                    PhotosPicker(selection: $selectedItem, matching: .images) {
                        SourceRow(
                            icon: "photo.on.rectangle",
                            title: "Choose from Library",
                            subtitle: "Pick from Photos"
                        )
                    }
                    .buttonStyle(.plain)

                    SourceRow(
                        icon: "camera.fill",
                        title: "Take Photo",
                        subtitle: "Use your camera"
                    ) {
                        showCamera = true
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 30)
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("Add a photo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { isPresented = false }
                        .foregroundStyle(Color.hairPurple)
                }
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
        .onChange(of: selectedItem) { _, item in
            guard let item else { return }
            Task {
                if let data = try? await item.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    await MainActor.run {
                        onSelect(image)
                        isPresented = false
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $showCamera) {
            CameraPickerView { image in
                onSelect(image)
                showCamera = false
                isPresented = false
            }
            .ignoresSafeArea()
        }
    }
}

private struct CameraPickerView: UIViewControllerRepresentable {
    let onCapture: (UIImage) -> Void

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.cameraDevice = .front
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(onCapture: onCapture) }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let onCapture: (UIImage) -> Void
        init(onCapture: @escaping (UIImage) -> Void) { self.onCapture = onCapture }

        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage { onCapture(image) }
        }
    }
}

private struct SourceRow: View {
    let icon: String
    let title: String
    let subtitle: String
    var action: (() -> Void)? = nil

    var body: some View {
        let content = HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.hairPurpleAlpha)
                    .frame(width: 42, height: 42)
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundStyle(Color.hairPurple)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.hairText)
                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundStyle(Color.hairTextSec)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.hairTextSec)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))

        if let action {
            Button(action: action) { content }
                .buttonStyle(.plain)
        } else {
            content
        }
    }
}
