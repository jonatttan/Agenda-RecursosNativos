//
//  CalculaMediaAPI.swift
//  Agenda
//
//  Created by Jonattan Moises Sousa on 24/03/21.
//  Copyright © 2021 Alura. All rights reserved.
//

import UIKit

class CalculaMediaAPI: NSObject {
    
    func calculaMediaGeralDosAlunos() {
        
        guard let url = URL(string: "https://673bf8e5-4661-47b9-bce3-179d2b2a57c7.mock.pstmn.io/media") else { return }
        var listaDeAlunos: Array<Dictionary<String, Any>> = []
        var json:Dictionary<String, Any> = [:]
        
        
        
        let dicionarioDeAlunos = [
            "id" : "1",
            "nome" : "Jonattan",
            "endereco" : "Rua da benga",
            "telefone" : "99148-5784",
            "site" : "www.senai.com.br",
            "nota" : "9"
        ]
        listaDeAlunos.append(dicionarioDeAlunos as [String:Any])
        
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
                        let dicionario = try JSONSerialization.jsonObject(with: data!, options: [])
                        print(dicionario)
                    } catch {
                        print("Deu erro aqui, arruma.")
                        print(error.localizedDescription)
                    }
                }
            })
            task.resume()
            
        } catch {
            print(error.localizedDescription)
        }
        
    }



}
