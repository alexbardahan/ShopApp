class HttpException implements Exception {
  //it implements all the methods of Exception class
  final String message;
  HttpException(this.message);

  @override
  String toString() {
    // TODO: implement toString
    return message;
    // return super.toString();//instace of HttpException
  }
}
