package com.splash.web.model;

/*Base de todas as entidades que possuem chave primária gerada pelo banco O id fica nulo até a entidade ser persistida e só pode ser definido uma vez.*/
public abstract class EntidadeBase {

    private Integer id;

    public Integer getId() {
        return id;
    }

    /* Chamado pela camada de persistência DAO depois do INSERT ou ao carregar do banco. */
    public void setId(int id) {
        if (this.id != null) {
            throw new IllegalStateException("O id já foi definido e não pode ser alterado.");
        }
        if (id <= 0) {
            throw new IllegalArgumentException("O id deve ser positivo.");
        }
        this.id = id;
    }

    public boolean isPersistido() {
        return id != null;
    }
}
