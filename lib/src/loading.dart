/// Objeto usado para informar se existe uma conexão estabelecida com o servidor de microserviços
///
/// message - Texto apresentado ao usuário durante a conexão
/// isConnect - Indica se existe uma conexão estabelecida com o servidor de microserviço
class Loading {
  final String message;
  final bool isConnect;

  Loading({required this.message, required this.isConnect});
}
