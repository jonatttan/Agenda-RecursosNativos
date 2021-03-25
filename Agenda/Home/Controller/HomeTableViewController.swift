//
//  HomeTableViewController.swift
//  Agenda
//
//  Created by Ândriu Coelho on 24/11/17.
//  Copyright © 2017 Alura. All rights reserved.
//

import UIKit
import CoreData
import SafariServices

class HomeTableViewController: UITableViewController, UISearchBarDelegate, NSFetchedResultsControllerDelegate {
    
    //MARK: - Variáveis
    
    var contexto:NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
    
    let searchController = UISearchController(searchResultsController: nil)
    var gerenciadorDeResultados:NSFetchedResultsController<Aluno>?
    var alunoViewController:AlunoViewController?
    var mensagem = Mensagem()
    
    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configuraSearch()
        self.recuperaAluno()
    }
    
    // MARK: - Métodos
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editar"{
            alunoViewController = segue.destination as? AlunoViewController
        }
    }
    
    func configuraSearch() {
        self.searchController.searchBar.delegate = self
        self.searchController.dimsBackgroundDuringPresentation = false
        self.navigationItem.searchController = searchController
    }
    
    func recuperaAluno(filtro:String = "") { // Definindo dessa forma na assinatura, cria-se duas opções de chamada do método.
        let pesquisaAluno:NSFetchRequest<Aluno> = Aluno.fetchRequest()
        let ordenaPorNome = NSSortDescriptor(key: "nome", ascending: true)
        pesquisaAluno.sortDescriptors = [ordenaPorNome]
        
        if verificaFiltro(filtro){
            pesquisaAluno.predicate = filtraAluno(filtro)
        }
        
        gerenciadorDeResultados = NSFetchedResultsController(fetchRequest: pesquisaAluno, managedObjectContext: contexto, sectionNameKeyPath: nil, cacheName: nil)
        gerenciadorDeResultados?.delegate = self
        
        do {
            try gerenciadorDeResultados?.performFetch()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    
    
    //MARK: - NSPredicate (filtro)
    func filtraAluno(_ filtro: String) -> NSPredicate {
        return NSPredicate(format: "nome CONTAINS %@", filtro)
    }
    
    func verificaFiltro(_ filtro:String) -> Bool {
        if filtro.isEmpty {
            return false
        }
        return true
    }
    
    
    
    @objc func abrirActionSheet(_ longPress:UILongPressGestureRecognizer) {
        if longPress.state == .began {
            //Dando erro aqui, o alunoSelecionado é o incorreto. Pegar o fetched objects e debugar, contar o nº de objetos dentro dele, percorrer...
            guard let alunoSelecionado = gerenciadorDeResultados?.fetchedObjects?[(longPress.view?.tag)!] else { return }
            // Pegamos o aluno para passar à constante componenteMensagem
            let menu = MenuOpcoesAlunos().configuraMenuOpcoesAluno (completion: { (opcao) in
                switch opcao {
                case .sms:
                    if let componenteMensagem = self.mensagem.configuraSMS(alunoSelecionado) {
                        componenteMensagem.messageComposeDelegate = self.mensagem
                        self.present(componenteMensagem, animated: true, completion: nil)
                    }
                    break
                case .ligacao:
                    guard let numeroAluno = alunoSelecionado.telefone else { return }
                    if let url  = URL(string: "tel://\(numeroAluno)"), UIApplication.shared.canOpenURL(url){
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                    break
                case .waze:
                    if UIApplication.shared.canOpenURL(URL(string: "waze://")!) {
                        guard let enderecoDoAluno = alunoSelecionado.endereco else { return }
                        Localizacao().converteEnderecoEmCoordenadas(endereco: enderecoDoAluno, local: { (localizacaoEncontrada) in
                            
                            let latitude = String(describing:localizacaoEncontrada.location?.coordinate.latitude)
                            let longitude = String(describing:localizacaoEncontrada.location?.coordinate.longitude)
                            let url:String = "waze://?ll=\(latitude),\(longitude)&navigate=yes"
                            UIApplication.shared.open(URL(string: url)!, options: [:], completionHandler: nil)
                        })
                    }
                    break
                case .mapa:
                    
                    let mapa = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mapa") as! MapaViewController //Resgatando o StoryBoard a ser exibido
                    mapa.aluno = alunoSelecionado
                    self.navigationController?.pushViewController(mapa, animated: true) // Empurrando a tela resgatada a cima
                    
                    break
                case .abrirPaginaWeb:
                    
                    if let urlDoAluno = alunoSelecionado.site {
                        
                        var urlFormatada = urlDoAluno
                        if !urlFormatada.hasPrefix("http://") { //Verifica se a variável se inicia com http://
                            urlFormatada = String(format: "http://%@", urlFormatada)
                        }
                        
                        guard let url = URL(string: urlFormatada) else { return }
                        
                        //UIApplication.shared.open(url, options: [:], completionHandler: nil) // Abertura da url em página livre no navegador
                        let safariViewController = SFSafariViewController(url: url) // Abertura da url em página estática no navegador
                        
                        self.present(safariViewController, animated: true, completion: nil)
                    }
                    
                    break
                }
            })
            self.present(menu, animated: true, completion: nil)
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let contadorListaAlunos = gerenciadorDeResultados?.fetchedObjects?.count else { return 0}
        
        return contadorListaAlunos
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "celula-aluno", for: indexPath) as! HomeTableViewCell
        cell.tag = indexPath.row // Esta é a resolução do problema com abertura do AlertController, onde qualquer registro pressionado correspodia ao primeiro da lista.
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(abrirActionSheet(_:)))
        guard let aluno = gerenciadorDeResultados?.fetchedObjects![indexPath.row] else { return cell }

        cell.configuraCelula(aluno)
        cell.addGestureRecognizer(longPress)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            AutenticacaoLocal().autorizaUsuario { (autenticado) in
                if autenticado {
                    DispatchQueue.main.async { // Consertando problema de thread, dispachando para fila da thread principal, para então ser executada.
                        guard let alunoSelecionado = self.gerenciadorDeResultados?.fetchedObjects![indexPath.row] else { return }
                        self.contexto.delete(alunoSelecionado)
                        
                        do {
                            try self.contexto.save()
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                }
            }
            
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let alunoSelecionado = gerenciadorDeResultados?.fetchedObjects![indexPath.row]
        else { return }
        //Seleção de aluno para edição e atribiução para a proxima controller(AlunoViewController)
        alunoViewController?.aluno = alunoSelecionado
        
    }
    
    
    // MARK: - FeatchedResultsControllerDelegate
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .delete:
            guard let indexPath = indexPath else { return }
            tableView.deleteRows(at: [indexPath], with: .fade)
        break
        default:
            tableView.reloadData()
        }
    }
    
    @IBAction func buttonCalculaMedia(_ sender: UIBarButtonItem) {
        guard let listaDeAlunos = gerenciadorDeResultados?.fetchedObjects else { return }
        CalculaMediaAPI().calculaMediaGeralDosAlunos(alunos: listaDeAlunos) { (dicionario) in // Aqui é enviado o listaDeAlunos ao método para processamento, em caso de sucesso, nos devolverá o dicionário, que será usado no alerta.
            if let alerta = Notificacoes().exibeNotificacaoDeMediaDosAlunos(dicionarioDeMedia: dicionario) {
                self.present(alerta, animated: true, completion: nil)
            }
        } falha: { (error) in
            print(error.localizedDescription)
            print("Deu erro")
        }
    }
    
    
    @IBAction func buttonLocaliazacaoGeral(_ sender: UIBarButtonItem) { // Chamando tela do mapa
        let mapa = UIStoryboard(name: "Main" , bundle: nil).instantiateViewController(withIdentifier: "mapa") as! MapaViewController
        navigationController?.pushViewController(mapa, animated: true)
    }
    
    
    //MARK: - SearchBarDelegate
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let nomeDoAluno = searchBar.text else { return }
        recuperaAluno(filtro: nomeDoAluno)
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        recuperaAluno()
        tableView.reloadData()
    }
    
    

    
    
    
    
    
    
    
    
    
    
    
    
}
