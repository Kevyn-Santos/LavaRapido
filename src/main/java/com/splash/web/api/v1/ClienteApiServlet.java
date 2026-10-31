package com.splash.web.api.v1;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;

import com.splash.web.api.ApiServlet;

import com.splash.web.db.DAOCliente;
import com.splash.web.model.Cliente;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * <pre>
 * GET   /api/v1/me -> {id, nome, cpf, telefone, email}
 * PATCH /api/v1/me {nome?, telefone?, email?}
 * </pre>
 *
 * TODO: implementar usando DAOCliente. Ver miscelaneous/analise-app-mobile.md, seção 3.5.
 */
@WebServlet("/api/v1/usuarios")
public class ClienteApiServlet extends ApiServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        // TODO: DAOCliente.getusuario(idClienteAutenticado(request))

        // Configurações de resposta para o front
        response.setContentType("application/json"); // Define a resposta como Json
        response.setCharacterEncoding("UTF-8"); // Define a codificação de texto em UTF-8
        response.setStatus(HttpServletResponse.SC_OK); // Define código HTTp 200 com o padrão da página

        // definição das variaveis utilizadas
        DAOCliente dao = new DAOCliente(); // Cria o objeto de DAO
        Map<String, Object> payload = new HashMap<>(); // Cria um Hash para armazenar os retornos da api
        PrintWriter out = response.getWriter(); // Cria um objeto para escrever a resposta

        /*
        * Possiveis erros:
        *
        * Informação errada
        * payload vazio ou mal formado
        * Erro de conexão com o banco
        * Erro de pesquisa na DAO
        * Erro no envio de informações para o front
        * */

        try{
            /*
            * Retornar a lista
            * Iterar sobre a lista
            * Montar um Hash ou payload chave-valor com os elementos da lista
            * */
            for(Cliente item:dao.getUsuarios()){
                payload.put("Id_Cliente", item.getId_cliente());
                payload.put("Nome", item.getNome());
                payload.put("CPF", item.getCpf());
                payload.put("Email", item.getEmail());
                payload.put("Telefone", item.getTelefone());
            }

            // cria um iterador a partir dos valores de payload
            Iterator<Object> iter = payload.values().iterator();

            // Enquanto o payload tiver valores, monta o JSON, retorna com "Out",
            // captura essa iteração e passa para a proxima
            while(iter.hasNext()) {

                String json = """
                        {
                            "id": %d,
                            "nome": %s,
                            "cpf": %s,
                            "email: %s,
                            "telefone": %s
                        }
                        """.formatted(
                        (Integer) payload.get("Id_Cliente"),
                        payload.get("Nome"),
                        payload.get("CPF"),
                        payload.get("Email"),
                        payload.get("Telefone"));
                // retorna a resposta para o mobile escrevendo o resultado da API
                out.print(json);
                out.flush();
                Object nextValue = iter.next();
            }



        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
    }

    @Override
    protected void doPatch(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // TODO: DAOCliente.updateUsuarios(...)
        response.sendError(HttpServletResponse.SC_NOT_IMPLEMENTED);
    }
}
