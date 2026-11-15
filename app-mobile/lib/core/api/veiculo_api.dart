import 'dart:convert';

import 'package:flash_splash/core/api/api_client.dart';
import 'package:flash_splash/core/api/api_exception.dart';
import 'package:flash_splash/core/api/model/veiculoModel.dart';

/// Veículos do cliente logado. O servidor identifica o cliente pela sessão (cookie):
/// nenhuma chamada recebe ou envia o id do cliente.
class VeiculoApi {
  final APIClient apiClient;

  VeiculoApi({required this.apiClient});

  /// `GET /veiculos`.
  Future<List<VeiculoModel>> listar() => comTratamentoDeRede(() async {
        final resposta = await apiClient.get('/veiculos');
        if (resposta.statusCode != 200) throw ApiException.deResposta(resposta);
        final lista = jsonDecode(utf8.decode(resposta.bodyBytes)) as List<dynamic>;
        return [for (final item in lista) VeiculoModel.fromJson(item as Map<String, dynamic>)];
      });

  /// `POST /veiculos` (201). A resposta não traz o id do veículo novo: chame [listar] de novo.
  /// Erros: 409 placa já cadastrada, 422 dado inválido.
  Future<void> cadastrar({
    required String placa,
    required String marca,
    required String modelo,
    required String cor,
  }) =>
      comTratamentoDeRede(() async {
        final resposta = await apiClient.post('/veiculos', body: {
          'placa': placa,
          'marca': marca,
          'modelo': modelo,
          'cor': cor,
        });
        if (resposta.statusCode != 201) throw ApiException.deResposta(resposta);
      });

  /// `DELETE /veiculos/{id}` (200). 404 se o veículo não for do cliente logado.
  Future<void> excluir(String idVeiculo) => comTratamentoDeRede(() async {
        final resposta = await apiClient.delete('/veiculos/$idVeiculo');
        if (resposta.statusCode != 200) throw ApiException.deResposta(resposta);
      });
}
