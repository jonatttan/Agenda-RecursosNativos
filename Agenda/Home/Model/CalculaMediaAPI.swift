//
//  CalculaMediaAPI.swift
//  Agenda
//
//  Created by Jonattan Moises Sousa on 24/03/21.
//  Copyright © 2021 Alura. All rights reserved.
//

import UIKit

class CalculaMediaAPI: NSObject {
    
    func calculaMediaGeralDosAlunos(alunos:Array<Aluno>, sucesso:@escaping(_ dicionarioDeMedias:Dictionary<String, Any>) -> Void, falha:@escaping(_ error:Error) -> Void) { // Definição na assinatura do método os retornos em caso de sucesso e falha
        
        guard let url = URL(string: "https://673bf8e5-4661-47b9-bce3-179d2b2a57c7.mock.pstmn.io/media") else { return }
        var listaDeAlunos: Array<Dictionary<String, Any>> = []
        var json:Dictionary<String, Any> = [:]
        
        for aluno in alunos {

            guard let nome = aluno.nome else { return }
            guard let endereco = aluno.endereco else { return }
            guard let telefone = aluno.telefone else { return }
            guard let site = aluno.site else { return }

            let dicionarioDeAlunos = [
                "id" : "\(aluno.objectID)",
                "nome" : nome,
                "endereco" : endereco,
                "telefone" : telefone,
                "site" : site,
                "nota" : String(aluno.nota)
            ]
            listaDeAlunos.append(dicionarioDeAlunos as [String:Any])
        }
        
//        let dicionarioDeAlunos = [
//            "id": "1",
//            "nome": "Andd",
//            "endereco": "dasdsads",
//            "telefone": "323212",
//            "site": "dasd.com",
//            "nota": "9",
//        ]
        
        json = [
            "list": [
                ["aluno": listaDeAlunos]
            ]
        ]
        
        do {
            var requisicao = URLRequest(url: url)
            let data = try JSONSerialization.data(withJSONObject: json, options: [])
            requisicao.httpBody = data
            requisicao.httpMethod = "POST"
            requisicao.addValue("application/json", forHTTPHeaderField: "Content-Type")
          
            let task = URLSession.shared.dataTask(with: requisicao, completionHandler: { (data, response, error) in // Talvez tenha de colocar tudo dentro de 'descricao'
                if error == nil {
                    do {
                        let dicionario = try JSONSerialization.jsonObject(with: data!, options: []) as! Dictionary<String, Any> // O retorno abaixo espera um dicionário de String, Any, então será enviado já convertido através desse casting
                        sucesso(dicionario)
                    } catch {
                        falha(error)
                    }
                }
            })
            task.resume()
            
        } catch {
            print(error.localizedDescription)
        }
    }
}
