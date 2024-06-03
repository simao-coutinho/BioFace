//
//  File.swift
//
//
//  Created by Simao Coutinho on 14/05/2024.
//

import Foundation

public class IcaoOptions {
    
    public init() {}
    
    private var options : [Int] = []
    
    public enum Option: Int {
        case ICAO_EYES_OPENED = 1
        case ICAO_NEUTRAL_EXPRESSION = 2
        case ICAO_MOUTH_CLOSED = 3
        case ICAO_SOULDERS_ALIGNED = 4
        case ICAO_CORRECT_FACE_POSE = 5
        case ICAO_LOOKING_FORWARD = 6
        case ICAO_HAIR_NOT_COVERING_EYES = 7
        case ICAO_HEAD_WITHOUTH_COVERING = 8
        case ICAO_VEIL_NOT_OVER_FACE = 9
        case ICAO_ONLY_ONE_FACE = 10
        case ICAO_NO_SUNGLASSES = 11
        case ICAO_FRAMES_NOT_COVERING_EYES = 12
        case ICAO_NO_GLASSES_REFLECTION = 13
        case ICAO_FRAMES_NOT_TOO_HEAVY = 14
        case ICAO_NO_BACKGROUND_SHADOWS = 15
        case ICAO_NO_FACE_SHADOWS = 16
        case ICAO_NO_FLASH_REFLECTION = 17
        case ICAO_NATURAL_SKIN_TONE = 18
        case ICAO_NO_RED_EYES = 19
        case ICAO_LIGHTING_CONDITIONS_CORRECT = 20
        case ICAO_NO_BLURRED_IMAGE = 21
        case ICAO_HOMOGENEOUS_BACKGROUND = 22
        case ICAO_NO_PIXELATED_IMAGE = 23
        case ICAO_NO_WASHED_OUT_IMAGE = 24
        case ICAO_NO_INK_MARKED_CREASED_IMAGE = 25
    }
    
    
    public func addOption(option: Option) {
        options.append(option.rawValue)
    }
    
    public func getOptions() -> [Int] {
        return options
    }
    
    public func getRegistrationDefaults() -> [Int] {
        return [10, 21, 18, 11, 1, 6, 19, 3, 2, 5, 4]
    }
    
    public func getVerificationDefaults() -> [Int] {
        return [10, 11, 1, 6, 5]
    }
    
    public func getMessage(icaoOption: String) -> String {
        return switch icaoOption {
            case "ICAO_EYES_OPENED": "Tem de abrir os olhos"
            case "ICAO_NEUTRAL_EXPRESSION": "Tem de fazer uma pose neutra"
            case "ICAO_MOUTH_CLOSED": "Tem de fechar a boca"
            case "ICAO_SOULDERS_ALIGNED": "Tem de alinhar os ombros"
            case "ICAO_CORRECT_FACE_POSE": "Tem de fazer uma pose correta"
            case "ICAO_LOOKING_FORWARD": "Tem de olhar para a camera"
            case "ICAO_HAIR_NOT_COVERING_EYES": "Tem de retirar o cabelo dos olhos"
            case "ICAO_HEAD_WITHOUTH_COVERING": "Tem de retirar chapeu ou capucho"
            case "ICAO_VEIL_NOT_OVER_FACE": "Tem de retirar o veu"
            case "ICAO_ONLY_ONE_FACE": "Tem de apenas estar uma pessoa"
            case "ICAO_NO_SUNGLASSES": "Tem de retirar os óculos de sol"
            case "ICAO_FRAMES_NOT_COVERING_EYES": "Tem de retirar o que está a cobrir os olhos"
            case "ICAO_NO_GLASSES_REFLECTION": "Tem reflexo nos óculos"
            case "ICAO_FRAMES_NOT_TOO_HEAVY": "Imagem com qualidade fraca"
            case "ICAO_NO_BACKGROUND_SHADOWS": "Não pode haver sombras de fundo"
            case "ICAO_NO_FACE_SHADOWS": "Não pode haver sombras na cara"
            case "ICAO_NO_FLASH_REFLECTION": "Não pode haver reflexo do flash"
            case "ICAO_NATURAL_SKIN_TONE": "Tom de pele não é natural"
            case "ICAO_NO_RED_EYES": "Tem os olhos vermelhos repita por favor!"
            case "ICAO_LIGHTING_CONDITIONS_CORRECT": "Condição de luz não é adequada"
            case "ICAO_NO_BLURRED_IMAGE": "Imagem com qualidade fraca"
            case "ICAO_HOMOGENEOUS_BACKGROUND": "Tem de ter um fundo homogêneo"
            case "ICAO_NO_PIXELATED_IMAGE": "Imagem com qualidade fraca"
            case "ICAO_NO_WASHED_OUT_IMAGE": "Imagem com qualidade fraca"
            case "ICAO_NO_INK_MARKED_CREASED_IMAGE": "Imagem com qualidade fraca"
            case "ICAO_FACE_NOT_DETECTED": "Não foi encontrada uma face"
            default: "ICAO Não Reconhecido"
        }
    }
}
