//
//  AddProjectGridTileView.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 16/01/2024.
//

import Photos
import SwiftUI

struct AddProjectGridTileView: View {
    @State var thumbnail: UIImage?
    @EnvironmentObject var vm: AddProjectViewModel
    @State var isSelected: Bool = false
    @State var media: PHAsset

    var body: some View {
        ZStack {
            ZStack {
                Group {
                    if let thumbnail {
                        Image(uiImage: thumbnail)
                            .centerCropped()
                    } else {
                        Color(.image)
                    }
                }.aspectRatio(1.0, contentMode: .fill)
                    .cornerRadius(4.0)

            }.overlay {
                if isSelected {
                    ZStack(alignment: .topLeading) {
                        Color(.primary)
                            .opacity(isSelected ? 0.7 : 0)
                            .aspectRatio(1.0, contentMode: .fill)
                            .cornerRadius(4.0)
                        Circle()
                            .fill(Color(.primary))
                            .frame(width: 25, height: 25)
                            .padding(4.0)
                            .overlay {
                                Text("\((vm.selectedAssets.firstIndex(of: media) ?? 0) + 1)")
                            }
                    }
                }
            }
        }
        .contentShape(RoundedRectangle(cornerRadius: 4.0))
        .onAppear {
            if vm.selectedAssets.contains(where: { $0.localIdentifier == media.localIdentifier }) {
                isSelected = true
            }
        }
        .onTapGesture {
            HapticService.shared.play(.light)
            isSelected = vm.toggleMediaSelection(for: media)
        }
        .task {
            thumbnail = try? await vm.fetchPhoto(for: media, desiredSize:
                .init(width: UIScreen.main.nativeBounds.width *
                    (UIDevice.current.userInterfaceIdiom == .phone ? 0.33 : 0.2),
                    height: UIScreen.main.nativeBounds.width *
                        (UIDevice.current.userInterfaceIdiom == .phone ? 0.33 : 0.2)))

        }.onDisappear {
            thumbnail = nil
        }
    }
}
