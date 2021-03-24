//
//  MenuOpcoesAlunos.swift
//  Agenda
//
//  Created by Jonattan Moises Sousa on 24/03/21.
//  Copyright © 2021 Alura. All rights reserved.
//

import UIKit

enum MenuActioSheetAluno {
    case sms
    case ligacao
    case waze
    case mapa
}

class MenuOpcoesAlunos: NSObject {

    func configuraMenuOpcoesAluno(completion:@escaping(_ opcao:MenuActioSheetAluno) -> Void) -> UIAlertController {
        let menu = UIAlertController(title: "Atenção", message: "Escolha uma das opcoes abaixo", preferredStyle: .actionSheet)
        let sms = UIAlertAction(title: "Enviar SMS", style: .default) { (acao) in
            completion(.sms)
        }
        menu.addAction(sms)
        
        let ligacao = UIAlertAction(title: "Ligar", style: .default) { (acao) in
            completion(.ligacao)
        }
        menu.addAction(ligacao)
        
        let wase = UIAlertAction(title: "Localizar no Waze", style: .default) { (acao) in
            completion(.waze)
        }
        menu.addAction(wase)
        
        let mapa = UIAlertAction(title: "Localizar no mapa", style: .default) { (acao) in
            completion(.mapa)
        }
        menu.addAction(mapa)
        
        let cancelar = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        menu.addAction(cancelar)
        return menu
    }
}
