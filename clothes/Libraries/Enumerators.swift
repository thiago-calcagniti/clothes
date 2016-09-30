//
//  AppCustomEnumerator.swift
//  AnimatedTabControl
//
//  Created by Thiago Calcagniti on 08/01/16.
//  Copyright © 2016 Calcagniti. All rights reserved.
//

import Foundation



class Enumerators {
    
    
    // Cloth Types
    func getClothTypes() -> Array<String> {
        let clothTypes:[String] = ["Outros", "Acessorio", "Camisa", "Camiseta", "Jaqueta", "Calcinha", "Calca", "Saia", "Vestido", "Meias", "Calcados", "Fitness", "Biquini", "Sutia"]
        return clothTypes
    }
    
    
    func getImageForClothType(_ type:String) -> String {
            switch type {
            case "Acessorio": return "acessoriesIcon.png"
            case "Camisa": return "shirtsIcon.png"
            case "Camiseta": return "tShirtsIcon.png"
            case "Jaqueta": return "jacketsIcon.png"
            case "Calcinha": return "underwearsIcon.png"
            case "Calca": return "pantsIcon.png"
            case "Saia": return "skirtsIcon.png"
            case "Vestido": return "dressIcon.png"
            case "Meias": return "socketsIcon.png"
            case "Calcados": return "shoesIcon.png"
            case "Blusa": return "blousesIcon.png"
            case "Fitness": return "fitnessIcon.png"
            case "Moleton": return "moletonsIcon.png"
            case "Pijamas": return "pijamasIcon.png"
            case "Biquini": return "bikinisIcon.png"
            case "Sutia": return "sutiasIcon.png"
            case "Outros": return "shirtsIcon.png"
            default: return "shirtsIcon.png"
        }
    }
    
    
    // Occasion Types
    func getOccasionTypes() -> Array<String> {
        let occasionTypes:[String] = ["Aniversario", "Campo", "Churrasco","Cotidiano","Esporte","Festa","Festa Fantasia","Inverno","Natal","Outono","Piscina","Praia","Primavera","Trabalho","Trilha", "Verao"]
        return occasionTypes
    }
    func getImageForOccasionTypes(_ occasion: String) -> String {
        switch occasion {
            case "Aniversario": return "aniversario.png"
            case "Campo": return "campo.png"
            case "Churrasco": return "churrasco.png"
            case "Cotidiano": return "cotidiano.png"
            case "Esporte": return "esporte.png"
            case "Festa": return "festa.png"
            case "Festa Fantasia": return "festaFantasia.png"
            case "Inverno": return "inverno.png"
            case "Natal": return "natal.png"
            case "Outono": return "outono.png"
            case "Piscina": return "piscina.png"
            case "Praia": return "praia.png"
            case "Primavera": return "primavera.png"
            case "Trabalho": return "trabalho.png"
            case "Trilha": return "trilha.png"
            case "Verao": return "verao.png"
            default: return ""
        }
    }
    
    
    // Body Shapes
    func getBodyShapes(_ gender: String) -> Array<String> {
        var bodyShapes = Array<String>()
        if gender == "Masculino" {
            bodyShapes = ["Atlético","Fofinho","Musculoso","Magrelo","Encorpado","Indefinido"]
        } else if gender == "Feminino" {
            bodyShapes = ["Atlética","Fofinha","Musculosa","Magrela","Encorpada","Indefinido"]
        }
        return bodyShapes
    }

    


    
    
}
