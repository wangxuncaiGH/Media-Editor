//
//  ImageProjectToolScrollView.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 21/01/2024.
//

import Combine
import SwiftUI

struct ImageProjectToolScrollView: View {
    @EnvironmentObject var vm: ImageProjectViewModel

    var body: some View {
        ZStack(alignment: .topLeading) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    if vm.activeLayer == nil {
                        ForEach(ProjectToolType.allCases) { tool in
                            Button(action: {
                                vm.currentTool = tool
                            }, label: {
                                ImageProjectToolTileView(title: tool.name,
                                                         iconName: tool.icon)

                            })
                        }
                    } else {
                        Group {
                            if vm.activeLayer is TextLayerModel {
                                Button(action: {
                                    vm.currentTool = LayerToolType.editText
                                }, label: {
                                    ImageProjectToolTileView(title: LayerToolType.editText.name,
                                                             iconName: LayerToolType.editText.icon)
                                })
                            }
                            ForEach(LayerToolType.allCases.filter { $0 != .editText }) { tool in
                                Button(action: {
                                    vm.currentTool = tool
                                }, label: {
                                    ImageProjectToolTileView(title: tool.name,
                                                             iconName: tool.icon)

                                })
                            }
                            ForEach(LayerSingleActionToolType.allCases) { tool in
                                Button(action: {
                                    vm.performToolActionSubject.send(tool)
                                }, label: {
                                    ImageProjectToolTileView(title: tool.name,
                                                             iconName: tool.icon)
                                })
                            }
                        }
                        .transition(.normalOpacityTransition)
                    }
                }
            }
            .onReceive(vm.performToolActionSubject) { [unowned vm] tool in
                if let tool = tool as? LayerSingleActionToolType {
                    if tool == .copy {
                        Task {
                            await vm.copyAndAppend()
                        }
                    }
                }
            }
            .padding(.horizontal, vm.tools.paddingFactor * vm.plane.lowerToolbarHeight)
            .frame(height: vm.plane.lowerToolbarHeight)
            .background(Color(.image))
        }
    }
}
