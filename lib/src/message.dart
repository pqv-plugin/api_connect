/// Registra as mensagens que devem ser apresentadas para o usuário durante a coneção com microserviços
///
/// error - Mensagem apresentada para o usuário no caso de erro
/// erogress - Mensagem apresentada enquanto existe uma conexão com o serviço
/// success - Mensagem apresentada no término da conexão
class Message {
  final String error;
  String success;
  String progress;

  Message({
    this.error = 'Houve um erro conectando microserviço',
    this.success = 'Conexão com microserviço ocorreu com sucesso',
    this.progress = 'Conectando microserviço',
  });

  @override
  String toString() {
    return 'Instance of Message(error:$error, success:$success, progress:$progress)';
  }
}
