import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PrivacyPolicyDialog extends StatefulWidget {
  @override
  _PrivacyPolicyDialogState createState() {
    return new _PrivacyPolicyDialogState();
  }
}

class _PrivacyPolicyDialogState extends State<PrivacyPolicyDialog> {
  String privacy1 = "Recogida y tratamiento de datos de carácter personal";

  String privacyPart1a =
      "Los datos de carácter personal son los que pueden ser utilizados para identificar a una persona o ponerse en contacto con ella.";

  String privacyPart1b =
      "Podemos solicitar datos personales de usuarios al acceder a aplicaciones de la empresa o de otras empresas afiliadas así como la posibilidad de que entre estas empresas puedan compartir esos datos para mejorar los productos y servicios ofrecidos. Si no se facilitan esos datos personales, en muchos casos no podremos ofrecer los productos o servicios solicitados.";

  String privacyPart1c =
      "Estos son algunos ejemplos de las categorías de datos de carácter personal que XXEMPRESAXX puede recoger y la finalidad para los que puede llevar a cabo el tratamiento de estos datos.";

  String privacy2 = "¿Qué datos de carácter personal se pueden recopilar?";

  String privacyPart2a =
      "    -  Al crear un ID, solicitar un crédito comercial, comprar un producto, descargar una actualización de software, se recopilan diferentes datos, como nombre, dirección postal, número de teléfono, dirección de correo electrónico o los datos de la tarjeta de crédito.";

  String privacyPart2b =
      "    -  Cuando se comparten contenidos con familiares y amigos o se invita a otras personas a participar en los servicios o foros, pueden recogerse los datos que facilitamos sobre esas personas, como su nombre, domicilio, correo electrónico y número de teléfono. Se utilizarán dichos datos para completar sus pedidos, mostrarle el producto o servicio correspondiente o para combatir el fraude.";

  String privacy3 = "Propósito del tratamiento de datos de carácter personal";

  String privacyPart3a = "podremos utilizar los datos personales recabados para:";

  String privacyPart3b =
      "   -   Los datos de carácter personal recopilados permiten mantenerle informado acerca de los últimos productos, las actualizaciones de software disponibles y los próximos eventos.";

  String privacyPart3c =
      "   -   También se utilizan los datos de carácter personal como ayuda para elaborar, perfeccionar, gestionar, proporcionar y mejorar los productos, servicios, contenidos y publicidad, y con el propósito de evitar pérdidas y fraudes.";

  String privacyPart3d =
      "   -   Pueden utilizarse los datos de carácter personal para comprobar la identidad, colaborar en la identificación de usuarios y decidir los servicios apropiados.";

  String privacyPart3e =
      "   -   También se utilizan esos datos de carácter personal con propósitos internos, incluyendo auditorías, análisis de datos y sondeos, para mejorar los productos, servicios y comunicaciones a clientes.";

  String privacyPart3f =
      "   -   Si participa en un sorteo, un concurso o una promoción, pueden usarse los datos proporcionados para administrar estos programas.";

  String privacy4 = "Recopilación y tratamiento de datos de carácter no personal";

  String privacyPart4a =
      "También recopilaremos datos de un modo que, por sí mismos, no pueden ser asociados directamente a una persona determinada. Estos datos de carácter no personal se pueden recopilar, tratar, transferir y publicar con cualquier intención. Estos son algunos ejemplos de las clases de datos de carácter no personal que podemos recopilar y los fines para los que se realiza su tratamiento:";

  String privacyPart4b =
      "   -   Datos tales como profesión, idioma, código postal, identificador único de dispositivo, etc. para comprender mejor la conducta de nuestros clientes y mejorar nuestros productos, servicios y anuncios publicitarios.";

  String privacyPart4c =
      "   -   Datos sobre cómo se usan determinados servicios, incluidas las consultas de búsqueda. Esta información se puede utilizar para incrementar la importancia de los resultados que aportan los servicios ofrecidos.";

  String privacyPart4d =
      "   -   Datos sobre cómo usa su dispositivo y las aplicaciones para facilitar a los desarrolladores la mejora de esas aplicaciones.";

  String privacyPart4e =
      "Si juntamos datos de carácter no personal con datos personales, los datos mezclados serán tratados como datos personales mientras sigan estando combinados.";

  String privacy5 = "Divulgación a terceros";

  String privacyPart5a =
      "Ocasionalmente  podemos facilitar determinados datos de carácter personal a socios estratégicos que trabajen con nosotros para proveer productos y servicios o nos ayudan en nuestras actividades de marketing. No se compartirán los datos con ningún tercero para sus propios fines de marketing.";

  String privacy6 = "Proveedores de servicios";

  String privacyPart6a =
      "compartiremos datos de carácter personal con empresas que se ocupan, entre otras actividades, de prestar servicios de tratamiento de datos, conceder créditos, tramitar pedidos de clientes, presentar sus productos, mejorar datos de clientes, suministrar servicios de atención al cliente, evaluar su interés en productos y servicios y realizar investigaciones sobre clientes o su grado de satisfacción.";

  String privacy7 = "Otros terceros";

  String privacyPart7a =
      "Es posible que divulguemos datos de carácter personal por mandato legal, en el marco de un proceso judicial o por petición de una autoridad pública, tanto dentro como fuera de su país de residencia. Igualmente se puede publicar información personal si es necesaria oconveniente por motivos de seguridad nacional, para acatar la legislación vigente o por otras razones relevantes de orden público.";

  String privacy8 = "Protección de datos de carácter persona";

  String privacyPart8a =
      "Garantizaremos la protección de los datos personales mediante cifrado durante el tránsito y, los alojados en instalaciones, con medidas de seguridad físicas.";

  String privacyPart8b =
      "Al usar ciertos productos, servicios o aplicaciones o al publicar opiniones en foros, salas de chat o redes sociales, el contenido y los datos de carácter personal que se comparta serán visible para otros usuarios, que tendrán la posibilidad de leerlos, compilarlos o usarlos. Usted será responsable de los datos de carácter personal que distribuya o proporcione en estos casos.";

  String privacy9 = "Integridad y conservación de datos de carácter personal";

  String privacyPart9a =
      "Garantizaremos la exactitud y la calidad de los datos personales, se conservarán durante el tiempo necesario para cumplir los fines para los que fueron recabados, salvo que la ley exija conservarlos durante más tiempo.";

  String privacy10 = "Acceso a los datos de carácter personal";

  String privacyPart10a =
      "Respecto a los datos de carácter personal que conservamos, ofrecemos acceso a ellos para cualquier fin, incluyendo las solicitudes de rectificación en caso de que sean incorrectos o de eliminación en caso de no estar obligados a conservarlos por imperativo legal o por razones legítimas de negocio. Nos reservamos el derecho a no tramitar aquellas solicitudes que sean improcedentes o vejatorias, que pongan en riesgo la privacidad de terceros, que resulten inviables o para las que la legislación local no exija derecho de acceso. Las solicitudes de acceso, rectificación o eliminación podrán enviarse a nuestra cuenta de correo electrónico pabvazzam@gmail.com";

  String privacy11 = "Niños y educación";

  String privacyPart11a =
      "Somos consciente de la necesidad de establecer precauciones adicionales para preservar la privacidad y la seguridad de los menores que utilizan las aplicaciones y exigir consentimiento de sus progenitores en caso de que no tengan la edad mínima exigida por la legislación (en España, 14 años).";

  String privacyPart11b =
      "Si se han recopilado datos personales de un menor de 14 años, sin el consentimiento necesario, se debe eliminar esa información lo antes posible.";

  String privacy12 = "Servicios de localización";

  String privacyPart12a =
      "Para prestar servicios de localización podremos reunir, utilizar y compartir datos exactos sobre ubicaciones, incluyendo la situación geográfica en tiempo real de su ordenador o de su dispositivo. Salvo que nos den su consentimiento, estos datos de localización se recogen de manera anónima de forma que no pueden utilizarse para identificarlo personalmente, y son usados para suministrar y mejorar sus productos y servicios de localización.";

  String privacy13 = "Páginas web y servicios de terceros";

  String privacyPart13a =
      "Las aplicaciones pueden contener enlaces a páginas web, productos y servicios de terceros. También pueden utilizar u ofrecer productos o servicios de terceros. La recogida de datos por parte de terceros, introduciendo de datos sobre ubicaciones geográficas o datos de contacto, se guiará por sus respectivas políticas de privacidad. Le recomendamos consultar las políticas de privacidad de esos terceros.";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        child: Scaffold(
            appBar: new AppBar(
              title: const Text('Política de Privacidad'),
            ),
            backgroundColor: Colors.white,
            body: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 30),
                child: Container(
                  margin: EdgeInsets.only(top: 4.0),
                  child: Column(
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(top: 8.0, bottom: 4.0),
                        child: Text(
                          privacy1,
                          style: TextStyle(fontSize: 18.0),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 4.0, bottom: 4.0),
                        child: Text(
                          privacyPart1a,
                          style: TextStyle(fontSize: 14.0),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 4.0, bottom: 4.0),
                        child: Text(
                          privacyPart1b,
                          style: TextStyle(fontSize: 14.0),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 4.0, bottom: 4.0),
                        child: Text(
                          privacyPart1c,
                          style: TextStyle(fontSize: 14.0),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 8.0, bottom: 4.0),
                        child: Text(
                          privacy2,
                          style: TextStyle(fontSize: 18.0),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 4.0, bottom: 4.0),
                        child: Text(
                          privacyPart2a,
                          style: TextStyle(fontSize: 14.0),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 4.0, bottom: 4.0),
                        child: Text(
                          privacyPart2b,
                          style: TextStyle(fontSize: 14.0),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 8.0, bottom: 4.0),
                        child: Text(
                          privacy3,
                          style: TextStyle(fontSize: 18.0),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 4.0, bottom: 4.0),
                        child: Text(
                          privacyPart3a,
                          style: TextStyle(fontSize: 14.0),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 4.0, bottom: 4.0),
                        child: Text(
                          privacyPart3b,
                          style: TextStyle(fontSize: 14.0),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 4.0, bottom: 4.0),
                        child: Text(
                          privacyPart3c,
                          style: TextStyle(fontSize: 14.0),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 4.0, bottom: 4.0),
                        child: Text(
                          privacyPart3d,
                          style: TextStyle(fontSize: 14.0),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 4.0, bottom: 4.0),
                        child: Text(
                          privacyPart3e,
                          style: TextStyle(fontSize: 14.0),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 4.0, bottom: 4.0),
                        child: Text(
                          privacyPart3f,
                          style: TextStyle(fontSize: 14.0),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 8.0, bottom: 4.0),
                        child: Text(
                          privacy4,
                          style: TextStyle(fontSize: 18.0),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 4.0, bottom: 4.0),
                        child: Text(
                          privacyPart4a,
                          style: TextStyle(fontSize: 14.0),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 4.0, bottom: 4.0),
                        child: Text(
                          privacyPart4b,
                          style: TextStyle(fontSize: 14.0),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 4.0, bottom: 4.0),
                        child: Text(
                          privacyPart4c,
                          style: TextStyle(fontSize: 14.0),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 4.0, bottom: 4.0),
                        child: Text(
                          privacyPart4d,
                          style: TextStyle(fontSize: 14.0),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 4.0, bottom: 4.0),
                        child: Text(
                          privacyPart4e,
                          style: TextStyle(fontSize: 14.0),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 8.0, bottom: 4.0),
                        child: Text(
                          privacy5,
                          style: TextStyle(fontSize: 18.0),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 4.0, bottom: 4.0),
                        child: Text(
                          privacyPart5a,
                          style: TextStyle(fontSize: 14.0),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 8.0, bottom: 4.0),
                        child: Text(
                          privacy6,
                          style: TextStyle(fontSize: 18.0),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 4.0, bottom: 4.0),
                        child: Text(
                          privacyPart6a,
                          style: TextStyle(fontSize: 14.0),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 8.0, bottom: 4.0),
                        child: Text(
                          privacy7,
                          style: TextStyle(fontSize: 18.0),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 4.0, bottom: 4.0),
                        child: Text(
                          privacyPart7a,
                          style: TextStyle(fontSize: 14.0),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 8.0, bottom: 4.0),
                        child: Text(
                          privacy8,
                          style: TextStyle(fontSize: 18.0),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 4.0, bottom: 4.0),
                        child: Text(
                          privacyPart8a,
                          style: TextStyle(fontSize: 14.0),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 4.0, bottom: 4.0),
                        child: Text(
                          privacyPart8b,
                          style: TextStyle(fontSize: 14.0),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 8.0, bottom: 4.0),
                        child: Text(
                          privacy9,
                          style: TextStyle(fontSize: 18.0),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 4.0, bottom: 4.0),
                        child: Text(
                          privacyPart9a,
                          style: TextStyle(fontSize: 14.0),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 8.0, bottom: 4.0),
                        child: Text(
                          privacy10,
                          style: TextStyle(fontSize: 18.0),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 4.0, bottom: 4.0),
                        child: Text(
                          privacyPart10a,
                          style: TextStyle(fontSize: 14.0),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 8.0, bottom: 4.0),
                        child: Text(
                          privacy11,
                          style: TextStyle(fontSize: 18.0),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 4.0, bottom: 4.0),
                        child: Text(
                          privacyPart11a,
                          style: TextStyle(fontSize: 14.0),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 4.0, bottom: 4.0),
                        child: Text(
                          privacyPart11b,
                          style: TextStyle(fontSize: 14.0),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 8.0, bottom: 4.0),
                        child: Text(
                          privacy12,
                          style: TextStyle(fontSize: 18.0),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 4.0, bottom: 4.0),
                        child: Text(
                          privacyPart12a,
                          style: TextStyle(fontSize: 14.0),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 8.0, bottom: 4.0),
                        child: Text(
                          privacy13,
                          style: TextStyle(fontSize: 18.0),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 4.0, bottom: 8.0),
                        child: Text(
                          privacyPart13a,
                          style: TextStyle(fontSize: 14.0),
                        ),
                      ),
                    ],
                  ),
                ))));
  }
}
