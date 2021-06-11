library dial_code_picker;

import 'package:dial_code_picker/country.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DialCodePicker extends StatefulWidget {
  @override
  _DialCodePickerState createState() => _DialCodePickerState();
}

class _DialCodePickerState extends State<DialCodePicker> with TickerProviderStateMixin {
  var countries = CountryProvider.instance.countriesList;
  List<Country> getFilteredCountries(String query) => countries.where((e) => e.name.toLowerCase().contains(query.toLowerCase())).toList();

  late AnimationController _animationController;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(duration:Duration(milliseconds: 300),reverseDuration: Duration(milliseconds: 250),vsync:this);

    _animation = Tween<Offset>(
      end: Offset.zero,
      begin: const Offset(0.0, 500.0),
    ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.bounceInOut,
        reverseCurve: Curves.bounceOut
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    bool isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: isDark?Colors.black:Colors.white,
      statusBarIconBrightness: isDark?Brightness.light:Brightness.dark,
    ));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black54,
      body: Stack(
        children: [
          GestureDetector(
            onTap: () async {
              await _animationController.reverse();
              Navigator.of(context).pop();
            },
            behavior: HitTestBehavior.opaque,
            child: Container(),
          ),
          SlideTransition(
            position: _animation,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: MediaQuery.of(context).size.height / 2,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16,),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topLeft: Radius.circular(16),topRight: Radius.circular(16))),
                child: Column(
                  children: [
                    SizedBox(height: 10,),
                    Container(
                      height: 50,
                      margin: EdgeInsets.only(bottom: 4),
                      child: TextField(
                        onChanged: (query) {
                          setState(() {
                            countries = getFilteredCountries(query);
                            print(countries.length);
                          });
                        },
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          prefixIcon: Icon(Icons.search,color: Colors.grey,),
                          hintText: "Search country",
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.transparent)
                          ),
                          contentPadding: EdgeInsets.zero,
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.transparent)
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                        child: countries.length==0? Center(child: Text("Country not found"),) :ListView.builder(
                            shrinkWrap: true,
                            physics: BouncingScrollPhysics(),
                            itemCount: countries.length,
                            padding: const EdgeInsets.only(top: 20),
                            itemBuilder: (context, index) {
                              var country = countries[index];
                              return GestureDetector(
                                onTap: () async {
                                  await _animationController.reverse();
                                  Navigator.pop(context,country);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 30),
                                  child: Row(
                                    children: [
                                      ClipRRect(borderRadius: BorderRadius.circular(2), child: Image.asset(country.image, width: 32,)),
                                      SizedBox(width: 16,),
                                      Expanded(child: Text(country.name + " (+${country.dialCode})"))
                                    ],
                                  ),
                                ),
                              );
                            }))
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
