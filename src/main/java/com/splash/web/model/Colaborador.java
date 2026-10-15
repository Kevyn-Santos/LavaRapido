package com.splash.web.model;

import com.splash.web.model.enums.NivelAcesso;

public class Colaborador extends Pessoa {

    private String cargo;
    private NivelAcesso nivelAcesso;

    public Colaborador(String nome, String cargo, NivelAcesso nivelAcesso, String email, String senhaHash) {
        super(nome, email, senhaHash);
        setCargo(cargo);
        setNivelAcesso(nivelAcesso);
    }

    public String getCargo() {
        return cargo;
    }

    public final void setCargo(String cargo) {
        this.cargo = Validacao.textoObrigatorio(cargo, "Cargo", 60);
    }

    public NivelAcesso getNivelAcesso() {
        return nivelAcesso;
    }

    public final void setNivelAcesso(NivelAcesso nivelAcesso) {
        this.nivelAcesso = Validacao.obrigatorio(nivelAcesso, "Nível de acesso");
    }

    public boolean isAdministrador() {
        return nivelAcesso == NivelAcesso.ADMINISTRADOR;
    }
}
