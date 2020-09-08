import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TermsAndConditionsDialog extends StatefulWidget {
  @override
  _TermsAndConditionsDialogState createState() {
    return new _TermsAndConditionsDialogState();
  }
}

class _TermsAndConditionsDialogState extends State<TermsAndConditionsDialog> {
  String termsAndConditions1 =
      "1. Estos Términos y Condiciones de Uso regulan las reglas a que se sujeta la utilización de la APP MMSport, que puede descargarse desde las plataformas Apple Store o Play Store. La descarga o utilización de la APP atribuye la condición de Usuario a quien lo haga e implica la aceptación de todas las condiciones incluidas en este documento y en la Política de Privacidad y el Aviso Legal de dicha página Web. El Usuario debería leer estas condiciones cada vez que utilice la APP, ya que podrían ser modificadas en lo sucesivo.";

  String termsAndConditions2 =
      "2. Únicamente los Usuarios expresamente autorizados por ambas plataformas mencionadas anteriormente podrán acceder a la descarga y uso de la APP. Los Usuarios que no dispongan de autorización, no podrán acceder a dicho contenido.";

  String termsAndConditions3 =
      "3. Cargos: eres responsable del pago de todos los costes o gastos en los que incurras como resultado de descargar y usar la Aplicación de Pablo Vázquez Zambrano y Antonio Montaño Aguilera, incluido cualquier cargo de red de operador o itinerancia. Consulta con tu proveedor de servicios los detalles al respecto.";

  String termsAndConditions4 =
      "4. Estadísticas anónimas: nos reservamos el derecho a realizar un seguimiento de tu actividad en la Aplicación de y a informar de ello a nuestros proveedores de servicios estadísticos de terceros. Todo ello de forma anónima.";

  String termsAndConditions5 =
      "5. Protección de tu información personal: queremos ayudarte a llevar a cabo todos los pasos necesarios para proteger tu privacidad e información. Consulta nuestra Política de privacidad y los avisos sobre privacidad de la Aplicación para conocer qué tipo de información recopilamos y las medidas que tomamos para proteger tu información personal.";

  String termsAndConditions6 =
      "6. Queda prohibido alterar o modificar ninguna parte de la APP a de los contenidas de la misma, eludir, desactivar o manipular de cualquier otra forma (o tratar de eludir, desactivar o manipular) las funciones de seguridad u otras funciones del programa y utilizar la APP o sus contenidos para un fin comercial o publicitario. Queda prohibido el uso de la APP con la finalidad de lesionar bienes, derechos o intereses nuestros o de terceros. Queda igualmente prohibido realizar cualquier otro uso que altere, dañe o inutilice las redes, servidores, equipos, productos y programas informáticos nuestros o de terceros.";

  String termsAndConditions7 =
      "7. La APP y sus contenidos (textos, fotografías, gráficos, imágenes, tecnología, software, links, contenidos, diseño gráfico, código fuente, etc.), así como las marcas y demás signos distintivos son propiedad nuestra o de terceros, no adquiriendo el Usuario ningún derecho sobre ellos por el mero uso de la APP. El Usuario, deberá abstenerse de:";

  String termsAndConditions7_1 =
      "    a. Reproducir, copiar, distribuir, poner a disposición de terceros, comunicar públicamente, transformar o modificar la APP o sus contenidos, salvo en los casos contemplados en la ley o expresamente autorizados por nosotros o por el titular de dichos derechos.";

  String termsAndConditions7_2 =
      "    b. Reproducir o copiar para uso privado la APP o sus contenidos, así como comunicarlos públicamente o ponerlos a disposición de terceros cuando ello conlleve su reproducción.";

  String termsAndConditions7_3 =
      "    c. Extraer o reutilizar todo o parte sustancial de los contenidos integrantes de la APP.";

  String termsAndConditions8 =
      "8. Con sujeción a las condiciones establecidas en el apartado anterior, concedemos al Usuario una licencia de uso de la APP, no exclusiva, gratuita, para uso personal, circunscrita al territorio nacional y con carácter indefinido. Dicha licencia se concede también en los mismos términos con respecto a las actualizaciones y mejoras que se realizasen en la aplicación. Dichas licencias de uso podrán ser revocadas por nosotros unilateralmente en cualquier momento, mediante la mera notificación al Usuario.";

  String termsAndConditions9 =
      "9. Corresponde al Usuario, en todo caso, disponer de herramientas adecuadas para la detección y desinfección de programas maliciosos o cualquier otro elemento informático dañino. No nos responsabilizamos de los daños producidos a equipos informáticos durante el uso de la APP. Igualmente, no seremos responsables de los daños producidos a los Usuarios cuando dichos daños tengan su origen en fallos o desconexiones en las redes de telecomunicaciones que interrumpan el servicio.";

  String termsAndConditions10 =
      "10. IMPORTANTE: Podemos, sin que esto suponga ninguna obligación contigo, modificar estas Condiciones de uso sin avisar en cualquier momento. Si continúas utilizando la aplicación una vez realizada cualquier modificación en estas Condiciones de uso, esa utilización continuada constituirá la aceptación por tu parte de tales modificaciones. Si no aceptas estas condiciones de uso ni aceptas quedar sujeto a ellas, no debes utilizar la aplicación ni descargar o utilizar cualquier software relacionado. El uso que hagas de la aplicación queda bajo tu única responsabilidad. No tenemos responsabilidad alguna por la eliminación o la incapacidad de almacenar o trasmitir cualquier contenido u otra información mantenida o trasmitida por la aplicación. No somos responsables de la precisión o la fiabilidad de cualquier información o consejo trasmitidos a través de la aplicación. Podemos, en cualquier momento, limitar o interrumpir tu uso a nuestra única discreción. Hasta el máximo que permite la ley, en ningún caso seremos responsables por cualquier pérdida o daño relacionados.";

  String termsAndConditions11 =
      "11. El Usuario se compromete a hacer un uso correcto de la APP, de conformidad con la Ley, con los presentes Términos y Condiciones de Uso y con las demás reglamentos e instrucciones que, en su caso, pudieran ser de aplicación El Usuario responderá frente a nosotros y frente a terceros de cualesquiera daños o perjuicios que pudieran causarse por incumplimiento de estas obligaciones.";

  String termsAndConditions12 =
      "12. Estos Términos y Condiciones de Uso se rigen íntegramente por la legislación española. Para la resolución de cualquier conflicto relativo a su interpretación o aplicación, el Usuario se somete expresamente a la jurisdicción de los tribunales de España.";

  String privacyTitle = "Política de Privacidad";

  String privacy1 =
      "La información que tienen la obligación de incluir las apps en su política de privacidad debe ser lo más clara y completa posible. Un ejemplo de política de privacidad utilizada en aplicaciones debería incluir los siguientes apartados:";

  String privacyPart1 = "Recogida y tratamiento de datos de carácter personal";

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
              title: const Text('Términos y Condiciones'),
            ),
            backgroundColor: Colors.white,
            body: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 30),
                child: Container(
                  margin: EdgeInsets.only(top: 4.0),
                  child: Column(
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 4.0),
                        child: Text(termsAndConditions1),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 4.0),
                        child: Text(termsAndConditions2),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 4.0),
                        child: Text(termsAndConditions3),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 4.0),
                        child: Text(termsAndConditions4),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 4.0),
                        child: Text(termsAndConditions5),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 4.0),
                        child: Text(termsAndConditions6),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 4.0),
                        child: Text(termsAndConditions7),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 4.0),
                        child: Text(termsAndConditions7_1),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 4.0),
                        child: Text(termsAndConditions7_2),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 4.0),
                        child: Text(termsAndConditions7_3),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 4.0),
                        child: Text(termsAndConditions8),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 4.0),
                        child: Text(termsAndConditions9),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 4.0),
                        child: Text(termsAndConditions10),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 4.0),
                        child: Text(termsAndConditions11),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 4.0),
                        child: Text(termsAndConditions12),
                      ),
                    ],
                  ),
                ))));
  }
}
