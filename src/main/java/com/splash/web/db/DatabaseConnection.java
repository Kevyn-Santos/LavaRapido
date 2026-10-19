package com.splash.web.db;

import java.sql.Connection;
import java.sql.SQLException;
import java.sql.DriverManager;
import java.nio.file.Path;
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

    // Pasta do .env: propriedade -Ddotenv.dir ou variável DOTENV_DIR. Sem nenhuma das duas, a pasta onde a JVM foi
    // iniciada (no Tomcat do sistema é o CATALINA_BASE, não a raiz do projeto). Ver miscelaneous/variaveis-de-ambiente.md
    private static final String PASTA_ENV = pastaEnv();
    private static final Dotenv dotenv = Dotenv.configure() // Configura a biblioteca para capturar apenas os valores preenchidos de ENV local
            .directory(PASTA_ENV)
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
            // Diz onde o .env foi procurado, porque a pasta muda conforme o Tomcat (ver pastaEnv)
            throw new IllegalStateException("Variável de ambiente ausente ou vazia: " + chave
                    + " (procurada nas variáveis do sistema e em " + Path.of(PASTA_ENV, ".env").toAbsolutePath().normalize() + ")");
        }
        return valor;
    };

    private static String pastaEnv() {
        String pasta = System.getProperty("dotenv.dir");
        if (pasta == null || pasta.isBlank()) {
            pasta = System.getenv("DOTENV_DIR");
        }
        return pasta == null || pasta.isBlank() ? "./" : pasta.trim();
    }


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
