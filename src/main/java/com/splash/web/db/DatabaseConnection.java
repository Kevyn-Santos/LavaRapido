package com.splash.web.db;

import java.sql.Connection;
import java.sql.SQLException;
import java.sql.DriverManager;
import io.github.cdimascio.dotenv.Dotenv;

/**
 * Classe de conexão com o banco de dados
 *
 * <p>
 *     Realiza a conexão utilizando o Driver Mysql do JDBC,
 *     distinguindo o acesso ao banco local ou de produção por meio de variáveis de ambiente
 * </p>
 */
public class DatabaseConnection {

    public enum Ambiente{LOCAL, PROD}; // Define os possíveis ambientes de desenvolvimento do banco (PROD, LOCAL)
    private static final Dotenv dotenv = Dotenv.configure() // Configura a biblioteca para capturar apenas os valores preenchidos de ENV local
            .ignoreIfMissing()
            .load();

    // Define o valor padrão da variável de ambiente; se "ENV_DEV" estiver preenchido ele é usado, senão é utilizado o valor "local"
    private static final Ambiente PADRAO = Ambiente.valueOf(dotenv.get("ENV_DEV", "LOCAL").trim().toUpperCase());

    // Inicia a conexão passando o valor de ambiente padrão(que é local)
    public static Connection getConnection() throws SQLException{
        return getConnection(PADRAO);
    }

     /**
      * Função que verifica se a chave informada existe
      * <p>Se {@code chave} existir ela é retornada.
      * Se {@code chave} não existir é retornado um {@code IllegalStateException}</p>
      *
      * @param chave {@code String} advinda de uma variável de ambiente
      * @throws IllegalStateException se o valor de chave for {@code null} ou {@code Blank}
      * */
    private static String ChaveObrigatoria(String chave){
        String valor = dotenv.get(chave);
        if (valor == null || valor.isBlank()) {
            throw new IllegalStateException("Variável de ambiente ausente ou vazia: " + chave);
        }
        return valor;
    };


    public static Connection getConnection(Ambiente ambiente) throws SQLException {
        String prefix = ambiente.name() + "_"; //Anexa o valor de "ambiente" ao underscore, resultando em "LOCAL_" ou "PROD_"
        // No Tomcat o DriverManager não enxerga drivers do WEB-INF/lib sozinho, então o registro é explícito
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new SQLException("Driver MySQL não encontrado no classpath", e);
        }

        // SQLException é propagada sem embrulhar, para os servlets tratarem casos como violação de chave (409)
        return DriverManager.getConnection(
                ChaveObrigatoria(prefix + "DB_URL"),
                ChaveObrigatoria(prefix + "USER"),
                ChaveObrigatoria(prefix + "PASS"));
    }

}
