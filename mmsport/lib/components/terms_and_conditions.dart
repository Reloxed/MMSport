import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:mmsport/components/dialogs.dart';
import 'package:mmsport/components/form_validators.dart';
import 'package:mmsport/navigations/navigations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TermsAndConditionsDialog extends StatefulWidget {
  @override
  _TermsAndConditionsDialogState createState() {
    return new _TermsAndConditionsDialogState();
  }
}

class _TermsAndConditionsDialogState extends State<TermsAndConditionsDialog> {

  String termsAndConditions1 = "1. Estos Términos y Condiciones de Uso regulan las reglas a que se sujeta la utilización de la APP MMSport, que puede descargarse desde las plataformas Apple Store o Play Store. La descarga o utilización de la APP atribuye la condición de Usuario a quien lo haga e implica la aceptación de todas las condiciones incluidas en este documento y en la Política de Privacidad y el Aviso Legal de dicha página Web. El Usuario debería leer estas condiciones cada vez que utilice la APP, ya que podrían ser modificadas en lo sucesivo.";

  String termsAndConditions2 = "2. Únicamente los Usuarios expresamente autorizados por ambas plataformas mencionadas anteriormente podrán acceder a la descarga y uso de la APP. Los Usuarios que no dispongan de autorización, no podrán acceder a dicho contenido.";

  String termsAndConditions3 = "3. Cargos: eres responsable del pago de todos los costes o gastos en los que incurras como resultado de descargar y usar la Aplicación de Pablo Vázquez Zambrano y Antonio Montaño Aguilera, incluido cualquier cargo de red de operador o itinerancia. Consulta con tu proveedor de servicios los detalles al respecto.";

  String termsAndConditions4 = "4. Estadísticas anónimas: nos reservamos el derecho a realizar un seguimiento de tu actividad en la Aplicación de y a informar de ello a nuestros proveedores de servicios estadísticos de terceros. Todo ello de forma anónima.";

  String termsAndConditions5 = "5. Protección de tu información personal: queremos ayudarte a llevar a cabo todos los pasos necesarios para proteger tu privacidad e información. Consulta nuestra Política de privacidad y los avisos sobre privacidad de la Aplicación para conocer qué tipo de información recopilamos y las medidas que tomamos para proteger tu información personal.";

  String termsAndConditions6 = "6. Queda prohibido alterar o modificar ninguna parte de la APP a de los contenidas de la misma, eludir, desactivar o manipular de cualquier otra forma (o tratar de eludir, desactivar o manipular) las funciones de seguridad u otras funciones del programa y utilizar la APP o sus contenidos para un fin comercial o publicitario. Queda prohibido el uso de la APP con la finalidad de lesionar bienes, derechos o intereses nuestros o de terceros. Queda igualmente prohibido realizar cualquier otro uso que altere, dañe o inutilice las redes, servidores, equipos, productos y programas informáticos nuestros o de terceros.";

  String termsAndConditions7 = "7. La APP y sus contenidos (textos, fotografías, gráficos, imágenes, tecnología, software, links, contenidos, diseño gráfico, código fuente, etc.), así como las marcas y demás signos distintivos son propiedad nuestra o de terceros, no adquiriendo el Usuario ningún derecho sobre ellos por el mero uso de la APP. El Usuario, deberá abstenerse de:";

  String termsAndConditions7_1 = "    a. Reproducir, copiar, distribuir, poner a disposición de terceros, comunicar públicamente, transformar o modificar la APP o sus contenidos, salvo en los casos contemplados en la ley o expresamente autorizados por nosotros o por el titular de dichos derechos.";

  String termsAndConditions7_2 = "    b. Reproducir o copiar para uso privado la APP o sus contenidos, así como comunicarlos públicamente o ponerlos a disposición de terceros cuando ello conlleve su reproducción.";

  String termsAndConditions7_3 = "    c. Extraer o reutilizar todo o parte sustancial de los contenidos integrantes de la APP.";

  String termsAndConditions8 = "8. Con sujeción a las condiciones establecidas en el apartado anterior, concedemos al Usuario una licencia de uso de la APP, no exclusiva, gratuita, para uso personal, circunscrita al territorio nacional y con carácter indefinido. Dicha licencia se concede también en los mismos términos con respecto a las actualizaciones y mejoras que se realizasen en la aplicación. Dichas licencias de uso podrán ser revocadas por nosotros unilateralmente en cualquier momento, mediante la mera notificación al Usuario.";

  String termsAndConditions9 = "9. Corresponde al Usuario, en todo caso, disponer de herramientas adecuadas para la detección y desinfección de programas maliciosos o cualquier otro elemento informático dañino. No nos responsabilizamos de los daños producidos a equipos informáticos durante el uso de la APP. Igualmente, no seremos responsables de los daños producidos a los Usuarios cuando dichos daños tengan su origen en fallos o desconexiones en las redes de telecomunicaciones que interrumpan el servicio.";

  String termsAndConditions10 = "10. IMPORTANTE: Podemos, sin que esto suponga ninguna obligación contigo, modificar estas Condiciones de uso sin avisar en cualquier momento. Si continúas utilizando la aplicación una vez realizada cualquier modificación en estas Condiciones de uso, esa utilización continuada constituirá la aceptación por tu parte de tales modificaciones. Si no aceptas estas condiciones de uso ni aceptas quedar sujeto a ellas, no debes utilizar la aplicación ni descargar o utilizar cualquier software relacionado. El uso que hagas de la aplicación queda bajo tu única responsabilidad. No tenemos responsabilidad alguna por la eliminación o la incapacidad de almacenar o trasmitir cualquier contenido u otra información mantenida o trasmitida por la aplicación. No somos responsables de la precisión o la fiabilidad de cualquier información o consejo trasmitidos a través de la aplicación. Podemos, en cualquier momento, limitar o interrumpir tu uso a nuestra única discreción. Hasta el máximo que permite la ley, en ningún caso seremos responsables por cualquier pérdida o daño relacionados.";

  String termsAndConditions11 = "11. El Usuario se compromete a hacer un uso correcto de la APP, de conformidad con la Ley, con los presentes Términos y Condiciones de Uso y con las demás reglamentos e instrucciones que, en su caso, pudieran ser de aplicación El Usuario responderá frente a nosotros y frente a terceros de cualesquiera daños o perjuicios que pudieran causarse por incumplimiento de estas obligaciones.";

  String termsAndConditions12 = "12. Estos Términos y Condiciones de Uso se rigen íntegramente por la legislación española. Para la resolución de cualquier conflicto relativo a su interpretación o aplicación, el Usuario se somete expresamente a la jurisdicción de los tribunales de España.";

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
                child:  Container(
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
                )
                )));
  }
}
