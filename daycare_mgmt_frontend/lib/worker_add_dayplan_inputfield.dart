import 'package:daycare_mgmt_frontend/worker_dayplan_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

// add dayplan input field for worker side when they want to add a dayplan item
class MyInputField extends StatelessWidget {
  final String title_d;
  final String hint_d;
  final TextEditingController? controler;
  final Widget? widget_d;
  const MyInputField(
      {Key? key,
      required this.title_d,
      required this.hint_d,
      this.controler,
      this.widget_d})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title_d, style: titleStyle),
          Container(
              height: 52,
              margin: EdgeInsets.only(top: 8),
              padding: EdgeInsets.only(left: 14),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey, width: 1.0),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      validator: (value) {
                        if (title_d == "* Date" ||
                            title_d == "* Start Time" ||
                            title_d == "* End Time") {
                          return null;
                        }
                        if (value == null || value.isEmpty) {
                          return 'Please enter a value';
                        }
                        return null;
                      },
                      readOnly: widget_d == null ? false : true,
                      autofocus: false,
                      cursorColor: Colors.grey[700],
                      controller: controler,
                      style: subTitleStyle,
                      decoration: InputDecoration(
                        hintText: hint_d,
                        hintStyle: subTitleStyle,
                        focusedBorder: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.white, width: 0.0),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.white, width: 0.0),
                        ),
                      ),
                    ),
                  ),
                  widget_d == null ? Container() : Container(child: widget_d),
                ],
              ))
        ],
      ),
    );
  }
}
