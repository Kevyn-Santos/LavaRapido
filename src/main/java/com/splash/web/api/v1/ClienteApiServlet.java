package com.splash.web.api.v1;

import java.io.IOException;
import java.sql.SQLException;
import java.util.stream.Collectors;


import com.splash.web.api.ApiServlet;

import com.splash.web.api.Json;
import com.splash.web.api.dto.AtualizarPerfilRequest;
import com.splash.web.db.DAOCliente;
import com.splash.web.model.Cliente;
import com.splash.web.api.dto.ClienteResumo;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.json.JSONObject;

/**
 * <pre>
 * GET   /api/v1/usuarios -> {id, nome, cpf, telefone, email}
 * PATCH /api/v1/usuarios {nome?, telefone?, email?}
 * </pre>
 *
 * TODO: implementar usando DAOCliente. Ver miscelaneous/analise-app-mobile.md, seção 3.5.
 */
@WebServlet("/api/v1/usuarios")
public class ClienteApiServlet extends ApiServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        // definição das variaveis utilizadas
        DAOCliente dao = new DAOCliente(); // Cria o objeto de DAO

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
            * Montar o DTO de resposta com os elementos da lista
            * */
            for(Cliente item:dao.getUsuarios()){
                ClienteResumo resumo = new ClienteResumo(
                        item.getId_cliente(), item.getNome(), item.getCpf(), item.getTelefone(), item.getEmail());

                String json = """
                        {
                            "id": %d,
                            "nome": %s,
                            "cpf": %s,
                            "email": %s,
                            "telefone": %s
                        }
                        """.formatted(
                        resumo.id(),
                        resumo.nome(),
                        resumo.cpf(),
                        resumo.email(),
                        resumo.telefone());

                Json.Response_enviar(response, HttpServletResponse.SC_OK ,json);
            }
        } catch (SQLException e) {
            Json.erro(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Um erro ocorreu no servidor da aplicação e a requisição não pode ser concluida");
        }
    }

    @Override
    protected void doPatch(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // TODO: DAOCliente.updateUsuarios(...)
        DAOCliente dao = new DAOCliente();

        try {

            String JsonMobile = request.getReader().lines().collect(Collectors.joining());
            JSONObject jsonObject = new JSONObject(JsonMobile); // instancia um JSONObject para lidar com o envio de requisições do mobile

            // Usa a DTO + JSONObject para receber as requisições do mobile. Os metodos "opt" são utilizados, pois nem todas as informações serão atualizadas sempre.
            AtualizarPerfilRequest perfil = new AtualizarPerfilRequest(
                    jsonObject.optString("nome", null), jsonObject.optString("telefone", null), jsonObject.optString("email", null));


            // Cria o cliente a ser editado. Aqui puxa direto do mobile.
            Cliente client = dao.getusuario(jsonObject.getInt("idcliente"));

            // Verifica quais informações foram preenchidas na DTO, ou seja, quais o mobile enviou.
            // Depois inclui esses valores em "Client"
            if(perfil.nome() != null) client.setNome(perfil.nome());
            if(perfil.telefone() != null) client.setTelefone(perfil.telefone());
            if(perfil.email() != null) client.setEmail(perfil.email());

            // depois, passa os valores para a DAO de atualização
            dao.updateUsuarios(client.getId_cliente(), client.getNome(), client.getTelefone(), client.getEmail());

            // Cria um json informando os dados atualizados
            ClienteResumo resumo = new ClienteResumo(
                    client.getId_cliente(),
                    client.getNome(),
                    client.getCpf(),
                    client.getTelefone(),
                    client.getEmail()
            );
            String json = """
                        {
                            "id": %d,
                            "nome": %s,
                            "cpf": %s,
                            "email": %s,
                            "telefone": %s
                        }
                        """.formatted(
                    resumo.id(),
                    resumo.nome(),
                    resumo.cpf(),
                    resumo.email(),
                    resumo.telefone());

            // por fim, manda o json para o mobile informando a atualização
            Json.Response_enviar(response, HttpServletResponse.SC_OK, json);

        } catch (SQLException e) {
            Json.erro(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Houve um erro interno na atualização");
        }
    }
}
