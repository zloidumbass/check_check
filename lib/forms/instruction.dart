import 'package:flutter/material.dart';

import '../module_common.dart';

class InstructionPage extends StatefulWidget {
  @override
  InstructionPageState createState() {
    return new InstructionPageState();
  }
}

class InstructionPageState extends State<InstructionPage> {
  @override
  Widget build(BuildContext context) {
    return CreateDefaultMasterForm(0, getBody(), context, null);
  }

  Widget getBody() {
    return ListView(children: [
      Padding(
        padding: EdgeInsets.all(20),
        child: Text("ГСМ ЧЕКИ",
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center),
      ),
      Padding(
          padding: EdgeInsets.all(10),
          child: RichText(
              textAlign: TextAlign.left,
              text: TextSpan(
                  style: TextStyle(color: Colors.black),
                  children: <TextSpan>[
                    TextSpan(
                        text: "Отчет по ЧЕКАМ (ЗА НАЛИЧНЫЕ) ",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    //тут переопределяем общий цвет
                    TextSpan(
                        text:
                            "– это отчет, который предоставляется Торговым представителем, если он заправлялся за собственные наличные/безналичные денежные средства, по которым ему необходима компенсация денежных средств.")
                  ]))),
      Padding(
        padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
        child: Text(
          " В комплект документов по отчету по чекам (за наличные) входят:",
          style: TextStyle(fontWeight: FontWeight.bold),
          textAlign: TextAlign.left,
        ),
      ),
      Padding(
        padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
        child: Text(
          "  1. Сканы кассовых чеков (или фото хорошего качества);",
          textAlign: TextAlign.left,
        ),
      ),
      Padding(
        padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
        child: Text(
          "  2. Путевой лист «ГСМ ЧЕКИ (НАЛИЧНЫЕ)» - заполненный согласно чекам",
          textAlign: TextAlign.left,
        ),
      ),
      Padding(
        padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
        child: Text(
          "  3. В комплект документов по отчету по чекам (за наличные) входят:",
          textAlign: TextAlign.left,
        ),
      ),
      Padding(
          padding: EdgeInsets.all(10),
          child: RichText(
              textAlign: TextAlign.left,
              text: TextSpan(
                  style: TextStyle(color: Colors.black),
                  children: <TextSpan>[
                    TextSpan(
                        text: "ВАЖНО! ",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    //тут переопределяем общий цвет
                    TextSpan(
                        text:
                            "Обязательные к заполнению ячейки/столбцы в Путевом листе и Реестре имеют примечания (отображаются при наведении мыши). На картинке «Пример заполнения ПЛ по чекам» выделены блоки, информация в которых подлежит заполнению в обязательном порядке.",
                        style: TextStyle(fontStyle: FontStyle.italic))
                  ]))),
      Padding(
        padding: EdgeInsets.all(10),
        child: Text(
          "Документы, которые не входят в перечисленный выше список, в отчет по чекам (за наличные) включать НЕ НУЖНО.",
          style: TextStyle(fontWeight: FontWeight.bold),
          textAlign: TextAlign.left,
        ),
      ),
      Padding(
          padding: EdgeInsets.all(10),
          child: RichText(
              textAlign: TextAlign.left,
              text: TextSpan(
                  style: TextStyle(color: Colors.black),
                  children: <TextSpan>[
                    TextSpan(
                        text: "ВАЖНО! ",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    //тут переопределяем общий цвет
                    TextSpan(
                        text:
                            "Отчет по чекам (за наличные) предоставляется сотрудником ОТДЕЛЬНОЙ ЗАЯВКОЙ от отчета по топливным картам. Перед отправкой отчет должен быть проверен на наличие ошибок.",
                        style: TextStyle(fontStyle: FontStyle.italic))
                  ]))),
      Padding(
          padding: EdgeInsets.all(10),
          child: RichText(
              textAlign: TextAlign.left,
              text: TextSpan(
                  style: TextStyle(color: Colors.black),
                  children: <TextSpan>[
                    TextSpan(
                        text:
                            "В путевой лист по чекам (за наличные) вносятся данные по поездкам и заправкам, совершенным "),
                    TextSpan(
                        text:
                            "ТОЛЬКО ЗА СОБСТВЕННЫЕ НАЛИЧНЫЕ/БЕЗНАЛИЧНЫЕ ДЕНЕЖНЫЕ СРЕДСТВА",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    //тут переопределяем общий цвет
                    TextSpan(text: " сотрудника.")
                  ]))),
      Padding(
        padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
        child: Text(
          "Правила заполнения путевого листа по чекам (за наличные):",
          style: TextStyle(fontWeight: FontWeight.bold),
          textAlign: TextAlign.left,
        ),
      ),
      Padding(
        padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
        child: Text(
          "1. Дата в шапке документа: указывается 1е число отчетного периода. Не правильно указывать конец месяца или период «1- 30»! Если сотрудник сдает свой первый отчет за тот месяц, в котором он был трудоустроен, то в шапке документа он указывает ДАТУ ТРУДОУСТРОЙСТВА.",
          textAlign: TextAlign.left,
        ),
      ),
      Padding(
        padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
        child: Text(
          "2. ФИО указывается в формате: Борисов Борис Борисович или Борисов Б.Б. Напоминаем, что имена собственные пишутся с большой буквы.",
          textAlign: TextAlign.left,
        ),
      ),
      Padding(
        padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
        child: Text(
          "3. Норма расхода топлива: Лето (апрель-сентябрь) – 10 л./100 км. Осень (октябрь-март) – 11 л./100 км.",
          textAlign: TextAlign.left,
        ),
      ),
      Padding(
        padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
        child: Text(
          "4. Точно по данным в кассовых чеках заполняются следующие графы путевого листа (за наличные): Номер чека по порядку, Дата заправки, Количество заправленных литров, Общая сумма по чеку в каждую дату.",
          textAlign: TextAlign.left,
        ),
      ),
      Padding(
        padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
        child: Text(
          "5. В путевом листе по чекам (за наличные) не должно быть данных по заправкам по топливным картам.",
          textAlign: TextAlign.left,
        ),
      ),
      Padding(
        padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
        child: Text(
          "6. Если 1-ю часть отчетного периода сотрудник заправлялся по топливной карте и 2ю часть отчетного периода заправлялся по чекам – необходимо предоставить 2 отчета с разными путевыми листами. В ПЛ по чекам и в ПЛ по топливным картам указываются разные пробеги, что в сумме составит один общий пробег по всему периоду. ",
          textAlign: TextAlign.left,
        ),
      ),
      Padding(
        padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
        child: Text(
          "Правила заполнения реестра по чекам (за наличные):",
          style: TextStyle(fontWeight: FontWeight.bold),
          textAlign: TextAlign.left,
        ),
      ),
      Padding(
        padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
        child: Text(
          "1. На каждого сотрудника заполняется отдельный реестр. Реестр должен быть направлен в ЭЛЕКТРОННОМ ВИДЕ.",
          textAlign: TextAlign.left,
        ),
      ),
      Padding(
        padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
        child: Text(
          "2. В реестре обязательно должны быть внесены следующие данные: ФИО, расход по чекам руб., количество литров по чекам и пробег по путевому листу. Средняя стоимость литра рассчитывается автоматически по внесенной формуле.",
          textAlign: TextAlign.left,
        ),
      ),
      Padding(
        padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
        child: Text(
          "3. ФИО вносится целиком и без ошибок в формате: Борисов Борис Борисович.",
          textAlign: TextAlign.left,
        ),
      ),
      Padding(
        padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
        child: Text(
          "4. Данные по сумме расхода в рублях вносятся из итогов путевого листа (по всем кассовым чекам по заправкам за наличные).",
          textAlign: TextAlign.left,
        ),
      ),
      Padding(
        padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
        child: Text(
          "5. Данные по литражу вносятся из итогов путевого листа (по всем кассовым чекам по заправкам за наличные).",
          textAlign: TextAlign.left,
        ),
      ),
      Padding(
        padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
        child: Text(
          "6. Данные по средней стоимости литра рассчитываются исходя из суммы расхода по чекам в рублях деленым на количество приобретенного топлива в литрах по чекам за наличные.",
          textAlign: TextAlign.left,
        ),
      ),
      Padding(
        padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
        child: Text(
          "7. Данные о пройденном километраже вносятся из путевого листа по чекам (за наличные).",
          textAlign: TextAlign.left,
        ),
      ),
      Padding(
        padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
        child: Text(
          "Формат предоставляемых документов:",
          style: TextStyle(fontWeight: FontWeight.bold),
          textAlign: TextAlign.left,
        ),
      ),
      Padding(
        padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
        child: Text(
          "1. Скан ПЛ и чеков: полностью читаемое четкое изображение.",
          textAlign: TextAlign.left,
        ),
      ),
      Padding(
        padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
        child: Text(
          "2. Фото ПЛ и чеков хорошего качества: полностью читаемое четкое изображение. ",
          textAlign: TextAlign.left,
        ),
      ),
      Padding(
        padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
        child: Text(
          "3. Электронный формат путевого листа в «excel» (если нет возможности предоставить ПЛ в выше указанных форматах). ",
          textAlign: TextAlign.left,
        ),
      ),
      Padding(
        padding: EdgeInsets.fromLTRB(10, 5, 10, 0),
        child: Text(
          "Если ПЛ заполнены сотрудниками от руки – почерк должен быть читаемый и разборчивый.",
          textAlign: TextAlign.left,
        ),
      ),
      Padding(
        padding: EdgeInsets.fromLTRB(10, 5, 10, 10),
        child: Text(
          "Убедительно просим не высылать фото, сделанные в темноте, а также фото мятых документов. ",
          textAlign: TextAlign.left,
        ),
      ),
    ]);
  }
}
