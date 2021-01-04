import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_html/style.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../controllers/filter_controller.dart';
import '../elements/CircularLoadingWidget.dart';
import '../models/filter.dart';

class FilterWidget extends StatefulWidget {
  final ValueChanged<Filter> onFilter;

  FilterWidget({Key key, this.onFilter}) : super(key: key);

  @override
  _FilterWidgetState createState() => _FilterWidgetState();
}

class _FilterWidgetState extends StateMVC<FilterWidget> {
  FilterController _con;
  List<String> selectedCuisines;
  String urlCusineImg;
  String cusineName;

  _FilterWidgetState() : super(FilterController()) {
    _con = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(S.of(context).filter),
                  MaterialButton(
                    onPressed: () {
                      _con.clearFilter();
                    },
                    child: Text(
                      S.of(context).clear,
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              child: ListView(
                primary: true,
                shrinkWrap: true,
                children: <Widget>[
                  ExpansionTile(
                    title: Text(S.of(context).delivery_or_pickup),
                    children: [
                      CheckboxListTile(
                        controlAffinity: ListTileControlAffinity.trailing,
                        value: _con.filter?.delivery ?? false,
                        onChanged: (value) {
                          setState(() {
                            _con.filter?.delivery = true;
                          });
                        },
                        title: Text(
                          S.of(context).delivery,
                          overflow: TextOverflow.fade,
                          softWrap: false,
                          maxLines: 1,
                        ),
                      ),
                      CheckboxListTile(
                        controlAffinity: ListTileControlAffinity.trailing,
                        value: _con.filter?.delivery ?? false ? false : true,
                        onChanged: (value) {
                          setState(() {
                            _con.filter?.delivery = false;
                          });
                        },
                        title: Text(
                          S.of(context).pickup,
                          overflow: TextOverflow.fade,
                          softWrap: false,
                          maxLines: 1,
                        ),
                      ),
                    ],
                    initiallyExpanded: true,
                  ),
                  ExpansionTile(
                    title: Text(S.of(context).opened_restaurants),
                    children: [
                      CheckboxListTile(
                        controlAffinity: ListTileControlAffinity.trailing,
                        value: _con.filter?.open ?? false,
                        onChanged: (value) {
                          setState(() {
                            _con.filter?.open = value;
                          });
                        },
                        title: Text(
                          S.of(context).open,
                          overflow: TextOverflow.fade,
                          softWrap: false,
                          maxLines: 1,
                        ),
                      ),
                    ],
                    initiallyExpanded: true,
                  ),
                  _con.cuisines.isEmpty
                      ? CircularLoadingWidget(height: 100)
                      : ExpansionTile(
                          title: Text(S.of(context).cuisines),
                          children: List.generate(_con.cuisines.length, (index) {
                            return CheckboxListTile(
                              controlAffinity: ListTileControlAffinity.trailing,
                              value: _con.cuisines.elementAt(index).selected,
                              onChanged: (value) {
                                //print("Cocinaaaa thumb");
                                //print(_con.cuisines.elementAt(index).name);
                                _con.onChangeCuisinesFilter(index);
                              },
                              // title: Text(
                              //   _con.cuisines.elementAt(index).name,
                              //   overflow: TextOverflow.fade,
                              //   softWrap: false,
                              //   maxLines: 1,
                              // ),
                              title: (_con.cuisines.elementAt(index).id == '0') 
                                         ? Text(
                                          _con.cuisines.elementAt(index).name,
                                          overflow: TextOverflow.fade,
                                          softWrap: false,
                                          maxLines: 1,
                                          style: TextStyle(color: Theme.of(context).textTheme.subtitle1.color, fontSize: 14, fontWeight: FontWeight.w500),
                                        ) : Container(
                                                margin: EdgeInsetsDirectional.only(start: 5, end: 20),
                                                width: 80,
                                                height: 80,
                                                decoration: BoxDecoration(
                                                    color: Theme.of(context).primaryColor,
                                                    borderRadius: BorderRadius.all(Radius.circular(5)),
                                                    boxShadow: [BoxShadow(color: Theme.of(context).focusColor.withOpacity(0.2), offset: Offset(0, 2), blurRadius: 7.0)]),
                                                child: Padding(
                                                  padding: const EdgeInsets.all(5),
                                                  child: _con.cuisines.elementAt(index).image.url.toLowerCase().endsWith('.svg')
                                                      ? SvgPicture.network(
                                                          _con.cuisines.elementAt(index).image.url,
                                                          color: Theme.of(context).accentColor,
                                                        )
                                                      : CachedNetworkImage(
                                                          fit: BoxFit.cover,
                                                          imageUrl:  _con.cuisines.elementAt(index).image.thumb,
                                                          placeholder: (context, url) => Image.asset(
                                                            'assets/img/loading.gif',
                                                            fit: BoxFit.cover,
                                                          ),
                                                          errorWidget: (context, url, error) => Icon(Icons.error),
                                                        ),
                                                ),
                                        ),
                            
                              subtitle: (_con.cuisines.elementAt(index).id == '0') 
                                         ? null :  Text(
                                          _con.cuisines.elementAt(index).name,
                                          overflow: TextOverflow.fade,
                                          softWrap: false,
                                          maxLines: 1,
                                          style: TextStyle(color: Theme.of(context).textTheme.subtitle1.color, fontSize: 14, fontWeight: FontWeight.w500),
                                        ),
                                                                        );
                          }),
                          initiallyExpanded: true,
                        ),


//intento de filtro horizontal

                // _con.cuisines.isEmpty
                // ? SizedBox(height: 90)
                // : Container(
                //     height: 90,
                //     child: ListView(
                //       primary: false,
                //       shrinkWrap: true,
                //       scrollDirection: Axis.horizontal,
                //       children: List.generate(_con.cuisines.length, (index) {
                //         var cuisin = _con.cuisines.elementAt(index);
                //         print("Zimba");
                //         print(cuisin.name);
                //         var _selected = this.selectedCuisines.contains(cuisin.id);
                //         return Padding(
                //           padding: const EdgeInsetsDirectional.only(start: 20),
                //           child: RawChip(
                //             elevation: 0,
                //             label: Text(cuisin.name),
                //             labelStyle: _selected
                //                 ? Theme.of(context).textTheme.bodyText2.merge(TextStyle(color: Theme.of(context).primaryColor))
                //                 : Theme.of(context).textTheme.bodyText2,
                //             padding: EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                //             backgroundColor: Theme.of(context).focusColor.withOpacity(0.1),
                //             selectedColor: Theme.of(context).accentColor,
                //             selected: _selected,
                //             //shape: StadiumBorder(side: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.05))),
                //             showCheckmark: false,
                //             avatar: (cuisin.id == '0')
                //                 ? null
                //                 : (cuisin.image.url.toLowerCase().endsWith('.svg')
                //                     ? SvgPicture.network(
                //                         cuisin.image.url,
                //                         color: _selected ? Theme.of(context).primaryColor : Theme.of(context).accentColor,
                //                       )
                //                     : CachedNetworkImage(
                //                         fit: BoxFit.cover,
                //                         imageUrl: cuisin.image.icon,
                //                         placeholder: (context, url) => Image.asset(
                //                           'assets/img/loading.gif',
                //                           fit: BoxFit.cover,
                //                         ),
                //                         errorWidget: (context, url, error) => Icon(Icons.error),
                //                       )),
                //             onSelected: (bool value) {
                //               setState(() {
                //                 if (cuisin.id == '0') {
                //                   this.selectedCuisines = ['0'];
                //                 } else {
                //                   this.selectedCuisines.removeWhere((element) => element == '0');
                //                 }
                //                 if (value) {
                //                   this.selectedCuisines.add(cuisin.id);
                //                 } else {
                //                   this.selectedCuisines.removeWhere((element) => element == cuisin.id);
                //                 }
                //                 _con.selectCuisine(this.selectedCuisines);
                //               });
                //             },
                //           ),
                //         );
                //       }),
                //     ),
                //   ),


                ],
              ),
            ),
            SizedBox(height: 15),
            FlatButton(
              onPressed: () {
                _con.saveFilter().whenComplete(() {
                  widget.onFilter(_con.filter);
                });
              },
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              color: Theme.of(context).accentColor,
              shape: StadiumBorder(),
              child: Text(
                S.of(context).apply_filters,
                textAlign: TextAlign.start,
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
            ),
            SizedBox(height: 15)
          ],
        ),
      ),
    );
  }
}
