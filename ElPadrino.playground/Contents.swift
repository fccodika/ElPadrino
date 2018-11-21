import UIKit

extension Array {
  func any(_ fx: @escaping (Element) -> Bool) -> Bool {
    return self.filter(fx).count > 0
  }
}










protocol Arma {
  func usarContra(_ unMiembro: Miembro)
  func esSutil() -> Bool
}


class Revolver: Arma {
  var balas: Int
  
  init(_ unasBalas: Int) {
    balas = unasBalas
  }
  
  func usarContra(_ unMiembro: Miembro) {
    if self.tieneBalas() {
      unMiembro.morirse()
      balas -= 1
    }
  }
  
  func tieneBalas() -> Bool {
    return balas > 0
  }
  
  func esSutil() -> Bool {
    return balas == 1
  }
}

class Escopeta: Arma {
  func usarContra(_ unMiembro: Miembro) {
    unMiembro.herirse()
  }
  
  func esSutil() -> Bool {
    return false
  }
}

class Cuerda: Arma {
  var buenaCalidad: Bool
  
  init(_ unaCalidad: Bool) {
    buenaCalidad = unaCalidad
  }
  
  func usarContra(_ unMiembro: Miembro) {
    if self.buenaCalidad {
      unMiembro.morirse()
    }
  }
  
  func esSutil() -> Bool {
    return true
  }
}



protocol Rango {
  func despachaElegantemente(unMiembro: Miembro) -> Bool
  func ataque(atacante: Miembro, atacado: Miembro)
  func cambiarRangoDe(unMiembro: Miembro)
}

class Don: Rango {
  func despachaElegantemente(unMiembro: Miembro) -> Bool {
    return true
  }
  
  func ataque(atacante: Miembro, atacado: Miembro) {
    atacante.cualquierSubordinado().atacarA(otroMiembro: atacado)
  }
  
  func cambiarRangoDe(unMiembro: Miembro) { }
}

class Subjefe: Rango {
  func despachaElegantemente(unMiembro: Miembro) -> Bool {
    return unMiembro.subordinadoSutil()
  }
  
  func ataque(atacante: Miembro, atacado: Miembro) {
    atacante.armaAMano().usarContra(atacado)
    atacante.rotarArmas()
  }
  
  func cambiarRangoDe(unMiembro: Miembro) { }
}

class Soldado: Rango {
  func despachaElegantemente(unMiembro: Miembro) -> Bool {
    return unMiembro.tieneArmaSutil()
  }
  
  func ataque(atacante: Miembro, atacado: Miembro) {
    atacante.cualquierArma().usarContra(atacado)
  }
  
  func cambiarRangoDe(unMiembro: Miembro) {
    if unMiembro.cantidadDeArmas() > 5 {
      unMiembro.cambiarRangoPor(Subjefe())
    }
  }
}

class Miembro {
  var herido: Bool = false
  var muerto: Bool = false
  var rango: Rango
  var lealtad = 100.0
  
  var armas: [Arma] = []
  var subordinados: [Miembro] = []
  
  init(unRango: Rango) {
    rango = unRango
  }
  
  func cambiarRangoPor(_ unRango: Rango) {
    rango = unRango
  }
  
  func estaHerido() -> Bool {
    return herido
  }
  
  func herirse() {
    if self.estaHerido() {
      herido = false
      muerto = true
    } else {
      herido = true
    }
  }
  
  func morirse() {
    muerto = true
  }
  
  func duermeConLosPeces() -> Bool {
    return muerto
  }
  
  func cantidadDeArmas() -> Int {
    return armas.count
  }
  
  func agregarArma(_ unArma: Arma) {
    self.armas.append(unArma)
  }
  
  func cualquierArma() -> Arma {
    return armas.randomElement()!
  }
  
  func armaAMano() -> Arma {
    return armas.first!
  }
  
  func rotarArmas() {
    let armaUsada = armas.first!
    armas = armas.dropFirst() + [armaUsada]
  }
  
  func sabeDespacharElegantemente() -> Bool {
    return rango.despachaElegantemente(unMiembro: self)
  }
  
  func atacarFamilia(_ unaFamilia: Familia) {
    self.atacarA(otroMiembro: unaFamilia.elMasPeligroso())
  }
  
  func atacarA(otroMiembro: Miembro) {
    rango.ataque(atacante: self, atacado: otroMiembro)
  }
  
  func cualquierSubordinado() -> Miembro {
    return subordinados.randomElement()!
  }
  
  func tieneArmaSutil() -> Bool {
    return armas.any{ arma in arma.esSutil() }
  }
  
  func subordinadoSutil() -> Bool {
    return subordinados.any{ miembro in miembro.tieneArmaSutil() }
  }
  
  func aumentarLealtadPorcentualmente() {
    lealtad = lealtad * 1.1
  }
  
  func estaDeLuto() {
    rango.cambiarRangoDe(unMiembro: self)
    self.aumentarLealtadPorcentualmente()
  }
  
  func maximaLealtad() {
    lealtad = 100.0
  }
}

class DonVito: Miembro {
  init() {
    super.init(unRango: Don())
  }
  
  override func atacarA(otroMiembro: Miembro) {
    super.atacarA(otroMiembro: otroMiembro)
    super.atacarA(otroMiembro: otroMiembro)
  }
}

class Familia {
  var miembros: [Miembro] = []
  var traiciones: [Traicion] = []
  
  func miembrosVivos() -> [Miembro] {
    return miembros.filter{ miembro in !miembro.duermeConLosPeces() }
  }
  
  func elMasPeligroso() -> Miembro {
    return self.miembrosVivos().max(by: { (miembro1, miembro2) in miembro1.cantidadDeArmas() > miembro2.cantidadDeArmas() })!
  }
  
  func atacarFamilia(_ otraFamilia: Familia) {
    self.miembrosVivos().forEach{ miembro in miembro.atacarFamilia(otraFamilia) }
  }
  
  func reorganizarse() {
    self.miembrosVivos().forEach{ miembro in miembro.estaDeLuto() }
    self.elMasLeal().cambiarRangoPor(Don())
  }
  
  func elMasLeal() -> Miembro {
    return self.miembrosQueSabenDespachar().max(by: { (m1, m2) in m1.lealtad > m2.lealtad })!
  }
  
  func miembrosQueSabenDespachar() -> [Miembro] {
    return self.miembrosVivos().filter{ miembro in miembro.sabeDespacharElegantemente() }
  }
  
  func promedioLealtad() -> Double {
    return miembros.map{ miembro in miembro.lealtad }.reduce(0, { (res, lealtad) in res + lealtad }) / Double(miembros.count)
  }
  
  func agregarMiembro(_ miembro: Miembro) {
    miembros.append(miembro)
  }
  
  func quitarMiembro(_ miembro: Miembro) {
    
  }
  
  func recordarTraicion(_ traicion: Traicion) {
    traiciones.append(traicion)
  }
}


class Traicion {
  var fecha: Date
  var traidor: Miembro
  var familiaActual: Familia
  var familiaNueva: Familia
  var victimas: [Miembro] = []
  
  init(_ unaFecha: Date, unTraidor: Miembro, familiaActual: Familia, familiaNueva: Familia) {
    fecha = unaFecha
    traidor = unTraidor
    self.familiaActual = familiaActual
    self.familiaNueva = familiaNueva
  }
  
  func agregarVictima(_ victima: Miembro) {
    victimas.append(victima)
  }
  
  func adelantarDias(_ otraFecha: Date, _ nuevaVictima: Miembro) {
    fecha = otraFecha
    victimas.append(nuevaVictima)
  }
  
  func realizarse() {
    if self.puedeRealizarse() {
      self.concretarse()
    } else {
      self.desbaratarse()
    }
  }
  
  func puedeRealizarse() -> Bool {
    return familiaNueva.promedioLealtad() > traidor.lealtad * 2
  }
  
  func desbaratarse() {
    traidor.morirse()
  }
  
  func concretarse() {
    self.atacarVictimas()
    self.cambiarFamilia()
    familiaActual.recordarTraicion(self)
  }
  
  func atacarVictimas() {
    victimas.forEach{ m in traidor.atacarA(otroMiembro: m) }
  }
  
  func cambiarFamilia() {
    familiaNueva.agregarMiembro(traidor)
    familiaActual.quitarMiembro(traidor)
    traidor.maximaLealtad()
  }
}
