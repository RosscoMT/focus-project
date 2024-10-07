//
//  RenderPass.swift
//  
//
//  Created by Ross Viviani on 26/08/2024.
//

import MetalKit

class RenderPass {
    var descriptor: MTLRenderPassDescriptor
    var texture: MTLTexture
    var depthTexture: MTLTexture
    
    let name: String
    
    init(name: String, size: CGSize) {
        self.name = name
        texture = RenderPass.buildTexture(size: size, label: name,
                                          pixelFormat: .bgra8Unorm,
                                          usage: [.renderTarget, .shaderRead])
        depthTexture = RenderPass.buildTexture(size: size, label: name,
                                               pixelFormat: .depth32Float,
                                               usage: [.renderTarget, .shaderRead])
        descriptor = RenderPass.setupRenderPassDescriptor(texture: texture,
                                                          depthTexture: depthTexture)
    }
    
    func updateTextures(size: CGSize) {
        texture = RenderPass.buildTexture(size: size, label: name,
                                          pixelFormat: .bgra8Unorm,
                                          usage: [.renderTarget, .shaderRead])
        depthTexture = RenderPass.buildTexture(size: size, label: name,
                                               pixelFormat: .depth32Float,
                                               usage: [.renderTarget, .shaderRead])
        descriptor = RenderPass.setupRenderPassDescriptor(texture: texture,
                                                          depthTexture: depthTexture)
    }
    
    static func setupRenderPassDescriptor(texture: MTLTexture,
                                          depthTexture: MTLTexture) -> MTLRenderPassDescriptor {
        let descriptor = MTLRenderPassDescriptor()
        descriptor.setUpColorAttachment(position: 0, texture: texture)
        descriptor.setUpDepthAttachment(texture: depthTexture)
        return descriptor
    }
    
    static func buildTexture(
        size: CGSize,
        label: String,
        pixelFormat: MTLPixelFormat,
        usage: MTLTextureUsage
    ) -> MTLTexture {
        let descriptor = MTLTextureDescriptor.texture2DDescriptor(
            pixelFormat: pixelFormat,
            width: Int(size.width),
            height: Int(size.height),
            mipmapped: false
        )
        descriptor.sampleCount = 1
        descriptor.storageMode = .private
        descriptor.textureType = .type2D
        descriptor.usage = usage
        guard let texture = Renderer.device.makeTexture(descriptor: descriptor) else {
            fatalError("Texture not created")
        }
        texture.label = label
        return texture
    }
}

private extension MTLRenderPassDescriptor {
    func setUpDepthAttachment(texture: MTLTexture) {
        depthAttachment.texture = texture
        depthAttachment.loadAction = .clear
        depthAttachment.storeAction = .dontCare
        depthAttachment.clearDepth = 1
    }
    
    func setUpColorAttachment(position: Int, texture: MTLTexture) {
        let attachment: MTLRenderPassColorAttachmentDescriptor = colorAttachments[position]
        attachment.texture = texture
        attachment.loadAction = .clear
        attachment.storeAction = .store
        attachment.clearColor = MTLClearColorMake(0, 0, 0, 0)
    }
}
