//
//  PhotoLibraryService.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 08/01/2024.
//

import Foundation
import Photos
import UIKit

class PhotoLibraryService: ObservableObject {
    @Published var media: PHFetchResult<PHAsset> = .init()
    
    var imageCachingManager = PHCachingImageManager()
    
    func requestAuthorization() {
        PHPhotoLibrary.requestAuthorization { [unowned self] status in
            switch status {
            case .authorized, .limited:
                fetchAllMediaFromPhotoLibrary()
            default:
                print("Permission not granted")
            }
        }
    }
    
    func getMediaPublisher() -> Published<PHFetchResult<PHAsset>>.Publisher {
        return _media.projectedValue
    }

    func fetchAllMediaFromPhotoLibrary() {
        imageCachingManager.allowsCachingHighQualityImages = true
        let fetchOptions = PHFetchOptions()
        fetchOptions.includeHiddenAssets = false
        fetchOptions.predicate = NSPredicate(format: "mediaType == %d || mediaType == %d", PHAssetMediaType.image.rawValue, PHAssetMediaType.video.rawValue)
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        
        DispatchQueue.main.async { [unowned self] in
            media = PHAsset.fetchAssets(with: fetchOptions)
        }
    }
    
    func fetchThumbnail(for localIdentifier: String, desiredSize: CGSize, contentMode: PHImageContentMode = .default) async throws -> UIImage {
        
//        var desiredSize = [PHImageManagerMaximumSize, desiredSize].min()! 
        print(desiredSize)
        
        let asset: PHAsset? = PHAsset.fetchAssets(withLocalIdentifiers: [localIdentifier], options: nil).firstObject
        
        guard let asset else { throw PhotoError.invalidLocalIdentifier(localIdentifier: localIdentifier) }
        
        let requestOptions = PHImageRequestOptions()
        requestOptions.resizeMode = .fast
        requestOptions.isSynchronous = false
        requestOptions.isNetworkAccessAllowed = true
        requestOptions.deliveryMode = .highQualityFormat
        
        if asset.mediaType == .video || asset.mediaType == .image {
            let photo = try await withCheckedThrowingContinuation { continuation in
                imageCachingManager.requestImage(for: asset, targetSize: desiredSize, contentMode: contentMode, options: requestOptions) { image, _ in
                    if let image {
                        continuation.resume(returning: image)
                    } else {
                        continuation.resume(throwing: PhotoError.thumbnailError)
                    }
                }
            }
            return photo
        } else {
            throw PhotoError.invalidLocalIdentifier(localIdentifier: "lol")
        }
      
    }
    
    func getThumbnail(asset: PHAsset, targetSize: CGSize, completion: @escaping (UIImage?) -> Void) {}
}
