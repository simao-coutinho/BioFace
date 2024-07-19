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
    
    public enum Option: Int, CaseIterable {
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
        
        public static func fromRawValue(value: String) -> Option {
            let intValue = Int(value) ?? 1
            return Option(rawValue: intValue) ?? ICAO_EYES_OPENED
        }
        
        public static func fromDiscribingValue(value: String) -> Option {
            for option in Option.allCases {
                if String(describing: option) == value {
                    return option
                }
            }
            
            let intValue = Int(value) ?? 1
            return Option(rawValue: intValue) ?? ICAO_EYES_OPENED
        }
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
        return [1]
    }
    
    public func getMessage(icaoOption: String) -> String {
        return switch icaoOption {
        case "ICAO_EYES_OPENED": "Mantenha os olhos aberto"
        case "ICAO_NEUTRAL_EXPRESSION": "Mantenha uma expressão facial neutra"
        case "ICAO_MOUTH_CLOSED": "Deve manter a boca fechada"
        case "ICAO_SOULDERS_ALIGNED": "Deve alinhar os ombors para estar frontal à câmara"
        case "ICAO_CORRECT_FACE_POSE": "Mantenha a face virada de frente para a câmara"
        case "ICAO_LOOKING_FORWARD": "Deve olhar para a câmara"
        case "ICAO_HAIR_NOT_COVERING_EYES": "Não pode ter cabelo a cobrir os olhos"
        case "ICAO_HEAD_WITHOUTH_COVERING": "Retire qualquer objeto da cabeça, por exemplo chapéus"
        case "ICAO_VEIL_NOT_OVER_FACE": "Retire qualquer lenço ou véu que cubra a cabeça"
        case "ICAO_ONLY_ONE_FACE": "Na foto só pode aparecer uma pessoa"
        case "ICAO_NO_SUNGLASSES": "Retire óculos escuros"
        case "ICAO_FRAMES_NOT_COVERING_EYES": "A armação dos óculos não pode cobrir os olhos"
        case "ICAO_NO_GLASSES_REFLECTION": "Deve evitar reflexos nas lentes dos óculos"
        case "ICAO_FRAMES_NOT_TOO_HEAVY": "A armação dos óculos é demasiado grande"
        case "ICAO_NO_BACKGROUND_SHADOWS": "Evite sombras no fundo da imagem"
        case "ICAO_NO_FACE_SHADOWS": "Evite sombras na face"
        case "ICAO_NO_FLASH_REFLECTION": "Evite reflexos provocados pela luz de flash"
        case "ICAO_NATURAL_SKIN_TONE": "Procure uma foto com o seu tom natural de pele"
        case "ICAO_NO_RED_EYES": "Repita a foto para evitar o efeito de olhos vermelhos"
        case "ICAO_LIGHTING_CONDITIONS_CORRECT": "Procure boa iluminação para uma foto com luz adequada"
        case "ICAO_NO_BLURRED_IMAGE": "A imagem não tem qualidade suficiente"
        case "ICAO_HOMOGENEOUS_BACKGROUND": "Procure um local para tirar uma foto com fundo homogéneo"
        case "ICAO_NO_PIXELATED_IMAGE": "A imagem não tem qualidade suficiente"
        case "ICAO_NO_WASHED_OUT_IMAGE": "A imagem não tem qualidade suficiente"
        case "ICAO_NO_INK_MARKED_CREASED_IMAGE": "A imagem não tem qualidade suficiente"
        case "ICAO_FACE_NOT_DETECTED": "Não foi detetada uma face na imagem"
        case "FACE_DETECTED": "Não foi detetada uma face. Por favor, tente outra vez."
        case "LIVENESS": "Possível ataque de apresentação detetado"
        case "LIVENESS_YES": "Possível ataque de apresentação detetado"
        case "GENERAL_BIOMETRIC_DATA_COMP": "A face detetada não corresponde à de registo"
        default: "\(icaoOption) retornou falso"
        }
    }
}
