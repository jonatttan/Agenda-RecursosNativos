//
//  MapaViewController.swift
//  Agenda
//
//  Created by Jonattan Moises Sousa on 24/03/21.
//  Copyright © 2021 Alura. All rights reserved.
//

import UIKit
import MapKit

class MapaViewController: UIViewController, CLLocationManagerDelegate {
    
    //MARK: - IBOutlet
    
    @IBOutlet weak var mapa: MKMapView!
    
    
    //MARK: - Variavel
    
    var aluno:Aluno?
    lazy var localizacao = Localizacao()
    lazy var gerenciadorDeLocalizacao = CLLocationManager()
    
    
    //MARK: -  View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = getTitulo() //aplicando titulo definido
        verificaAurorizacaoDoUsuario()
        localizacaoInicial()
        mapa.delegate = localizacao
        gerenciadorDeLocalizacao.delegate = self
    }

    
    //MARK: - Métodos
    
    func getTitulo() -> String { //setando titulo
        return "Localizar Alunos"
    }
    
    func verificaAurorizacaoDoUsuario() {
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .authorizedWhenInUse:
                let botao = Localizacao().configuraBotaoLocalizacaoAtual(mapa: mapa)
                mapa.addSubview(botao)
                gerenciadorDeLocalizacao.startUpdatingLocation()
                break
                
            case .notDetermined:
                gerenciadorDeLocalizacao.requestWhenInUseAuthorization()
                break
                
            case .denied:
                
                break
            default:
                break
            }
        }
    }
    
    func localizacaoInicial() { //Pino de origem
        Localizacao().converteEnderecoEmCoordenadas(endereco: "Sé - São Paulo") { (localizacaoEncontrada) in
//            let pino = self.configuraPino(titulo: "Praça da Sé", localizacao: localizacaoEncontrada)
            let pino = Localizacao().configuraPino(titulo: "Caelum", localizacao: localizacaoEncontrada, cor: .black, icone: UIImage(named: "icon_caelum"))
            let regiao = MKCoordinateRegionMakeWithDistance(pino.coordinate, 5000, 5000)
            self.mapa.setRegion(regiao, animated: true)
            self.mapa.addAnnotation(pino)
            self.localizarAluno()
        }
    }
    
    func localizarAluno() {
        if let aluno = aluno { //Pino de destino
            Localizacao().converteEnderecoEmCoordenadas(endereco: aluno.endereco!) { (localizacaoEncontrada) in
                let pino = Localizacao().configuraPino(titulo: aluno.nome!, localizacao: localizacaoEncontrada, cor: nil, icone: nil)
                self.mapa.addAnnotation(pino)
                self.mapa.showAnnotations(self.mapa.annotations, animated: true)//Para mostrar os dois pinos na tela
            }
        }
    }
    
    //MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse:
            let botao = Localizacao().configuraBotaoLocalizacaoAtual(mapa: mapa)
            mapa.addSubview(botao)
            gerenciadorDeLocalizacao.startUpdatingLocation()
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print(locations)
    }
    

}
