//
//  DriveFolderPickerView.swift
//  CondoRented_Owner
//

import SwiftUI

struct DriveFolderPickerView: View {
    @Bindable var viewModel = DriveFolderPickerViewModel()
    var onSelect: (String, String) -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 4) {
                        ForEach(Array(viewModel.breadcrumb.enumerated()), id: \.offset) { index, level in
                            if index > 0 {
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Text(level.name)
                                .font(.caption)
                                .foregroundStyle(index == viewModel.breadcrumb.count - 1 ? .primary : .secondary)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 4)

                if viewModel.loading {
                    Spacer()
                    ProgressView()
                    Spacer()
                } else if let error = viewModel.error {
                    Spacer()
                    Text(error)
                        .foregroundStyle(.red)
                        .padding()
                    Button("Reintentar") {
                        Task { await viewModel.loadRoot() }
                    }
                    Spacer()
                } else if viewModel.folders.isEmpty {
                    Spacer()
                    Text("No hay subcarpetas")
                        .foregroundStyle(.secondary)
                    Spacer()
                } else {
                    List(viewModel.folders) { folder in
                        Button {
                            Task { await viewModel.navigateInto(folder: folder) }
                        } label: {
                            Label(folder.name, systemImage: "folder")
                        }
                    }
                }

                Button {
                    onSelect(viewModel.currentFolderId, viewModel.currentFolderName)
                    dismiss()
                } label: {
                    Text("Seleccionar esta carpeta")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .padding()
            }
            .navigationTitle("Google Drive")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    if viewModel.breadcrumb.count > 1 {
                        Button {
                            Task { await viewModel.navigateBack() }
                        } label: {
                            Image(systemName: "chevron.left")
                        }
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Cancelar") { dismiss() }
                }
            }
            .task {
                await viewModel.loadRoot()
            }
        }
    }
}
