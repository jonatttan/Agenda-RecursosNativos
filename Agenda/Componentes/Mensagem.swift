//
//  Mensagem.swift
//  Agenda
//
//  Created by Jonattan Moises Sousa on 24/03/21.
//  Copyright © 2021 Alura. All rights reserved.
//

import UIKit
import MessageUI

class Mensagem: NSObject, MFMessageComposeViewControllerDelegate {
    
    //MARK: - Métodos
    
    func configuraSMS(_ aluno:Aluno) -> MFMessageComposeViewController? {
        
        if !MFMessageComposeViewController.canSendText() {
            print("Detectado simulador, recurso de SMS indisponível.")
            return nil // tem de deixar o metodo como optional para usar o nil, assim terá de tratar no uso.
        }
        
        let componenteMensagem = MFMessageComposeViewController()
        guard let numeroAluno = aluno.telefone else { return componenteMensagem}
        componenteMensagem.recipients = [numeroAluno] //Seta o número de destino no app de mensagem nativo
        componenteMensagem.messageComposeDelegate = self
        
        return componenteMensagem
    }
    
    
    //MARK: - MessageComposerDelegate
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
        
    }

}
